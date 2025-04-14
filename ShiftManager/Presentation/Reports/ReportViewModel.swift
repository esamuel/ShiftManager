import SwiftUI
import CoreData
import Combine

@MainActor
public class ReportViewModel: ObservableObject {
    @Published var shifts: [ShiftModel] = []
    @Published var currentPeriodStart: Date
    @Published var currentPeriodEnd: Date
    @Published var selectedView: ReportViewType = .weekly
    @Published var totalWorkingDays = 0
    @Published var totalHours: Double = 0
    @Published var grossWage: Double = 0
    @Published var netWage: Double = 0
    @Published var regularHours: Double = 0
    @Published var overtimeHours125: Double = 0
    @Published var overtimeHours150: Double = 0
    @Published var overtimeHours175: Double = 0
    @Published var overtimeHours200: Double = 0
    @Published var selectedReportType: ReportViewType = .daily
    @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var endDate: Date = Date()
    @Published var reports: [Report] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let calendar: Calendar
    private let repository: ShiftRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
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
        loadReports()
    }
    
    var periodTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        // Get the month name from localized strings
        let month = calendar.component(.month, from: currentPeriodStart)
        let year = calendar.component(.year, from: currentPeriodStart)
        
        let monthNames = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        
        let localizedMonth = monthNames[month - 1].localized
        return "\(localizedMonth) \(year)"
    }
    
    var periodRangeText: String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let startDay = dayFormatter.string(from: currentPeriodStart)
        let endDay = dayFormatter.string(from: currentPeriodEnd)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let month = calendar.component(.month, from: currentPeriodStart)
        let endMonth = calendar.component(.month, from: currentPeriodEnd)
        
        let monthNames = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        
        let localizedMonth = monthNames[month - 1].localized
        let localizedEndMonth = monthNames[endMonth - 1].localized
        
        let year = calendar.component(.year, from: currentPeriodStart)
        let endYear = calendar.component(.year, from: currentPeriodEnd)
        
        let shortMonth = String(localizedMonth.prefix(3))
        let shortEndMonth = String(localizedEndMonth.prefix(3))
        
        if month == endMonth && year == endYear {
            return "\(startDay) \(shortMonth) \(year) - \(endDay) \(shortMonth) \(year)"
        } else if year == endYear {
            return "\(startDay) \(shortMonth) - \(endDay) \(shortEndMonth) \(year)"
        } else {
            return "\(startDay) \(shortMonth) \(year) - \(endDay) \(shortEndMonth) \(endYear)"
        }
    }
    
    private func updatePeriodRange() {
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
    
    func switchView(to view: ReportViewType) {
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
        var totalOvertime175Hours = 0.0
        var totalOvertime200Hours = 0.0
        var totalGrossWage = 0.0
        
        for shift in shifts {
            let hours = shift.duration / 3600
            let isSpecialDay = isSpecialWorkDay(shift.startTime)
            
            // Base hours (first 8 hours)
            let baseHours = min(8.0, hours)
            if isSpecialDay {
                // Special day base rate is 150%
                totalOvertime150Hours += baseHours
            } else {
                // Regular day base rate is 100%
                totalRegularHours += baseHours
            }
            
            // First overtime tier (hours 9-10)
            if hours > 8.0 {
                let overtime1 = min(2.0, hours - 8.0)
                if isSpecialDay {
                    // Special day first overtime is 175%
                    totalOvertime175Hours += overtime1
                } else {
                    // Regular day first overtime is 125%
                    totalOvertime125Hours += overtime1
                }
            }
            
            // Second overtime tier (after 10 hours)
            if hours > 10.0 {
                let overtime2 = hours - 10.0
                if isSpecialDay {
                    // Special day second overtime is 200%
                    totalOvertime200Hours += overtime2
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
        overtimeHours175 = totalOvertime175Hours
        overtimeHours200 = totalOvertime200Hours
        totalHours = totalRegularHours + totalOvertime125Hours + totalOvertime150Hours + totalOvertime175Hours + totalOvertime200Hours
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
    
    func loadReports() {
        isLoading = true
        error = nil
        
        // TODO: Implement actual report loading logic
        // For now, just simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.reports = self.generateSampleReports()
        }
    }
    
    private func generateSampleReports() -> [Report] {
        // Generate sample reports based on selected type
        var reports: [Report] = []
        let calendar = Calendar.current
        
        switch selectedReportType {
        case .daily:
            for day in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -day, to: Date()) {
                    reports.append(Report(
                        id: UUID().uuidString,
                        date: date,
                        totalHours: Double.random(in: 4...12),
                        earnings: Double.random(in: 50...200)
                    ))
                }
            }
        case .weekly:
            for week in 0..<4 {
                if let date = calendar.date(byAdding: .weekOfYear, value: -week, to: Date()) {
                    reports.append(Report(
                        id: UUID().uuidString,
                        date: date,
                        totalHours: Double.random(in: 20...40),
                        earnings: Double.random(in: 300...800)
                    ))
                }
            }
        case .monthly:
            for month in 0..<12 {
                if let date = calendar.date(byAdding: .month, value: -month, to: Date()) {
                    reports.append(Report(
                        id: UUID().uuidString,
                        date: date,
                        totalHours: Double.random(in: 80...160),
                        earnings: Double.random(in: 1200...3200)
                    ))
                }
            }
        case .yearly:
            for year in 0..<5 {
                if let date = calendar.date(byAdding: .year, value: -year, to: Date()) {
                    reports.append(Report(
                        id: UUID().uuidString,
                        date: date,
                        totalHours: Double.random(in: 1000...2000),
                        earnings: Double.random(in: 15000...40000)
                    ))
                }
            }
        case .custom:
            // Generate reports for the custom date range
            let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            for day in 0...days {
                if let date = calendar.date(byAdding: .day, value: day, to: startDate) {
                    reports.append(Report(
                        id: UUID().uuidString,
                        date: date,
                        totalHours: Double.random(in: 4...12),
                        earnings: Double.random(in: 50...200)
                    ))
                }
            }
        }
        
        return reports.sorted { $0.date > $1.date }
    }
}

struct Report: Identifiable {
    let id: String
    let date: Date
    let totalHours: Double
    let earnings: Double
} 