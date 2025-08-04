import UIKit
import os.log
import ObjectiveC  // Add this for method swizzling

class AppDelegate: NSObject, UIApplicationDelegate {
    private var appearanceTimer: Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize the ForceInitializer
        _ = ForceInitializer.shared
        
        // Initialize our aggressive back button fix
        _ = BackButtonFix.shared
        
        // Add basic navigation bar appearance configuration
        configureNavigationBarAppearance()
        
        // Keep LocalizationManager as it still exists
        LocalizationManager.shared.configureEmptyBackButtonText()
        
        // Add this line to specifically clear Hebrew back button text
        LocalizationManager.shared.clearHebrewPreviousText()
        
        // Replace all back buttons with custom ones
        BackButtonFix.shared.replaceBackButtonsWithCustom()
        
        // Make sure swizzling is activated (uncomment this)
        let _ = UIBarButtonItem.swizzleTitle
        
        // Set up a timer to periodically check and fix back buttons
        appearanceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.applyBackButtonFixes()
            // Also call this periodically to catch any Hebrew text that appears dynamically
            LocalizationManager.shared.clearHebrewPreviousText()
            // Replace all back buttons with custom ones periodically
            BackButtonFix.shared.replaceBackButtonsWithCustom()
        }
        RunLoop.main.add(appearanceTimer!, forMode: .common)
        
        // Register for application state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationStateChanged),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        return true
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
        // Apply fixes more aggressively when app state changes
        applyBackButtonFixes()
        
        // Replace all back buttons with custom ones
        BackButtonFix.shared.replaceBackButtonsWithCustom()
        
        // Schedule additional fixes for when views may be reloading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.applyBackButtonFixes()
            LocalizationManager.shared.clearHebrewPreviousText()
            BackButtonFix.shared.replaceBackButtonsWithCustom()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.applyBackButtonFixes()
            LocalizationManager.shared.clearHebrewPreviousText()
            BackButtonFix.shared.replaceBackButtonsWithCustom()
        }
    }
    
    private func applyBackButtonFixes() {
        // Apply fixes to remove back button text
        clearAllBackButtonText()
        
        // Also explicitly clear Hebrew text
        LocalizationManager.shared.clearHebrewPreviousText()
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
    
    deinit {
        appearanceTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// Comment out swizzling logic initialization
// let _ = UINavigationItem.swizzleBackButtonTitleImplementation 
