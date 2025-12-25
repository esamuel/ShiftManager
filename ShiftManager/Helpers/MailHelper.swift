import SwiftUI
import MessageUI

/// A UIViewControllerRepresentable wrapper for MFMailComposeViewController
public struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    let recipients: [String]
    let subject: String
    let body: String
    let onComplete: (Result<MFMailComposeResult, Error>) -> Void
    
    public init(
        recipients: [String],
        subject: String,
        body: String,
        onComplete: @escaping (Result<MFMailComposeResult, Error>) -> Void
    ) {
        self.recipients = recipients
        self.subject = subject
        self.body = body
        self.onComplete = onComplete
    }
    
    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(recipients)
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(body, isHTML: false)
        return mailComposer
    }
    
    public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        public func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            if let error = error {
                parent.onComplete(.failure(error))
            } else {
                parent.onComplete(.success(result))
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

/// Helper to check if mail services are available
public struct MailHelper {
    public static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    public static func openMailApp(to recipient: String, subject: String, body: String) {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(recipient)?subject=\(encodedSubject)&body=\(encodedBody)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
