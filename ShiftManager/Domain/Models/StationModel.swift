import Foundation

public struct StationModel: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var hourlyWage: Double
    public var colorHex: String?
    public var isDefault: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String = "",
        hourlyWage: Double = 0.0,
        colorHex: String? = nil,
        isDefault: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.hourlyWage = hourlyWage
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
}
