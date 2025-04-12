import Foundation
import CoreData

class HomeViewModel: ObservableObject {
    @Published var todayShifts: [ShiftModel] = []
    @Published var weeklySummary: WeeklySummary?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let repository: ShiftRepositoryProtocol
    
    init(repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.repository = repository
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        do {
            // Load today's shifts
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            todayShifts = try await repository.fetchShiftsInDateRange(from: today, to: tomorrow)
            
            // Calculate weekly summary
            let weekStart = calendar.date(byAdding: .day, value: -7, to: today)!
            let weekShifts = try await repository.fetchShiftsInDateRange(from: weekStart, to: tomorrow)
            
            weeklySummary = WeeklySummary(shifts: weekShifts)
            error = nil
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func totalHoursWorked() -> TimeInterval {
        return todayShifts.reduce(0) { $0 + $1.duration }
    }
    
    func totalEarnings(rate: Double) -> Double {
        return totalHoursWorked() / 3600 * rate
    }
}

struct WeeklySummary {
    let totalHours: Double
    let overtimeHours: Double
    let totalShifts: Int
    
    init(shifts: [ShiftModel]) {
        totalHours = shifts.reduce(0) { $0 + $1.duration / 3600 }
        overtimeHours = shifts.filter { $0.isOvertime }.reduce(0) { $0 + $1.duration / 3600 }
        totalShifts = shifts.count
    }
} 