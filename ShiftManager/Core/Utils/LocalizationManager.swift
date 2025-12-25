import Foundation
import Combine
import SwiftUI

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
    func clearHebrewPreviousText() {
        // Disabled for performance reasons.
        // The recursive view hierarchy traversal was causing significant startup delays.
    }
}


struct AppLanguage {
    let code: String
    let name: String
}

// MARK: - View Extension for Language Refresh
extension View {
    func refreshOnLanguageChange() -> some View {
        LanguageRefreshWrapper(content: self)
    }
}

struct LanguageRefreshWrapper<Content: View>: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let content: Content
    
    var body: some View {
        content
            .id(localizationManager.refreshID)
    }
}


