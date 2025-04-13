import Foundation

/// Represents the type of report view to display
public enum ReportViewType: String, CaseIterable {
    /// Daily report view
    case daily = "Daily"
    /// Weekly report view
    case weekly = "Weekly"
    /// Monthly report view
    case monthly = "Monthly"
    /// Yearly report view
    case yearly = "Yearly"
    /// Custom date range report view
    case custom = "Custom"
    
    /// Localized title for the report type
    public var localizedTitle: String {
        switch self {
        case .daily:
            return NSLocalizedString("Daily", comment: "Daily report type")
        case .weekly:
            return NSLocalizedString("Weekly", comment: "Weekly report type")
        case .monthly:
            return NSLocalizedString("Monthly", comment: "Monthly report type")
        case .yearly:
            return NSLocalizedString("Yearly", comment: "Yearly report type")
        case .custom:
            return NSLocalizedString("Custom", comment: "Custom report type")
        }
    }
} 