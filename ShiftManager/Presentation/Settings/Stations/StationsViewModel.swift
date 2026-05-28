import Foundation
import SwiftUI

@MainActor
public final class StationsViewModel: ObservableObject {
    @Published public private(set) var stations: [StationModel] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    private let repository: StationRepositoryProtocol

    public init(repository: StationRepositoryProtocol = StationRepository()) {
        self.repository = repository
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            stations = try await repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func create(name: String, hourlyWage: Double, colorHex: String?) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let station = StationModel(
            name: trimmed,
            hourlyWage: hourlyWage,
            colorHex: colorHex,
            isDefault: false,
            createdAt: Date()
        )
        do {
            try await repository.create(station)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func update(_ station: StationModel) async {
        do {
            try await repository.update(station)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func delete(at offsets: IndexSet) async {
        let toDelete = offsets.map { stations[$0] }
        for station in toDelete {
            do {
                try await repository.delete(id: station.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        await load()
    }
}
