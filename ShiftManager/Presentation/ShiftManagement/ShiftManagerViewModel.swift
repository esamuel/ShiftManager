import SwiftUI
import CoreData

@MainActor
class ShiftManagerViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var startTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var endTime = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var notes = ""
    @Published var shifts: [ShiftModel] = []
    @Published var showCurrentMonthOnly = true
    
    // UI State
    @Published var showDatePicker = false
    @Published var showStartTimePicker = false
    @Published var showEndTimePicker = false
    @Published var showingDuplicateAlert = false
    @Published var showingLongShiftAlert = false
    @Published var error: Error?
    
    @Published var isEditing = false
    @Published var shiftBeingEdited: ShiftModel?
    
    private let context: NSManagedObjectContext
    private let wageCalculationService: WageCalculationService
    
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
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.wageCalculationService = WageCalculationService(context: context)
    }
    
    func loadShifts() async {
        do {
            let request = NSFetchRequest<Shift>(entityName: "Shift")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)]
            
            let results = try context.fetch(request)
            shifts = results.map { entity in
                ShiftModel(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    startTime: entity.startTime ?? Date(),
                    endTime: entity.endTime ?? Date(),
                    notes: entity.notes ?? "",
                    isOvertime: entity.isOvertime,
                    isSpecialDay: entity.isSpecialDay,
                    category: entity.category ?? "",
                    createdAt: entity.createdAt ?? Date(),
                    grossWage: entity.grossWage,
                    netWage: entity.netWage
                )
            }
        } catch {
            self.error = error
        }
    }
    
    func addShift() {
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
        
        // Determine if it's a special day based on the work week start setting
        let startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        let weekday = calendar.component(.weekday, from: shiftStart)
        let isSpecialDay = weekday == (startWorkOnSunday ? 7 : 1) // Saturday (7) for Sunday start, Sunday (1) for Monday start
        
        // Create new shift
        let entity = Shift(context: context)
        entity.id = UUID()
        
        // Format the date in a localized way
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: selectedDate)
        entity.title = String(format: "Shift on %@".localized, dateString)
        
        entity.startTime = shiftStart
        entity.endTime = shiftEnd
        entity.notes = notes
        entity.createdAt = Date()
        entity.isOvertime = false
        entity.isSpecialDay = isSpecialDay
        entity.category = ""
        
        // Calculate wages
        Task {
            if let calculation = try? await wageCalculationService.calculateWage(for: ShiftModel(
                id: entity.id ?? UUID(),
                title: entity.title ?? "",
                startTime: entity.startTime ?? Date(),
                endTime: entity.endTime ?? Date(),
                notes: entity.notes ?? "",
                isOvertime: entity.isOvertime,
                isSpecialDay: entity.isSpecialDay,
                category: entity.category ?? "",
                createdAt: entity.createdAt ?? Date()
            )) {
                entity.grossWage = calculation.grossWage
                entity.netWage = calculation.netWage
            }
            
            do {
                try context.save()
                await loadShifts()
                
                // Reset form
                notes = ""
            } catch {
                self.error = error
            }
        }
    }
    
    func deleteShift(_ shift: ShiftModel) async {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                context.delete(entity)
                try context.save()
                await loadShifts()
            }
        } catch {
            self.error = error
        }
    }
    
    func editShift(_ shift: ShiftModel) {
        selectedDate = shift.startTime
        startTime = shift.startTime
        endTime = shift.endTime
        notes = shift.notes
    }
    
    func toggleSpecialDay(_ shift: ShiftModel) async {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.isSpecialDay.toggle()
                
                // Recalculate wages
                if let calculation = try? await wageCalculationService.calculateWage(for: ShiftModel(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    startTime: entity.startTime ?? Date(),
                    endTime: entity.endTime ?? Date(),
                    notes: entity.notes ?? "",
                    isOvertime: entity.isOvertime,
                    isSpecialDay: entity.isSpecialDay,
                    category: entity.category ?? "",
                    createdAt: entity.createdAt ?? Date()
                )) {
                    entity.grossWage = calculation.grossWage
                    entity.netWage = calculation.netWage
                }
                
                try context.save()
                await loadShifts()
            }
        } catch {
            self.error = error
        }
    }
    
    func startEditing(_ shift: ShiftModel) {
        shiftBeingEdited = shift
        isEditing = true
    }
    
    @MainActor
    func updateShift(_ shift: ShiftModel) async {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.startTime = shift.startTime
                entity.endTime = shift.endTime
                entity.notes = shift.notes
                entity.isSpecialDay = shift.isSpecialDay
                
                // Recalculate wages
                if let calculation = try? await wageCalculationService.calculateWage(for: shift) {
                    entity.grossWage = calculation.grossWage
                    entity.netWage = calculation.netWage
                }
                
                try context.save()
                await loadShifts()
            }
        } catch {
            self.error = error
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
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
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
            startTime: entity.startTime ?? Date(),
            endTime: entity.endTime ?? Date(),
            notes: entity.notes ?? "",
            isOvertime: entity.isOvertime,
            isSpecialDay: entity.isSpecialDay,
            category: entity.category ?? "",
            createdAt: entity.createdAt ?? Date()
        )) {
            entity.grossWage = calculation.grossWage
            entity.netWage = calculation.netWage
        }
        
        do {
            try context.save()
            await loadShifts()
            self.notes = ""
        } catch {
            self.error = error
        }
    }
} 