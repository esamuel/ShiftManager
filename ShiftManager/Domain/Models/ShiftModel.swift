import Foundation

struct ShiftModel: Identifiable, Codable {
    let id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var notes: String
    var isOvertime: Bool
    var isSpecialDay: Bool
    var category: String?
    var createdAt: Date
    var grossWage: Double
    var netWage: Double
    
    init(id: UUID = UUID(), 
         title: String, 
         startTime: Date, 
         endTime: Date, 
         notes: String = "", 
         isOvertime: Bool = false,
         isSpecialDay: Bool = false,
         category: String? = nil, 
         createdAt: Date = Date(),
         grossWage: Double = 0.0,
         netWage: Double = 0.0) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.isOvertime = isOvertime
        self.isSpecialDay = isSpecialDay
        self.category = category
        self.createdAt = createdAt
        self.grossWage = grossWage
        self.netWage = netWage
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return String(format: "%dh %dm", hours, minutes)
    }
} 