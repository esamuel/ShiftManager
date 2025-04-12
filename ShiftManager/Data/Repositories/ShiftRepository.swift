import Foundation
import CoreData

public protocol ShiftRepositoryProtocol {
    func fetchShifts() async throws -> [ShiftModel]
    func fetchShift(id: UUID) async throws -> ShiftModel?
    func createShift(_ shift: ShiftModel) async throws
    func updateShift(_ shift: ShiftModel) async throws
    func deleteShift(id: UUID) async throws
    func fetchShiftsInDateRange(from startDate: Date, to endDate: Date) async throws -> [ShiftModel]
    func fetchAllShifts() async throws -> [ShiftModel]
    func deleteAllShifts() async throws
}

public class ShiftRepository: ShiftRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    public func fetchShifts() async throws -> [ShiftModel] {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)]
        
        return try await context.perform {
            let shifts = try self.context.fetch(request)
            return shifts.map { self.mapToModel($0) }
        }
    }
    
    public func fetchShift(id: UUID) async throws -> ShiftModel? {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return try await context.perform {
            let shifts = try self.context.fetch(request)
            return shifts.first.map { self.mapToModel($0) }
        }
    }
    
    public func createShift(_ shift: ShiftModel) async throws {
        try await context.perform {
            let entity = Shift(context: self.context)
            self.mapToEntity(shift, entity: entity)
            try self.context.save()
        }
    }
    
    public func updateShift(_ shift: ShiftModel) async throws {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
        
        try await context.perform {
            let shifts = try self.context.fetch(request)
            guard let entity = shifts.first else {
                throw RepositoryError.notFound
            }
            
            self.mapToEntity(shift, entity: entity)
            try self.context.save()
        }
    }
    
    public func deleteShift(id: UUID) async throws {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        try await context.perform {
            let shifts = try self.context.fetch(request)
            guard let entity = shifts.first else {
                throw RepositoryError.notFound
            }
            
            self.context.delete(entity)
            try self.context.save()
        }
    }
    
    public func fetchShiftsInDateRange(from startDate: Date, to endDate: Date) async throws -> [ShiftModel] {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.predicate = NSPredicate(format: "startTime >= %@ AND endTime <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)]
        
        return try await context.perform {
            let shifts = try self.context.fetch(request)
            return shifts.map { self.mapToModel($0) }
        }
    }
    
    public func fetchAllShifts() async throws -> [ShiftModel] {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)]
        
        return try await context.perform {
            let shifts = try self.context.fetch(request)
            return shifts.map { self.mapToModel($0) }
        }
    }
    
    public func deleteAllShifts() async throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Shift")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try await context.perform {
            try self.context.execute(deleteRequest)
            try self.context.save()
        }
    }
    
    // MARK: - Mapping Methods
    
    private func mapToModel(_ entity: Shift) -> ShiftModel {
        return ShiftModel(
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
    
    private func mapToEntity(_ model: ShiftModel, entity: Shift) {
        entity.id = model.id
        entity.title = model.title
        entity.startTime = model.startTime
        entity.endTime = model.endTime
        entity.notes = model.notes
        entity.isOvertime = model.isOvertime
        entity.isSpecialDay = model.isSpecialDay
        entity.category = model.category
        entity.createdAt = model.createdAt
        entity.grossWage = model.grossWage
        entity.netWage = model.netWage
    }
}

public enum RepositoryError: Error {
    case notFound
    case saveFailed
    case deleteFailed
} 