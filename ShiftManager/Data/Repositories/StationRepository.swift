import Foundation
@preconcurrency import CoreData

public protocol StationRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [StationModel]
    func fetch(id: UUID) async throws -> StationModel?
    func create(_ station: StationModel) async throws
    func update(_ station: StationModel) async throws
    func delete(id: UUID) async throws
}

public final class StationRepository: StationRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    public func fetchAll() async throws -> [StationModel] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Station")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        return try await context.perform {
            let stations = try self.context.fetch(request)
            return stations.map { self.mapToModel($0) }
        }
    }

    public func fetch(id: UUID) async throws -> StationModel? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Station")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        return try await context.perform {
            let stations = try self.context.fetch(request)
            return stations.first.map { self.mapToModel($0) }
        }
    }

    public func create(_ station: StationModel) async throws {
        try await context.perform {
            guard let entity = NSEntityDescription.entity(forEntityName: "Station", in: self.context) else {
                throw RepositoryError.saveFailed
            }
            let object = NSManagedObject(entity: entity, insertInto: self.context)
            self.mapToEntity(station, entity: object)
            try self.context.save()
        }
    }

    public func update(_ station: StationModel) async throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Station")
        request.predicate = NSPredicate(format: "id == %@", station.id as CVarArg)

        try await context.perform {
            let results = try self.context.fetch(request)
            guard let entity = results.first else {
                throw RepositoryError.notFound
            }
            self.mapToEntity(station, entity: entity)
            try self.context.save()
        }
    }

    public func delete(id: UUID) async throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Station")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        try await context.perform {
            let results = try self.context.fetch(request)
            guard let entity = results.first else {
                throw RepositoryError.notFound
            }
            self.context.delete(entity)
            try self.context.save()
        }
    }

    private func mapToModel(_ entity: NSManagedObject) -> StationModel {
        StationModel(
            id: entity.value(forKey: "id") as? UUID ?? UUID(),
            name: entity.value(forKey: "name") as? String ?? "",
            hourlyWage: entity.value(forKey: "hourlyWage") as? Double ?? 0.0,
            colorHex: entity.value(forKey: "colorHex") as? String,
            isDefault: entity.value(forKey: "isDefault") as? Bool ?? false,
            createdAt: entity.value(forKey: "createdAt") as? Date ?? Date()
        )
    }

    private func mapToEntity(_ model: StationModel, entity: NSManagedObject) {
        entity.setValue(model.id, forKey: "id")
        entity.setValue(model.name, forKey: "name")
        entity.setValue(model.hourlyWage, forKey: "hourlyWage")
        entity.setValue(model.colorHex, forKey: "colorHex")
        entity.setValue(model.isDefault, forKey: "isDefault")
        entity.setValue(model.createdAt, forKey: "createdAt")
    }
}
