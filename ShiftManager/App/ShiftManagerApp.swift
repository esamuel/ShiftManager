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
                .refreshOnLanguageChange()
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                    // Additional UI refresh when language changes
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
    }
} 