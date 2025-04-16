import UIKit
import ObjectiveC

// This class focuses specifically on fixing the Hebrew back button text issue
// It uses a combination of approaches to ensure the text doesn't appear
class BackButtonFix {
    static let shared = BackButtonFix()
    
    private init() {
        // Initialize the fixes immediately
        applyAllFixes()
    }
    
    func applyAllFixes() {
        // Apply swizzling to UILabel to prevent displaying specific text
        swizzleUILabelText()
        
        // Apply swizzling to UINavigationItem's back button title setter
        swizzleNavigationItemBackButtonTitle()
        
        // Apply swizzling to UIBarButtonItem's setTitleTextAttributes method
        swizzleBarButtonItemSetTitleTextAttributes()
        
        // Apply swizzling to NSBundle's localizedString method
        swizzleNSBundleLocalizedString()
        
        // Apply fixes to current UI
        DispatchQueue.main.async { [weak self] in
            self?.clearExistingBackButtonText()
        }
        
        // Schedule periodic checks
        startPeriodicChecks()
    }
    
    // MARK: - UILabel Text Swizzling
    // This swizzles UILabel's text property to prevent the problematic text
    private func swizzleUILabelText() {
        let originalSelector = #selector(setter: UILabel.text)
        let swizzledSelector = #selector(UILabel.swizzled_setText(_:))
        
        guard let originalMethod = class_getInstanceMethod(UILabel.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UILabel.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    // MARK: - UINavigationItem Back Button Title Swizzling
    private func swizzleNavigationItemBackButtonTitle() {
        let originalSelector = #selector(setter: UINavigationItem.backButtonTitle)
        let swizzledSelector = #selector(UINavigationItem.swizzled_setBackButtonTitle(_:))
        
        guard let originalMethod = class_getInstanceMethod(UINavigationItem.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UINavigationItem.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    // MARK: - UIBarButtonItem Swizzling
    private func swizzleBarButtonItemSetTitleTextAttributes() {
        let originalSelector = #selector(UIBarButtonItem.setTitleTextAttributes(_:for:))
        let swizzledSelector = #selector(UIBarButtonItem.swizzled_setTitleTextAttributes(_:for:))
        
        guard let originalMethod = class_getInstanceMethod(UIBarButtonItem.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIBarButtonItem.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    // MARK: - NSBundle Localization Swizzling
    // This swizzles the system's localization method to intercept back button text
    private func swizzleNSBundleLocalizedString() {
        let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
        let swizzledSelector = #selector(Bundle.swizzled_localizedString(forKey:value:table:))
        
        guard let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    // MARK: - Direct UI Manipulation
    // This function searches the entire UI hierarchy and clears any back button text
    private func clearExistingBackButtonText() {
        // First check all navigation bars
        if let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
            for scene in windowScenes {
                for window in scene.windows {
                    // Clear text in all navigation bars
                    self.recursivelySearchForNavigationBars(in: window)
                    
                    // Clear text in view controllers
                    if let rootVC = window.rootViewController {
                        self.recursivelyFixViewControllers(rootVC)
                    }
                }
            }
        }
    }
    
    private func recursivelySearchForNavigationBars(in view: UIView) {
        // If this is a navigation bar, clear all its text
        if let navBar = view as? UINavigationBar {
            clearNavigationBarText(navBar)
        }
        
        // Check for any labels with the problematic text
        if let label = view as? UILabel {
            clearLabelIfNeeded(label)
        }
        
        // Check all subviews
        for subview in view.subviews {
            recursivelySearchForNavigationBars(in: subview)
        }
    }
    
    private func clearNavigationBarText(_ navBar: UINavigationBar) {
        // Clear back and top items
        navBar.backItem?.backButtonTitle = ""
        navBar.topItem?.backButtonTitle = ""
        
        // Set custom empty back button for all items
        for item in navBar.items ?? [] {
            item.backButtonTitle = ""
            let emptyBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            emptyBackButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
            item.backBarButtonItem = emptyBackButton
        }
        
        // Check for labels in the navigation bar's view hierarchy
        for subview in navBar.subviews {
            recursivelySearchForLabels(in: subview)
        }
    }
    
    private func recursivelySearchForLabels(in view: UIView) {
        if let label = view as? UILabel {
            clearLabelIfNeeded(label)
        }
        
        for subview in view.subviews {
            recursivelySearchForLabels(in: subview)
        }
    }
    
    private func clearLabelIfNeeded(_ label: UILabel) {
        let backTexts = ["Back", "חזרה", "חזור", "Back", "Previous", "back", "הקודם"]
        
        if let text = label.text {
            if backTexts.contains(text) || text.containsHebrewCharacters() || text.isBackButtonText() {
                label.text = ""
                label.isHidden = true
                label.alpha = 0
            }
        }
    }
    
    private func recursivelyFixViewControllers(_ viewController: UIViewController) {
        // Fix this view controller's back button
        viewController.navigationItem.backButtonTitle = ""
        
        // Create empty back button
        let emptyBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        emptyBackButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        viewController.navigationItem.backBarButtonItem = emptyBackButton
        
        // Handle navigation controller
        if let navController = viewController as? UINavigationController {
            // Fix all view controllers in the stack
            for childVC in navController.viewControllers {
                recursivelyFixViewControllers(childVC)
            }
        }
        
        // Handle child view controllers
        for childVC in viewController.children {
            recursivelyFixViewControllers(childVC)
        }
        
        // Handle presented view controller
        if let presentedVC = viewController.presentedViewController {
            recursivelyFixViewControllers(presentedVC)
        }
    }
    
    // MARK: - Periodic Checks
    private var checkTimer: Timer?
    
    private func startPeriodicChecks() {
        // Stop any existing timer
        checkTimer?.invalidate()
        
        // Create a new timer that runs every 0.25 seconds
        checkTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.clearExistingBackButtonText()
        }
        
        // Add to common run loops
        if let timer = checkTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    // MARK: - Complete Back Button Replacement
    // This extreme technique replaces every back button in the app with a custom one
    func replaceBackButtonsWithCustom() {
        // Find all navigation controllers
        if let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
            for scene in windowScenes {
                for window in scene.windows {
                    if let rootVC = window.rootViewController {
                        recursivelyReplaceBackButtons(in: rootVC)
                    }
                }
            }
        }
    }
    
    private func recursivelyReplaceBackButtons(in viewController: UIViewController) {
        // Create a custom back button using only an image
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)
        
        // Create a new back button without any text
        let customBackButton = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: nil,
            action: nil
        )
        
        // Set it as the back button
        viewController.navigationItem.backBarButtonItem = customBackButton
        viewController.navigationItem.backButtonTitle = ""
        
        // If it's a navigation controller, do the same for all view controllers
        if let navController = viewController as? UINavigationController {
            for childVC in navController.viewControllers {
                recursivelyReplaceBackButtons(in: childVC)
            }
            
            // Force custom back button image in the nav bar
            let appearance = navController.navigationBar.standardAppearance
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            navController.navigationBar.compactAppearance = appearance
        }
        
        // Process child view controllers
        for childVC in viewController.children {
            recursivelyReplaceBackButtons(in: childVC)
        }
        
        // Process presented view controller
        if let presentedVC = viewController.presentedViewController {
            recursivelyReplaceBackButtons(in: presentedVC)
        }
    }
}

// MARK: - UILabel Extension
extension UILabel {
    @objc func swizzled_setText(_ text: String?) {
        let backTexts = ["Back", "חזרה", "חזור", "Back", "Previous", "back"]
        
        if let newText = text, (backTexts.contains(newText) || newText.containsHebrewCharacters()) {
            // Don't set problematic text, set empty string instead
            self.swizzled_setText("")
            self.isHidden = true
            self.alpha = 0
        } else {
            // Set the text normally
            self.swizzled_setText(text)
        }
    }
}

// MARK: - UINavigationItem Extension
extension UINavigationItem {
    @objc func swizzled_setBackButtonTitle(_ title: String?) {
        // Always set to empty string regardless of what's being set
        self.swizzled_setBackButtonTitle("")
    }
}

// MARK: - UIBarButtonItem Extension
extension UIBarButtonItem {
    @objc func swizzled_setTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any]?, for state: UIControl.State) {
        // Create a modified attributes dictionary that forces text color to be clear
        var modifiedAttributes = attributes ?? [:]
        modifiedAttributes[.foregroundColor] = UIColor.clear
        modifiedAttributes[.font] = UIFont.systemFont(ofSize: 0.1) // Extremely small font
        
        // Call the original method with our modified attributes
        self.swizzled_setTitleTextAttributes(modifiedAttributes, for: state)
    }
    
    // Additional hack to remove back button text
    static let swizzleTitle: Void = {
        let originalSetTitleSelector = #selector(setter: UIBarButtonItem.title)
        let swizzledSetTitleSelector = #selector(UIBarButtonItem.swizzled_setTitle(_:))
        
        guard let originalMethod = class_getInstanceMethod(UIBarButtonItem.self, originalSetTitleSelector),
              let swizzledMethod = class_getInstanceMethod(UIBarButtonItem.self, swizzledSetTitleSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()
    
    @objc func swizzled_setTitle(_ title: String?) {
        // Detect if this is a back button text
        let backTexts = ["Back", "חזרה", "חזור", "Back", "Previous", "back", "הקודם"]
        
        if let newTitle = title, backTexts.contains(newTitle) || newTitle.containsHebrewCharacters() {
            // For back buttons, set empty title
            self.swizzled_setTitle("")
        } else {
            // For other buttons, set the original title
            self.swizzled_setTitle(title)
        }
    }
}

// MARK: - NSBundle Extension
extension Bundle {
    @objc func swizzled_localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // Call original implementation
        let originalString = self.swizzled_localizedString(forKey: key, value: value, table: tableName)
        
        // Comprehensive list of back button related keys in various languages
        let backButtonKeys = [
            "Back", "back", "Back-Button", "Previous", "previous",
            "חזרה", "חזור", "הקודם",
            "Назад", // Russian
            "Atrás", "Volver", // Spanish
            "Retour", // French
            "Zurück"  // German
        ]
        
        // Check if the key directly matches any known back button text
        if backButtonKeys.contains(key) || key.lowercased().contains("back") {
            return ""
        }
        
        // Check common patterns in localization keys
        if key.contains("navigation.back") || key.contains("nav.back") || 
           key.contains("button.back") || key.contains("btn.back") {
            return ""
        }
        
        // Check if the resulting string contains back button text in any language
        for backText in backButtonKeys {
            if originalString.contains(backText) {
                return ""
            }
        }
        
        // Additional check for Hebrew text
        if originalString.containsHebrewCharacters() {
            // If the string is very short (likely just the back text) and contains Hebrew
            if originalString.count < 10 {
                return ""
            }
        }
        
        return originalString
    }
}

// Initialize the UIBarButtonItem title swizzling when this file is loaded
private let initializeBarButtonItemSwizzling: Void = {
    _ = UIBarButtonItem.swizzleTitle
}() 