import Foundation

public enum FeedbackCategory: String, CaseIterable, Identifiable, Codable {
    case general, usability, features, bugs, suggestions
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .general: return "General".localized
        case .usability: return "Usability".localized
        case .features: return "Features".localized
        case .bugs: return "Bug Report".localized
        case .suggestions: return "Suggestions".localized
        }
    }
}

public struct FeedbackModel: Identifiable, Codable {
    public let id: UUID
    public let rating: Int
    public let category: FeedbackCategory
    public let comment: String
    public let createdAt: Date
    public var isSentViaEmail: Bool
    public let appVersion: String
    public let deviceModel: String
    
    public init(
        id: UUID = UUID(),
        rating: Int,
        category: FeedbackCategory,
        comment: String,
        createdAt: Date = Date(),
        isSentViaEmail: Bool = false,
        appVersion: String = "",
        deviceModel: String = ""
    ) {
        self.id = id
        self.rating = rating
        self.category = category
        self.comment = comment
        self.createdAt = createdAt
        self.isSentViaEmail = isSentViaEmail
        self.appVersion = appVersion
        self.deviceModel = deviceModel
    }
    
    /// Formatted email body for sending feedback
    public var emailBody: String {
        """
        Feedback Details
        ================
        
        Rating: \(String(repeating: "⭐️", count: rating))
        Category: \(category.displayName)
        Date: \(createdAt.formatted(date: .long, time: .shortened))
        
        App Version: \(appVersion)
        Device: \(deviceModel)
        
        Comments:
        ---------
        \(comment)
        
        ================
        Feedback ID: \(id.uuidString)
        """
    }
}
