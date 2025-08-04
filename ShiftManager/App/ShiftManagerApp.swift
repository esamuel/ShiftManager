import SwiftUI

@main
struct ShiftManagerApp: App {
    // Use lazy StateObjects to defer initialization until needed
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    // Defer these initializations until after app has launched
    private var authManager: AuthManager { AuthManager.shared }
    private var shiftManager: ShiftManager { ShiftManager.shared }
    private var settingsManager: SettingsManager { SettingsManager.shared }
    
    // Cache this value instead of accessing UserDefaults on every render
    @State private var isFirstLaunch = UserDefaults.standard.object(forKey: "hasLaunchedBefore") == nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(\.locale, Locale(identifier: localizationManager.currentLanguage))
                    .environmentObject(localizationManager)
                    .environmentObject(themeManager)
                    .environmentObject(authManager)
                    .environmentObject(shiftManager)
                    .environmentObject(settingsManager)
                    .refreshOnLanguageChange()
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                        // Additional UI refresh when language changes
                        refreshUI()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ThemeChanged"))) { _ in
                        // Additional UI refresh when theme changes
                        refreshUI()
                    }
                    .withAppTheme() // Apply app theme
                
                // Show onboarding view on first launch
                if isFirstLaunch {
                    OnboardingView(isShowingOnboarding: $isFirstLaunch)
                        .onDisappear {
                            // Mark that the app has been launched before
                            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        }
                        .transition(.opacity)
                        .withAppTheme() // Apply theme to onboarding as well
                }
            }
        }
    }
    
    // Helper function to refresh the UI
    private func refreshUI() {
        DispatchQueue.main.async {
            if #available(iOS 15.0, *) {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first else { return }
                window.rootViewController?.view.setNeedsLayout()
            } else {
                // Fallback for iOS < 15
                UIApplication.shared.windows.first?.rootViewController?.view.setNeedsLayout()
            }
        }
    }
} 