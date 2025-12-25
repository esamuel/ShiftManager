import Foundation
import CoreData
import Combine

@MainActor
public class FeedbackRepository: ObservableObject {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    /// Save feedback to local storage
    public func saveFeedback(_ feedback: FeedbackModel) throws {
        let feedbackEntity = Feedback(context: context)
        feedbackEntity.id = feedback.id
        feedbackEntity.rating = Int16(feedback.rating)
        feedbackEntity.category = feedback.category.rawValue
        feedbackEntity.comment = feedback.comment
        feedbackEntity.createdAt = feedback.createdAt
        feedbackEntity.isSentViaEmail = feedback.isSentViaEmail
        feedbackEntity.appVersion = feedback.appVersion
        feedbackEntity.deviceModel = feedback.deviceModel
        
        try context.save()
    }
    
    /// Fetch all feedback from local storage
    public func fetchAllFeedback() throws -> [FeedbackModel] {
        let request = NSFetchRequest<Feedback>(entityName: "Feedback")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Feedback.createdAt, ascending: false)]
        
        let feedbackEntities = try context.fetch(request)
        return feedbackEntities.map { entity in
            FeedbackModel(
                id: entity.id ?? UUID(),
                rating: Int(entity.rating),
                category: FeedbackCategory(rawValue: entity.category ?? "") ?? .general,
                comment: entity.comment ?? "",
                createdAt: entity.createdAt ?? Date(),
                isSentViaEmail: entity.isSentViaEmail,
                appVersion: entity.appVersion ?? "",
                deviceModel: entity.deviceModel ?? ""
            )
        }
    }
    
    /// Mark feedback as sent via email
    public func markAsSent(feedbackId: UUID) throws {
        let request = NSFetchRequest<Feedback>(entityName: "Feedback")
        request.predicate = NSPredicate(format: "id == %@", feedbackId as CVarArg)
        
        if let feedback = try context.fetch(request).first {
            feedback.isSentViaEmail = true
            try context.save()
        }
    }
    
    /// Delete feedback
    public func deleteFeedback(feedbackId: UUID) throws {
        let request = NSFetchRequest<Feedback>(entityName: "Feedback")
        request.predicate = NSPredicate(format: "id == %@", feedbackId as CVarArg)
        
        if let feedback = try context.fetch(request).first {
            context.delete(feedback)
            try context.save()
        }
    }
    
    /// Get count of unsent feedback
    public func getUnsentFeedbackCount() throws -> Int {
        let request = NSFetchRequest<Feedback>(entityName: "Feedback")
        request.predicate = NSPredicate(format: "isSentViaEmail == NO")
        return try context.count(for: request)
    }
    
    /// Delete all feedback (for testing/debugging)
    public func deleteAllFeedback() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Feedback")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        try context.save()
    }
}
