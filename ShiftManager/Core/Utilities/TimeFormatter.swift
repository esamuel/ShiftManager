import Foundation

class TimeFormatter {
    static func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
    
    static func formatHours(_ hours: Double) -> String {
        return String(format: "%.2f", hours)
    }
    
    static func calculateEarnings(hours: Double, rate: Double) -> Double {
        return hours * rate
    }
} 