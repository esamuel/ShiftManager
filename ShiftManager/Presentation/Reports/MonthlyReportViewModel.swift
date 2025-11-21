import SwiftUI
import CoreData
import Combine

@MainActor
public class MonthlyReportViewModel: ObservableObject {
    @Published var shifts: [ShiftModel] = []
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var totalShifts = 0
    @Published var totalWorkingDays = 0
    @Published var totalHours: Double = 0
    @Published var grossWage: Double = 0
    @Published var netWage: Double = 0
    @Published var regularHours: Double = 0
    @Published var overtimeHours: Double = 0
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let calendar: Calendar
    private let repository: ShiftRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public init(repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.repository = repository
        self.calendar = Calendar.current
        loadMonthlyData()
    }
    
    var monthYearString: String {
        // Use DateFormatter to get properly localized month name
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        dateFormatter.dateFormat = "MMMM" // Full month name
        
        // Create a date for the selected month/year
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        guard let date = calendar.date(from: components) else {
            return "\(selectedYear)"
        }
        
        let localizedMonth = dateFormatter.string(from: date)
        
        // For RTL languages like Hebrew, reverse the order
        if LocalizationManager.shared.currentLanguage == "he" || LocalizationManager.shared.currentLanguage == "ar" {
            return "\(localizedMonth) \(selectedYear)"
        } else {
            return "\(localizedMonth) \(selectedYear)"
        }
    }
    
    func loadMonthlyData() {
        isLoading = true
        Task {
            do {
                // Calculate the start and end dates for the selected month
                var components = DateComponents()
                components.year = selectedYear
                components.month = selectedMonth
                components.day = 1
                
                guard let startDate = calendar.date(from: components) else {
                    isLoading = false
                    return
                }
                
                // End date is the last day of the month
                components.month = selectedMonth + 1
                components.day = 0
                guard let endDate = calendar.date(from: components) else {
                    isLoading = false
                    return
                }
                
                // Set time to end of day for end date
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
                
                // Fetch shifts for the month
                let fetchedShifts = try await repository.fetchShiftsInDateRange(from: startDate, to: endOfDay)
                
                await MainActor.run {
                    self.shifts = fetchedShifts.sorted { $0.startTime < $1.startTime }
                    calculateMonthlySummary()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func calculateMonthlySummary() {
        totalShifts = shifts.count
        
        // Calculate total working days
        let uniqueDays = Set(shifts.map { calendar.startOfDay(for: $0.startTime) })
        totalWorkingDays = uniqueDays.count
        
        // Calculate hours and wages
        var totalRegularHours = 0.0
        var totalOvertimeHours = 0.0
        var totalGrossWage = 0.0
        
        for shift in shifts {
            let hours = shift.duration / 3600
            let isSpecialDay = isSpecialWorkDay(shift.startTime)
            
            // Determine base hours (8 for regular days, can be different for special days)
            let baseHours = UserDefaults.standard.double(forKey: isSpecialDay ? "baseHoursSpecialDay" : "baseHoursWeekday")
            let effectiveBaseHours = baseHours > 0 ? baseHours : 8.0
            
            // Calculate regular and overtime hours
            if hours <= effectiveBaseHours {
                totalRegularHours += hours
            } else {
                totalRegularHours += effectiveBaseHours
                totalOvertimeHours += (hours - effectiveBaseHours)
            }
            
            totalGrossWage += shift.grossWage
        }
        
        regularHours = totalRegularHours
        overtimeHours = totalOvertimeHours
        totalHours = totalRegularHours + totalOvertimeHours
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
    
    func previousMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
        loadMonthlyData()
    }
    
    func nextMonth() {
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
        loadMonthlyData()
    }
}


