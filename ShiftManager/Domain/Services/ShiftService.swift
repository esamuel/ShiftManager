import Foundation

class ShiftService {
    private let repository: ShiftRepositoryProtocol
    
    init(repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.repository = repository
    }
    
    func getAllShifts() async throws -> [ShiftModel] {
        return try await repository.fetchShifts()
    }
    
    func createShift(title: String, startTime: Date, endTime: Date, isOvertime: Bool = false, notes: String? = nil) async throws {
        let shift = ShiftModel(
            id: UUID(),
            title: title,
            startTime: startTime,
            endTime: endTime,
            notes: notes ?? "",
            isOvertime: isOvertime
        )
        try await repository.createShift(shift)
    }
    
    func deleteShift(id: UUID) async throws {
        try await repository.deleteShift(id: id)
    }
    
    func getShiftsInDateRange(from startDate: Date, to endDate: Date) async throws -> [ShiftModel] {
        return try await repository.fetchShiftsInDateRange(from: startDate, to: endDate)
    }
} 