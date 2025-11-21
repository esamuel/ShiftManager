import Foundation

public struct ShiftModel: Identifiable, Codable, Sendable {
    public let id: UUID
    public var title: String
    public var startTime: Date
    public var endTime: Date
    public var notes: String
    public var isOvertime: Bool
    public var isSpecialDay: Bool
    public var category: String
    public var createdAt: Date
    public var grossWage: Double
    public var netWage: Double
    public var username: String
    
    public init(id: UUID = UUID(), 
         title: String = "", 
         category: String = "", 
         startTime: Date = Date(), 
         endTime: Date = Date(), 
         notes: String = "", 
         isOvertime: Bool = false, 
         isSpecialDay: Bool = false, 
         grossWage: Double = 0.0, 
         netWage: Double = 0.0, 
         createdAt: Date = Date(),
         username: String = "") {
        self.id = id
        self.title = title
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.isOvertime = isOvertime
        self.isSpecialDay = isSpecialDay
        self.grossWage = grossWage
        self.netWage = netWage
        self.createdAt = createdAt
        self.username = username
    }
    
    public var duration: TimeInterval {
        if endTime < startTime {
            // If end time is earlier than start time, assume it's the next day
            let calendar = Calendar.current
            let adjustedEndTime = calendar.date(byAdding: .day, value: 1, to: endTime) ?? endTime
            return adjustedEndTime.timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    public var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return String(format: "%dh %dm", hours, minutes)
    }
} 