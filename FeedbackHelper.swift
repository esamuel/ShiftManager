import UIKit

struct FeedbackHelper {
    // Haptic feedback generators
    private static let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private static let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    // Prepares feedback generators (call this e.g., in viewDidLoad)
    static func prepareFeedback() {
        selectionFeedbackGenerator.prepare()
        impactFeedbackGenerator.prepare()
    }

    // Trigger selection haptic feedback
    static func playSelectionFeedback() {
        selectionFeedbackGenerator.selectionChanged()
    }

    // Trigger impact haptic feedback
    static func playImpactFeedback() {
        impactFeedbackGenerator.impactOccurred()
    }

    // Animate a view for a button press with a subtle shrink and bounce back effect
    static func animateButtonPress(_ view: UIView) {
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        }
    }

    // Smooth view transition helper using a fade animation
    static func transition(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        toVC.view.alpha = 0
        container.addSubview(toVC.view)
        UIView.animate(withDuration: duration, animations: {
            toVC.view.alpha = 1
            fromVC.view.alpha = 0
        }, completion: { _ in
            fromVC.view.alpha = 1 // Restore in case it's needed for reuse
            completion?()
        })
    }
} 