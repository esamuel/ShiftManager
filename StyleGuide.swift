import UIKit

struct StyleGuide {
    // Spacing constants
    static let smallSpacing: CGFloat = 8.0
    static let mediumSpacing: CGFloat = 16.0
    static let largeSpacing: CGFloat = 24.0

    // Font constants using system fonts
    static var titleFont: UIFont { .systemFont(ofSize: 20, weight: .semibold) }
    static var bodyFont: UIFont { .systemFont(ofSize: 16, weight: .regular) }
    static var captionFont: UIFont { .systemFont(ofSize: 12, weight: .regular) }

    // Color palette with dark mode support
    static var primaryText: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }
    }

    static var secondaryText: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor.darkGray
        }
    }

    static var background: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
    }

    static var accent: UIColor {
        return UIColor.systemBlue
    }
    
    // Configure navigation bar with symbol-only back button (no text)
    static func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Configure back button to show only the arrow without text
        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left"), transitionMaskImage: UIImage(systemName: "chevron.left"))
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // This removes the back button text across the app
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
    }
} 