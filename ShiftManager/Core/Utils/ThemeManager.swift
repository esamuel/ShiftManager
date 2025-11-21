import Foundation
import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "theme")
            // Generate a new ID to force view refreshes
            refreshID = UUID()
            NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
        }
    }
    
    // Published property that changes whenever theme changes
    @Published var refreshID = UUID()
    
    private init() {
        // Use saved theme or default to system
        let themeString = UserDefaults.standard.string(forKey: "theme") ?? "system"
        self.currentTheme = Theme(rawValue: themeString) ?? .system
    }
    
    func setTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    var colorScheme: ColorScheme? {
        return currentTheme.colorScheme
    }
}

// MARK: - View Extension for Theme Support
extension View {
    func withAppTheme() -> some View {
        return self.preferredColorScheme(ThemeManager.shared.colorScheme)
    }
} 