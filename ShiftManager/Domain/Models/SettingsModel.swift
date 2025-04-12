import Foundation

struct SettingsModel: Identifiable, Codable {
    let id: UUID
    var username: String?
    var defaultShiftDuration: Double
    var theme: String
    var language: String
    
    init(id: UUID = UUID(),
         username: String? = nil,
         defaultShiftDuration: Double = 28800.0, // 8 hours in seconds
         theme: String = "system",
         language: String = "en") {
        self.id = id
        self.username = username
        self.defaultShiftDuration = defaultShiftDuration
        self.theme = theme
        self.language = language
    }
    
    var formattedDefaultDuration: String {
        let hours = Int(defaultShiftDuration) / 3600
        let minutes = Int(defaultShiftDuration) / 60 % 60
        return String(format: "%dh %dm", hours, minutes)
    }
} 