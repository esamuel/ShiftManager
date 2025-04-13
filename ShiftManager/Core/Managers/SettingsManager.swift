import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var darkModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        }
    }
    
    private init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
    }
    
    func toggleDarkMode() {
        darkModeEnabled.toggle()
    }
} 