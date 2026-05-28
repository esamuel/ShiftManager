import Foundation
@preconcurrency import CoreData

public protocol ShiftRepositoryProtocol: Sendable {
    func fetchShifts() async throws -> [ShiftModel]
    func fetchShift(id: UUID) async throws -> ShiftModel?
    func createShift(_ shift: ShiftModel) async throws
    func updateShift(_ shift: ShiftModel) async throws
    func deleteShift(id: UUID) async throws
    func fetchShiftsInDateRange(from startDate: Date, to endDate: Date) async throws -> [ShiftModel]
    func fetchAllShifts() async throws -> [ShiftModel]
    func deleteAllShifts() async throws
    func recalculateDailyWages(for date: Date) async throws
}

public final class ShiftRepository: ShiftRepositoryProtocol, @unchecked Sendable {
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
            category: entity.category ?? "",
            startTime: entity.startTime ?? Date(),
            endTime: entity.endTime ?? Date(),
            notes: entity.notes ?? "",
            isOvertime: entity.isOvertime,
            isSpecialDay: entity.isSpecialDay,
            grossWage: entity.grossWage,
            netWage: entity.netWage,
            createdAt: entity.createdAt ?? Date(),
            stationId: entity.value(forKey: "stationId") as? UUID
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
        entity.setValue(model.stationId, forKey: "stationId")
    }
    
    public func recalculateDailyWages(for date: Date) async throws {
        let wageService = WageCalculationService(context: context)

        // Fetch all shifts on the same day
        let sameDayShifts = try await wageService.fetchShiftsOnSameDay(as: date)

        guard !sameDayShifts.isEmpty else { return }

        // Calculate wages considering daily overtime
        let wageCalculations = try await wageService.calculateDailyWagesForShifts(sameDayShifts)

        // Update each shift in Core Data
        try await context.perform {
            for shift in sameDayShifts {
                guard let calculation = wageCalculations[shift.id] else { continue }

                let request = NSFetchRequest<Shift>(entityName: "Shift")
                request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)

                let results = try self.context.fetch(request)

                if let entity = results.first {
                    entity.grossWage = calculation.grossWage
                    entity.netWage = calculation.netWage
                }
            }

            try self.context.save()
        }
    }

    /// Recompute wages for all shifts starting on or after `cutoff`, optionally
    /// scoped to a specific station. Used when a wage rate changes — past
    /// payslips stay frozen, future ones reflect the new rate.
    ///
    /// - Parameters:
    ///   - cutoff: include only shifts with `startTime >= cutoff`.
    ///   - stationFilter: `.any` for all shifts; `.station(id)` for shifts
    ///     linked to that station; `.defaultWage` for shifts with no station.
    public func recalculateShifts(
        from cutoff: Date,
        stationFilter: StationFilter = .any
    ) async throws {
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        switch stationFilter {
        case .any:
            request.predicate = NSPredicate(format: "startTime >= %@", cutoff as NSDate)
        case .defaultWage:
            request.predicate = NSPredicate(format: "startTime >= %@ AND stationId == nil", cutoff as NSDate)
        case .station(let id):
            request.predicate = NSPredicate(
                format: "startTime >= %@ AND stationId == %@",
                cutoff as NSDate, id as CVarArg
            )
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Shift.startTime, ascending: true)]

        let candidates: [ShiftModel] = try await context.perform {
            let entities = try self.context.fetch(request)
            return entities.map { self.mapToModel($0) }
        }
        guard !candidates.isEmpty else { return }

        let calendar = Calendar.current
        let uniqueDays = Set(candidates.map { calendar.startOfDay(for: $0.startTime) })
        for day in uniqueDays {
            try await recalculateDailyWages(for: day)
        }
    }

    public enum StationFilter: Sendable {
        case any
        case defaultWage
        case station(UUID)
    }
}

public enum RepositoryError: Error {
    case notFound
    case saveFailed
    case deleteFailed
} 