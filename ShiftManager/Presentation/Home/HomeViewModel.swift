import Foundation
import CoreData

public class HomeViewModel: ObservableObject {
    @Published public var todayShifts: [ShiftModel] = []
    @Published public var weeklySummary: WeeklySummary?
    @Published public var isLoading = false
    @Published public var error: Error?
    
    private let repository: ShiftRepositoryProtocol
    
    public init(repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.repository = repository
    }
    
    @MainActor
    public func loadData() async {
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
    
    public func totalHoursWorked() -> TimeInterval {
        return todayShifts.reduce(0) { $0 + $1.duration }
    }
    
    public func totalEarnings(rate: Double) -> Double {
        return totalHoursWorked() / 3600 * rate
    }
}

public struct WeeklySummary {
    public let totalHours: Double
    public let overtimeHours: Double
    public let totalShifts: Int
    
    public init(shifts: [ShiftModel]) {
        totalHours = shifts.reduce(0) { $0 + $1.duration / 3600 }
        overtimeHours = shifts.filter { $0.isOvertime }.reduce(0) { $0 + $1.duration / 3600 }
        totalShifts = shifts.count
    }
} 