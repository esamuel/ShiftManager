import UIKit
import os.log
import ObjectiveC  // Add this for method swizzling

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // OPTIMIZED: Only do essential initialization during app launch
        
        // Initialize swizzling (lightweight operation)
        _ = ForceInitializer.shared
        _ = BackButtonFix.shared
        let _ = UIBarButtonItem.swizzleTitle
        
        // Basic navigation bar appearance (lightweight)
        configureNavigationBarAppearance()
        
        // DEFER heavy operations until after the app has fully launched
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.performDeferredInitialization()
        }
        
        return true
    }
    
    // Perform expensive operations AFTER app has launched
    private func performDeferredInitialization() {
        // Only apply fixes once, not continuously
        LocalizationManager.shared.configureEmptyBackButtonText()
        
        // Register for state changes to reapply fixes when needed
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationStateChanged),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // Add simple navigation bar configuration without the problematic swizzling
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Configure back button to show only the arrow
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        
        // Set default appearance for all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .systemBlue
        
        // Hide back button text with extreme offsets
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            UIOffset(horizontal: -1000, vertical: 0), for: .default)
            
        // Force global appearance override
        let emptyBackButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        emptyBackButtonItem.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        emptyBackButtonItem.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .highlighted)
        
        // Set this as the global default back button
        UINavigationBar.appearance().backItem?.backBarButtonItem = emptyBackButtonItem
        
        // Override back button text with an empty string for all languages
        for _ in ["en", "he", "ru", "es", "fr", "de"] {
            Bundle.main.localizedString(forKey: "Back", value: "", table: nil)
            Bundle.main.localizedString(forKey: "Previous", value: "", table: nil)
            Bundle.main.localizedString(forKey: "back", value: "", table: nil)
            Bundle.main.localizedString(forKey: "חזרה", value: "", table: nil)
            Bundle.main.localizedString(forKey: "חזור", value: "", table: nil)
        }
    }
    
    @objc private func applicationStateChanged() {
        // Apply fixes only once when app becomes active
        applyBackButtonFixes()
    }
    
    private func applyBackButtonFixes() {
        // Clear back button text in all navigation controllers
        clearAllBackButtonText()
    }
    
    private func clearAllBackButtonText() {
        // Clear back button text in all navigation controllers
        if let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
            for scene in windowScenes {
                for window in scene.windows {
                    if let rootVC = window.rootViewController {
                        recursivelyFixBackButtons(in: rootVC)
                    }
                }
            }
        }
    }
    
    private func recursivelyFixBackButtons(in viewController: UIViewController) {
        // Fix this view controller's back button
        viewController.navigationItem.backButtonTitle = ""
        
        // Create an empty back button
        let emptyBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        emptyBackButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        viewController.navigationItem.backBarButtonItem = emptyBackButton
        
        // Handle navigation controller
        if let navController = viewController as? UINavigationController {
            // Fix navigation bar items
            fixNavigationBarItems(navBar: navController.navigationBar)
            
            // Fix all view controllers in the navigation stack
            for childVC in navController.viewControllers {
                recursivelyFixBackButtons(in: childVC)
            }
        }
        
        // Handle child view controllers
        for childVC in viewController.children {
            recursivelyFixBackButtons(in: childVC)
        }
        
        // Handle presented view controller
        if let presentedVC = viewController.presentedViewController {
            recursivelyFixBackButtons(in: presentedVC)
        }
    }
    
    private func fixNavigationBarItems(navBar: UINavigationBar) {
        // Fix back and top items
        navBar.backItem?.backButtonTitle = ""
        navBar.topItem?.backButtonTitle = ""
        
        // Fix all navigation items
        for item in navBar.items ?? [] {
            item.backButtonTitle = ""
            let emptyBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            emptyBackButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
            item.backBarButtonItem = emptyBackButton
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}

// Comment out swizzling logic initialization
// let _ = UINavigationItem.swizzleBackButtonTitleImplementation 
