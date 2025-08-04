import SwiftUI
import CoreData
import Foundation
import Combine
import UserNotifications

@MainActor
public class ShiftManagerViewModel: ObservableObject {
    @Published public var shifts: [ShiftModel] = []
    @Published public var selectedDate: Date = Date()
    @Published public var startTime: Date = Date()
    @Published public var endTime: Date = Date()
    @Published public var notes: String = ""
    @Published public var showingDuplicateAlert = false
    @Published public var showingLongShiftAlert = false
    @Published public var showCurrentMonthOnly = false
    @Published var localizationManager = LocalizationManager.shared
    
    // UI State
    @Published var showDatePicker = false
    @Published var showStartTimePicker = false
    @Published var showEndTimePicker = false
    @Published var error: Error?
    
    @Published var isEditing = false
    @Published var shiftBeingEdited: ShiftModel?
    
    private let context: NSManagedObjectContext
    private let wageCalculationService: WageCalculationService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Notification Scheduling
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleShiftNotification(shift: ShiftModel, leadTimeMinutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Upcoming Shift", comment: "")
        content.body = String(format: NSLocalizedString("Your shift starts at %@", comment: ""), shift.startTime.formattedString(format: "MMM d, h:mm a"))
        content.sound = .default
        
        let triggerDate = shift.startTime.addingTimeInterval(TimeInterval(-leadTimeMinutes * 60))
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: shift.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelShiftNotification(shiftID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [shiftID.uuidString])
    }
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
         wageCalculationService: WageCalculationService = WageCalculationService()) {
        self.context = context
        self.wageCalculationService = wageCalculationService
        
        // Set initial default times for startTime and endTime based on selectedDate
        setDefaultTimes(for: self.selectedDate)

        Task {
            await loadShifts()
        }
        
        // Listen for language changes
        NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))
            .sink { [weak self] _ in
                Task {
                    await self?.loadShifts()
                }
            }
            .store(in: &cancellables)
            
        // Observe selectedDate changes to update default start/end times
        $selectedDate
            .dropFirst() // To avoid re-triggering for the initial selectedDate value
            .sink { [weak self] newDate in
                self?.setDefaultTimes(for: newDate)
            }
            .store(in: &cancellables)
    }
    
    private func setDefaultTimes(for date: Date) {
        let calendar = Calendar.current
        // Get year, month, day from the passed 'date', ignoring its time component for setting defaults
        var components = calendar.dateComponents([.year, .month, .day], from: date)

        components.hour = 8
        components.minute = 0
        components.second = 0
        self.startTime = calendar.date(from: components) ?? Date()

        components.hour = 17
        components.minute = 0
        components.second = 0
        self.endTime = calendar.date(from: components) ?? Date()

        // Robustness check: if endTime is not after startTime (e.g., calendar.date failed and defaulted to Date() differently)
        if self.endTime <= self.startTime {
            // Fallback to ensure endTime is 9 hours after startTime if direct setting fails
            self.endTime = calendar.date(byAdding: .hour, value: 9, to: self.startTime) ?? Date()
        }
    }
    
    func loadShifts() async {
        do {
            let request = NSFetchRequest<Shift>(entityName: "Shift")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Shift.startTime, ascending: true)]
            
            let results = try await context.perform {
                try self.context.fetch(request)
            }
            
            self.shifts = results.map { shift in
                ShiftModel(
                    id: shift.id ?? UUID(),
                    title: shift.title ?? "",
                    category: shift.category ?? "",
                    startTime: shift.startTime ?? Date(),
                    endTime: shift.endTime ?? Date(),
                    notes: shift.notes ?? "",
                    isOvertime: shift.isOvertime,
                    isSpecialDay: shift.isSpecialDay,
                    grossWage: shift.grossWage,
                    netWage: shift.netWage,
                    createdAt: shift.createdAt ?? Date()
                )
            }
        } catch {
            print("Error loading shifts: \(error)")
        }
    }
    
    var canAddShift: Bool {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        // Combine selected date with time components
        let shiftStart = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                     minute: startComponents.minute ?? 0,
                                     second: 0,
                                     of: selectedDate) ?? selectedDate
        let shiftEnd = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                   minute: endComponents.minute ?? 0,
                                   second: 0,
                                   of: selectedDate) ?? selectedDate
        
        // Check if shift already exists
        return !shifts.contains { existingShift in
            let existingStart = existingShift.startTime
            let existingEnd = existingShift.endTime
            return calendar.isDate(existingStart, inSameDayAs: shiftStart) &&
                   ((shiftStart >= existingStart && shiftStart < existingEnd) ||
                    (shiftEnd > existingStart && shiftEnd <= existingEnd) ||
                    (shiftStart <= existingStart && shiftEnd >= existingEnd))
        }
    }
    
    var filteredShifts: [ShiftModel] {
        if showCurrentMonthOnly {
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: Date())
            let currentYear = calendar.component(.year, from: Date())
            
            return shifts.filter { shift in
                let shiftMonth = calendar.component(.month, from: shift.startTime)
                let shiftYear = calendar.component(.year, from: shift.startTime)
                return shiftMonth == currentMonth && shiftYear == currentYear
            }
        }
        return shifts
    }
    
    func addShift() {
        Task {
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
            let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
            
            // Combine selected date with time components
            let shiftStart = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                         minute: startComponents.minute ?? 0,
                                         second: 0,
                                         of: selectedDate) ?? selectedDate
            let shiftEnd = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                       minute: endComponents.minute ?? 0,
                                       second: 0,
                                       of: selectedDate) ?? selectedDate
            
            // Check for existing shift
            if !canAddShift {
                showingDuplicateAlert = true
                return
            }
            
            // Check for shift duration
            let duration = shiftEnd.timeIntervalSince(shiftStart)
            let hours = duration / 3600
            
            if hours > 12 {
                showingLongShiftAlert = true
                return
            }
            
            await createShift(startTime: shiftStart, endTime: shiftEnd, notes: notes)
            await loadShifts()
        }
    }
    
    func createShift(startTime: Date, endTime: Date, notes: String) async {
        let calendar = Calendar.current
        let startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        let weekday = calendar.component(.weekday, from: startTime)
        let isSpecialDay = weekday == (startWorkOnSunday ? 7 : 1) // Saturday (7) for Sunday start, Sunday (1) for Monday start
        
        let entity = Shift(context: context)
        entity.id = UUID()
        
        // Format the date in a localized way
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.formattingContext = .standalone
        let dateString = dateFormatter.string(from: selectedDate)
        entity.title = String(format: "Shift on %@".localized, dateString)
        
        entity.startTime = startTime
        entity.endTime = endTime
        entity.notes = notes
        entity.createdAt = Date()
        entity.isOvertime = false
        entity.isSpecialDay = isSpecialDay
        entity.category = ""
        
        if let calculation = try? await wageCalculationService.calculateWage(for: ShiftModel(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            category: entity.category ?? "",
            startTime: entity.startTime ?? Date(),
            endTime: entity.endTime ?? Date(),
            notes: entity.notes ?? "",
            isOvertime: entity.isOvertime,
            isSpecialDay: entity.isSpecialDay,
            grossWage: entity.grossWage,
            netWage: entity.netWage,
            createdAt: entity.createdAt ?? Date()
        )) {
            entity.grossWage = calculation.grossWage
            entity.netWage = calculation.netWage
        }
        
        do {
            try await context.perform {
                try self.context.save()
            }
        } catch {
            print("Error saving shift: \(error)")
        }
    }
    
    func deleteShift(_ shift: ShiftModel) {
        Task {
            do {
                let request = NSFetchRequest<Shift>(entityName: "Shift")
                request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
                
                let results = try await context.perform {
                    try self.context.fetch(request)
                }
                
                if let shiftToDelete = results.first {
                    await context.perform {
                        self.context.delete(shiftToDelete)
                    }
                    try await context.perform {
                        try self.context.save()
                    }
                    await loadShifts()
                }
            } catch {
                print("Error deleting shift: \(error)")
            }
        }
    }
    
    func editShift(_ shift: ShiftModel) {
        selectedDate = shift.startTime
        startTime = shift.startTime
        endTime = shift.endTime
        notes = shift.notes
    }
    
    func toggleSpecialDay(_ shift: ShiftModel) {
        Task {
            let request = NSFetchRequest<Shift>(entityName: "Shift")
            request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
            
            do {
                let results = try await context.perform {
                    try self.context.fetch(request)
                }
                if let entity = results.first {
                    entity.isSpecialDay.toggle()
                    
                    // Recalculate wages
                    if let calculation = try? await wageCalculationService.calculateWage(for: ShiftModel(
                        id: entity.id ?? UUID(),
                        title: entity.title ?? "",
                        category: entity.category ?? "",
                        startTime: entity.startTime ?? Date(),
                        endTime: entity.endTime ?? Date(),
                        notes: entity.notes ?? "",
                        isOvertime: entity.isOvertime,
                        isSpecialDay: entity.isSpecialDay,
                        grossWage: entity.grossWage,
                        netWage: entity.netWage,
                        createdAt: entity.createdAt ?? Date()
                    )) {
                        entity.grossWage = calculation.grossWage
                        entity.netWage = calculation.netWage
                    }
                    
                    try await context.perform {
                        try self.context.save()
                    }
                    await loadShifts()
                }
            } catch {
                self.error = error
            }
        }
    }
    
    func startEditing(_ shift: ShiftModel) {
        shiftBeingEdited = shift
        isEditing = true
    }
    
    func updateShift(_ shift: ShiftModel) {
        Task {
            let request = NSFetchRequest<Shift>(entityName: "Shift")
            request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
            
            do {
                let results = try await context.perform {
                    try self.context.fetch(request)
                }
                if let entity = results.first {
                    entity.startTime = shift.startTime
                    entity.endTime = shift.endTime
                    entity.notes = shift.notes
                    entity.isSpecialDay = shift.isSpecialDay
                    
                    // Recalculate wages
                    if let calculation = try? await wageCalculationService.calculateWage(for: ShiftModel(
                        id: entity.id ?? UUID(),
                        title: entity.title ?? "",
                        category: entity.category ?? "",
                        startTime: entity.startTime ?? Date(),
                        endTime: entity.endTime ?? Date(),
                        notes: entity.notes ?? "",
                        isOvertime: entity.isOvertime,
                        isSpecialDay: entity.isSpecialDay,
                        grossWage: entity.grossWage,
                        netWage: entity.netWage,
                        createdAt: entity.createdAt ?? Date()
                    )) {
                        entity.grossWage = calculation.grossWage
                        entity.netWage = calculation.netWage
                    }
                    
                    try await context.perform {
                        try self.context.save()
                    }
                    await loadShifts()
                }
            } catch {
                self.error = error
            }
        }
    }
} 