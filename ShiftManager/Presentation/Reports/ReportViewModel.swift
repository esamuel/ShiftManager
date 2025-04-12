import SwiftUI
import CoreData

@MainActor
public class ReportViewModel: ObservableObject {
    @Published var shifts: [ShiftModel] = []
    @Published var currentPeriodStart: Date
    @Published var currentPeriodEnd: Date
    @Published var selectedView: ShiftManager.ReportViewType = .weekly
    @Published var totalWorkingDays = 0
    @Published var totalHours: Double = 0
    @Published var grossWage: Double = 0
    @Published var netWage: Double = 0
    @Published var regularHours: Double = 0
    @Published var overtimeHours125: Double = 0
    @Published var overtimeHours150: Double = 0
    
    private let calendar: Calendar
    private let repository: ShiftRepositoryProtocol
    
    public init(repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.repository = repository
        
        let calendar = Calendar.current
        
        // Initialize with current week
        let weekday = calendar.component(.weekday, from: Date())
        let daysToSubtract = (weekday - calendar.firstWeekday + 7) % 7
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: Date())!
        
        self.calendar = calendar
        self.currentPeriodStart = startOfWeek
        self.currentPeriodEnd = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        loadShifts()
    }
    
    var periodTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = selectedView == .weekly ? "MMMM yyyy" : "MMMM yyyy"
        return formatter.string(from: currentPeriodStart)
    }
    
    var periodRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(formatter.string(from: currentPeriodStart)) - \(formatter.string(from: currentPeriodEnd))"
    }
    
    private func updatePeriodRange() {
        let today = Date()
        
        if selectedView == .weekly {
            // Get the start of the week containing currentPeriodStart
            let weekday = calendar.component(.weekday, from: currentPeriodStart)
            let daysToSubtract = (weekday - calendar.firstWeekday + 7) % 7
            currentPeriodStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: currentPeriodStart)!
            
            // End of week is 6 days after start (inclusive of both start and end)
            currentPeriodEnd = calendar.date(byAdding: .day, value: 6, to: currentPeriodStart)!
            // Add one day to include the entire end day
            currentPeriodEnd = calendar.date(byAdding: .day, value: 1, to: currentPeriodEnd)!
        } else {
            // Get the start of the month containing currentPeriodStart
            var components = calendar.dateComponents([.year, .month], from: currentPeriodStart)
            currentPeriodStart = calendar.date(from: components)!
            
            // End of month is the start of next month minus 1 second
            components.month! += 1
            currentPeriodEnd = calendar.date(from: components)!
        }
    }
    
    func previousPeriod() {
        if selectedView == .weekly {
            currentPeriodStart = calendar.date(byAdding: .day, value: -7, to: currentPeriodStart)!
        } else {
            currentPeriodStart = calendar.date(byAdding: .month, value: -1, to: currentPeriodStart)!
        }
        updatePeriodRange()
        loadShifts()
    }
    
    func nextPeriod() {
        if selectedView == .weekly {
            currentPeriodStart = calendar.date(byAdding: .day, value: 7, to: currentPeriodStart)!
        } else {
            currentPeriodStart = calendar.date(byAdding: .month, value: 1, to: currentPeriodStart)!
        }
        updatePeriodRange()
        loadShifts()
    }
    
    func switchView(to view: ShiftManager.ReportViewType) {
        selectedView = view
        updatePeriodRange()
        loadShifts()
    }
    
    private func loadShifts() {
        Task {
            do {
                let shifts = try await repository.fetchShiftsInDateRange(from: currentPeriodStart, to: currentPeriodEnd)
                await MainActor.run {
                    // Sort shifts by date
                    self.shifts = shifts.sorted { $0.startTime < $1.startTime }
                    calculateSummary()
                }
            } catch {
                print("Error loading shifts: \(error)")
            }
        }
    }
    
    private func calculateSummary() {
        // Calculate total working days
        let uniqueDays = Set(shifts.map { calendar.startOfDay(for: $0.startTime) })
        totalWorkingDays = uniqueDays.count
        
        // Calculate hours and wages
        var totalRegularHours = 0.0
        var totalOvertime125Hours = 0.0
        var totalOvertime150Hours = 0.0
        var totalGrossWage = 0.0
        
        for shift in shifts {
            let hours = shift.duration / 3600
            let isSpecialDay = isSpecialWorkDay(shift.startTime)
            
            // First 8 hours
            let baseHours = min(8.0, hours)
            if isSpecialDay {
                // Special day base rate is 150%
                totalOvertime150Hours += baseHours
            } else {
                // Regular day base rate is 100%
                totalRegularHours += baseHours
            }
            
            // Next 2 hours (hours 9-10)
            if hours > 8.0 {
                let overtime1 = min(2.0, hours - 8.0)
                if isSpecialDay {
                    // Special day first overtime is 175%
                    totalOvertime150Hours += overtime1 * 1.75
                } else {
                    // Regular day first overtime is 125%
                    totalOvertime125Hours += overtime1
                }
            }
            
            // Remaining hours (after 10 hours)
            if hours > 10.0 {
                let overtime2 = hours - 10.0
                if isSpecialDay {
                    // Special day second overtime is 200%
                    totalOvertime150Hours += overtime2 * 2.0
                } else {
                    // Regular day second overtime is 150%
                    totalOvertime150Hours += overtime2
                }
            }
            
            totalGrossWage += shift.grossWage
        }
        
        regularHours = totalRegularHours
        overtimeHours125 = totalOvertime125Hours
        overtimeHours150 = totalOvertime150Hours
        totalHours = totalRegularHours + totalOvertime125Hours + totalOvertime150Hours
        grossWage = totalGrossWage
        
        // Get tax rate from settings
        let taxDeduction = UserDefaults.standard.double(forKey: "taxDeduction") / 100
        netWage = totalGrossWage * (1 - taxDeduction)
    }
    
    private func isSpecialWorkDay(_ date: Date) -> Bool {
        let startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        let weekday = calendar.component(.weekday, from: date)
        
        if startWorkOnSunday {
            // If week starts on Sunday, Saturday is special
            return weekday == 7 // 7 is Saturday
        } else {
            // If week starts on Monday, Sunday is special
            return weekday == 1 // 1 is Sunday
        }
    }
    
    @MainActor
    func loadShiftsForDateRange(start: Date, end: Date) async {
        do {
            // Clear existing shifts
            shifts = []
            
            // Load shifts from CoreData for the specified date range
            let fetchedShifts = try await repository.fetchShiftsInDateRange(from: start, to: end)
            
            // Update shifts array
            shifts = fetchedShifts
            
            // Calculate totals
            calculateSummary()
        } catch {
            print("Error loading shifts: \(error)")
        }
    }
} 