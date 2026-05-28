import Foundation
@preconcurrency import CoreData

/// One-time migration from the legacy "סייר" note convention to a real
/// Work Station. Detects shifts whose notes contain "סייר", offers to
/// create a matching Station, retroactively links those shifts, and
/// triggers a wage recompute pass for the affected days.
@MainActor
public final class StationMigrationManager: ObservableObject {
    public static let shared = StationMigrationManager()

    private static let completedKey = "stationMigrationCompleted_v1"
    private static let legacyKeyword = "סייר"
    private static let legacyWage = 46.04

    @Published public private(set) var pendingPromptCount: Int = 0
    @Published public var shouldPrompt: Bool = false

    private let context: NSManagedObjectContext
    private let stationRepository: StationRepositoryProtocol

    public init(
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
        stationRepository: StationRepositoryProtocol = StationRepository()
    ) {
        self.context = context
        self.stationRepository = stationRepository
    }

    public var legacyKeyword: String { Self.legacyKeyword }

    public func checkIfPromptNeeded() async {
        guard !UserDefaults.standard.bool(forKey: Self.completedKey) else { return }
        let count = await countLegacyShifts()
        await MainActor.run {
            self.pendingPromptCount = count
            self.shouldPrompt = count > 0
            if count == 0 {
                // Nothing to migrate — never ask again.
                UserDefaults.standard.set(true, forKey: Self.completedKey)
            }
        }
    }

    /// User confirmed — create the Station, link matching shifts, mark done.
    public func performMigration() async {
        let station = StationModel(
            name: Self.legacyKeyword,
            hourlyWage: Self.legacyWage,
            colorHex: "8E7CFF",
            isDefault: false,
            createdAt: Date()
        )
        do {
            try await stationRepository.create(station)
            try await linkLegacyShifts(to: station.id)
            await recomputeAffectedDays()
        } catch {
            print("StationMigrationManager: migration failed — \(error)")
        }
        UserDefaults.standard.set(true, forKey: Self.completedKey)
        await MainActor.run {
            self.shouldPrompt = false
        }
    }

    /// User declined — never ask again.
    public func dismiss() {
        UserDefaults.standard.set(true, forKey: Self.completedKey)
        shouldPrompt = false
    }

    // MARK: - Internals

    private func countLegacyShifts() async -> Int {
        await withCheckedContinuation { continuation in
            context.perform {
                let request = NSFetchRequest<NSManagedObject>(entityName: "Shift")
                request.predicate = NSPredicate(
                    format: "notes CONTAINS[c] %@ AND stationId == nil",
                    Self.legacyKeyword
                )
                let count = (try? self.context.count(for: request)) ?? 0
                continuation.resume(returning: count)
            }
        }
    }

    private func linkLegacyShifts(to stationId: UUID) async throws {
        try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Shift")
            request.predicate = NSPredicate(
                format: "notes CONTAINS[c] %@ AND stationId == nil",
                Self.legacyKeyword
            )
            let results = try self.context.fetch(request)
            for shift in results {
                shift.setValue(stationId, forKey: "stationId")
            }
            try self.context.save()
        }
    }

    private func recomputeAffectedDays() async {
        let calendar = Calendar.current
        let dates: [Date] = await withCheckedContinuation { continuation in
            context.perform {
                let request = NSFetchRequest<NSManagedObject>(entityName: "Shift")
                request.predicate = NSPredicate(format: "notes CONTAINS[c] %@", Self.legacyKeyword)
                let results = (try? self.context.fetch(request)) ?? []
                let startDates = results.compactMap { $0.value(forKey: "startTime") as? Date }
                let unique = Array(Set(startDates.map { calendar.startOfDay(for: $0) }))
                continuation.resume(returning: unique)
            }
        }
        let repo = ShiftRepository(context: context)
        for date in dates {
            try? await repo.recalculateDailyWages(for: date)
        }
    }
}
