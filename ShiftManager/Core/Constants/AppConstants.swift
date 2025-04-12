import Foundation

enum AppConstants {
    enum UserDefaults {
        static let settingsKey = "appSettings"
        static let pdfConfigKey = "pdfConfig"
    }
    
    enum Time {
        static let secondsInHour: TimeInterval = 3600
        static let secondsInMinute: TimeInterval = 60
    }
    
    enum UI {
        static let defaultAnimationDuration: TimeInterval = 0.3
        static let defaultCornerRadius: CGFloat = 8.0
    }
    
    enum File {
        static let exportDirectory = "ShiftManagerExports"
        static let pdfExtension = "pdf"
        static let csvExtension = "csv"
    }
} 