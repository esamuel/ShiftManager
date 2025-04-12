import Foundation
import CoreData

public class CalendarViewModel: ObservableObject {
    @Published public var selectedDate: Date
    @Published private var shifts: [ShiftModel] = []
    
    private let repository: ShiftRepositoryProtocol
    
    public init(selectedDate: Date = Date(), repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.selectedDate = selectedDate
        self.repository = repository
        loadShifts()
    }
    
    public func hasShifts(for date: Date) -> Bool {
        let calendar = Calendar.current
        return shifts.contains { shift in
            calendar.isDate(shift.startTime, inSameDayAs: date)
        }
    }
    
    public func getShifts(for date: Date) -> [ShiftModel] {
        let calendar = Calendar.current
        return shifts.filter { shift in
            calendar.isDate(shift.startTime, inSameDayAs: date)
        }
    }
    
    private func loadShifts() {
        Task {
            do {
                let allShifts = try await repository.fetchAllShifts()
                await MainActor.run {
                    self.shifts = allShifts
                }
            } catch {
                print("Error loading shifts: \(error)")
            }
        }
    }
} 