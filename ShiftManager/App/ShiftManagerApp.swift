import SwiftUI

@main
struct ShiftManagerApp: App {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var shiftManager = ShiftManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: localizationManager.currentLanguage))
                .environmentObject(localizationManager)
                .environmentObject(authManager)
                .environmentObject(shiftManager)
                .environmentObject(settingsManager)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                    // Force UI update when language changes
                    DispatchQueue.main.async {
                        UIApplication.shared.windows.first?.rootViewController?.view.setNeedsLayout()
                    }
                }
        }
    }
} 