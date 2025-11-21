import Foundation
import Combine
import SwiftUI
import ObjectiveC

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            // Generate a new ID to force view refreshes
            refreshID = UUID()
            
            // Update UI direction for RTL languages
            updateUIDirection()
            
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }
    
    @Published var currentCountry: Country {
        didSet {
            UserDefaults.standard.set(currentCountry.rawValue, forKey: "country")
            NotificationCenter.default.post(name: NSNotification.Name("CountryChanged"), object: nil)
        }
    }
    
    // Published property that changes whenever language changes
    @Published var refreshID = UUID()
    
    var currencySymbol: String {
        return currentCountry.currencySymbol
    }
    
    private let isFirstLaunchKey = "isFirstLaunch"
    
    private init() {
        // Load language and country synchronously - this is fast
        
        // Check if it's the first launch - use a direct access without synchronize for speed
        if !UserDefaults.standard.bool(forKey: isFirstLaunchKey) {
            // First launch - use device language
            let deviceLanguage = Locale.current.languageCode ?? "en"
            self.currentLanguage = deviceLanguage
            
            // Batch UserDefaults operations
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: isFirstLaunchKey)
            defaults.set(deviceLanguage, forKey: "selectedLanguage")
        } else {
            // Not first launch - use saved language or default to English
            self.currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        }
        
        // Initialize current country
        let countryString = UserDefaults.standard.string(forKey: "country") ?? "israel"
        self.currentCountry = Country(rawValue: countryString) ?? .israel
        
        // Set UI direction immediately - this is a lightweight operation
        updateUIDirection()
    }
    
    private func updateUIDirection() {
        // Set semantic content attribute for RTL languages
        let isRTL = currentLanguage == "he" || currentLanguage == "ar"
        
        // Set global appearance - this is very fast
        if isRTL {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        // Only traverse windows if they exist (not during initial app launch)
        // This defers the expensive operation until after the app has launched
        if UIApplication.shared.connectedScenes.isEmpty {
            return
        }
        
        // Update existing windows
        if let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
            for scene in windowScenes {
                for window in scene.windows {
                    window.rootViewController?.view.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
                }
            }
        }
    }
    
    func localizedString(for key: String) -> String {
        let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj")
        let bundle = path != nil ? Bundle(path: path!) : Bundle.main
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
    
    func availableLanguages() -> [AppLanguage] {
        return [
            AppLanguage(code: "en", name: "English"),
            AppLanguage(code: "he", name: "עברית"),
            AppLanguage(code: "ru", name: "Русский"),
            AppLanguage(code: "es", name: "Español"),
            AppLanguage(code: "fr", name: "Français"),
            AppLanguage(code: "de", name: "Deutsch")
        ]
    }
    
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    func setCountry(_ country: Country) {
        currentCountry = country
    }
    
    func resetToDeviceLanguage() {
        let deviceLanguage = Locale.current.languageCode ?? "en"
        setLanguage(deviceLanguage)
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currentCountry.currencySymbol
        formatter.locale = Locale(identifier: currentLanguage)
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currentCountry.currencySymbol)\(amount)"
    }
    
    // This ensures the back button text is properly localized
    func configureEmptyBackButtonText() {
        // Force clear back button text in all navigation controllers
        if let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
            for scene in windowScenes {
                for window in scene.windows {
                    if let rootVC = window.rootViewController {
                        recursivelyClearBackButtonText(in: rootVC)
                    }
                }
            }
        }
    }
    
    private func recursivelyClearBackButtonText(in viewController: UIViewController) {
        // Set empty back button title
        viewController.navigationItem.backButtonTitle = ""
        
        // Handle navigation controller
        if let navController = viewController as? UINavigationController {
            // Clear all navigation items
            for item in navController.navigationBar.items ?? [] {
                item.backButtonTitle = ""
            }
            
            // Process all view controllers in the stack
            for childVC in navController.viewControllers {
                recursivelyClearBackButtonText(in: childVC)
            }
        }
        
        // Handle child view controllers
        for childVC in viewController.children {
            recursivelyClearBackButtonText(in: childVC)
        }
    }
    
    // Direct override to find and replace the Hebrew text in any UI elements
    // Direct override to find and replace the Hebrew text in any UI elements
    func clearHebrewPreviousText() {
        // Disabled for performance reasons.
        // The recursive view hierarchy traversal was causing significant startup delays.
    }
    
    private func recursivelyRemoveBackButtonText(in viewController: UIViewController) {
        // Apply to this view controller
        viewController.navigationItem.backButtonTitle = ""
        
        // Create empty back button
        let emptyBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = emptyBackButton
        
        // If it's a navigation controller, apply to all child view controllers
        if let navController = viewController as? UINavigationController {
            for childVC in navController.viewControllers {
                recursivelyRemoveBackButtonText(in: childVC)
            }
            
            // Force empty back button title in navigation bar
            navController.navigationBar.backItem?.backButtonTitle = ""
            navController.navigationBar.topItem?.backButtonTitle = ""
            
            // Force clear all buttons
            for item in navController.navigationBar.items ?? [] {
                item.backButtonTitle = ""
                item.backBarButtonItem = emptyBackButton
            }
        }
        
        // Apply to presented view controller
        if let presentedVC = viewController.presentedViewController {
            recursivelyRemoveBackButtonText(in: presentedVC)
        }
        
        // Apply to child view controllers
        for childVC in viewController.children {
            recursivelyRemoveBackButtonText(in: childVC)
        }
    }
    
    private func recursivelySearchAndClearText(views: [UIView]) {
        for view in views {
            // Special handling for navigation bar
            if let navigationBar = view as? UINavigationBar {
                // Clear all text in navigation items
                navigationBar.backItem?.backButtonTitle = ""
                navigationBar.topItem?.backButtonTitle = ""
                
                // Set empty back button for all items
                for item in navigationBar.items ?? [] {
                    item.backButtonTitle = ""
                    item.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                }
                
                // Find and clear any text in navigation bar subviews
                clearNavigationBarText(navigationBar)
            }
            
            // Check labels
            if let label = view as? UILabel {
                if label.text == "חזרה" || label.text == "Back" || label.text == "Previous" || label.text == "Back" {
                    label.text = ""
                    label.isHidden = true
                    label.alpha = 0
                }
            }
            
            // Check buttons
            if let button = view as? UIButton {
                let titles = ["Back", "Previous", "Back", "חזרה", "חזור"]
                for state: UIControl.State in [.normal, .highlighted, .selected] {
                    if let title = button.title(for: state), titles.contains(title) {
                        button.setTitle("", for: state)
                    }
                }
            }
            
            // Recursively search subviews
            self.recursivelySearchAndClearText(views: view.subviews)
        }
    }
    
    private func clearNavigationBarText(_ navigationBar: UINavigationBar) {
        for subview in navigationBar.subviews {
            clearBackButtonTextRecursively(in: subview)
        }
    }
    
    private func clearBackButtonTextRecursively(in view: UIView) {
        // Check labels
        if let label = view as? UILabel {
            if label.text == "חזרה" || label.text == "Back" || label.text == "Previous" || label.text == "Back" {
                label.text = ""
                label.isHidden = true
                label.alpha = 0
            }
        }
        
        // Check buttons
        if let button = view as? UIButton {
            let titles = ["Back", "Previous", "Back", "חזרה", "חזור"]
            for state: UIControl.State in [.normal, .highlighted, .selected] {
                if let title = button.title(for: state), titles.contains(title) {
                    button.setTitle("", for: state)
                }
            }
        }
        
        // Recursively search in subviews
        for subview in view.subviews {
            clearBackButtonTextRecursively(in: subview)
        }
    }
    
    // Added method to find and fix navigation controllers more aggressively
    private func forceFixNavigationControllers() {
        if let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
            for scene in windowScenes {
                for window in scene.windows {
                    findAndFixNavigationControllers(in: window.rootViewController)
                }
            }
        }
    }
    
    private func findAndFixNavigationControllers(in viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        
        // If this is a navigation controller, fix it directly
        if let navController = viewController as? UINavigationController {
            // Fix navigation bar
            navController.navigationBar.backItem?.backButtonTitle = ""
            navController.navigationBar.topItem?.backButtonTitle = ""
            
            // Set appearance for this navigation controller specifically
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            
            // Configure back button to show only the arrow
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            let backImage = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            
            // Apply to this navigation controller
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.compactAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            
            // Fix all items in the navigation bar
            for item in navController.navigationBar.items ?? [] {
                item.backButtonTitle = ""
                let emptyBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                emptyBackButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
                item.backBarButtonItem = emptyBackButton
            }
            
            // Fix all view controllers in this navigation controller
            for childVC in navController.viewControllers {
                childVC.navigationItem.backButtonTitle = ""
                let emptyBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                emptyBackButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
                childVC.navigationItem.backBarButtonItem = emptyBackButton
                
                // Continue recursion
                findAndFixNavigationControllers(in: childVC)
            }
        }
        
        // Check child view controllers
        for childVC in viewController.children {
            findAndFixNavigationControllers(in: childVC)
        }
        
        // Check presented view controller
        findAndFixNavigationControllers(in: viewController.presentedViewController)
    }
}

struct AppLanguage {
    let code: String
    let name: String
}

// MARK: - View Extension for Language Refresh
extension View {
    func refreshOnLanguageChange() -> some View {
        self.id(LocalizationManager.shared.refreshID)
    }
}

// MARK: - UIViewController Extension for Method Swizzling at App Launch
extension UIViewController {
    static let swizzleImplementation: Void = {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(UIViewController.swizzled_viewWillAppear(_:))
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()
    
    class func swizzleViewWillAppear() {
        _ = swizzleImplementation
    }
    
    @objc func swizzled_viewWillAppear(_ animated: Bool) {
        swizzled_viewWillAppear(animated) // Call original implementation
        
        // Set empty back button title
        self.navigationItem.backButtonTitle = ""
    }
}

// Mark - Force UIKIt to swizzle when the class is loaded
@objc class ForceInitializer: NSObject {
    @objc static let shared = ForceInitializer()
    
    override init() {
        super.init()
        UIViewController.swizzleViewWillAppear()
    }
}

// This ensures the ForceInitializer is initialized when the app starts
private let initializeOnce: () = {
    _ = ForceInitializer.shared
}() 
