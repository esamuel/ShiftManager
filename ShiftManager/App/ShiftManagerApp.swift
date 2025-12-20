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
} 