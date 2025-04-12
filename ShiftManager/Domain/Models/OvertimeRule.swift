import Foundation

struct OvertimeRuleModel: Identifiable {
    let id: UUID
    var name: String
    var threshold: TimeInterval
    var multiplier: Double
    var isEnabled: Bool
    
    init(id: UUID = UUID(), name: String, threshold: TimeInterval, multiplier: Double, isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.threshold = threshold
        self.multiplier = multiplier
        self.isEnabled = isEnabled
    }
} 