import Foundation
import SwiftUI

public enum Theme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    public var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System".localized
        case .light: return "Light".localized
        case .dark: return "Dark".localized
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

public enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case hebrew = "he"
    case russian = "ru"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    
    public var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .hebrew: return "עברית"
        case .russian: return "Русский"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
}

public enum Country: String, CaseIterable, Identifiable {
    case usa
    case uk
    case eu
    case israel
    case russia
    
    public var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .usa: return "United States (USD)"
        case .uk: return "United Kingdom (GBP)"
        case .eu: return "European Union (EUR)"
        case .israel: return "Israel (ILS)"
        case .russia: return "Russia (RUB)"
        }
    }
    
    var currencyCode: String {
        switch self {
        case .usa: return "USD"
        case .uk: return "GBP"
        case .eu: return "EUR"
        case .israel: return "ILS"
        case .russia: return "RUB"
        }
    }
    
    var currencySymbol: String {
        switch self {
        case .usa: return "$"
        case .uk: return "£"
        case .eu: return "€"
        case .israel: return "₪"
        case .russia: return "₽"
        }
    }
}

public class SettingsViewModel: ObservableObject {
    @Published var username: String
    @Published var hourlyWage: Double
    @Published var taxDeduction: Double
    @Published var baseHoursWeekday: Int
    @Published var baseHoursSpecialDay: Int
    @Published var startWorkOnSunday: Bool {
        didSet {
            saveSettings()
        }
    }
    @Published var selectedLanguage: Language
    @Published var selectedCountry: Country
    @Published var selectedTheme: Theme
    @Published var showingSaveConfirmation = false
    @Published var showingLanguagePicker = false
    @Published var showSetupReminder = false
    @Published var showingShareSheet = false
    
    // App version property
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "1.0"
    }
    
    public init() {
        // Load saved values or use defaults
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.hourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
        self.taxDeduction = UserDefaults.standard.double(forKey: "taxDeduction")
        self.baseHoursWeekday = UserDefaults.standard.integer(forKey: "baseHoursWeekday")
        self.baseHoursSpecialDay = UserDefaults.standard.integer(forKey: "baseHoursSpecialDay")
        self.startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        
        // Initialize language from LocalizationManager
        let savedLanguage = LocalizationManager.shared.currentLanguage
        self.selectedLanguage = Language(rawValue: savedLanguage) ?? .english
        
        self.selectedCountry = Country(rawValue: UserDefaults.standard.string(forKey: "country") ?? "israel") ?? .israel
        
        // Initialize theme
        let savedTheme = UserDefaults.standard.string(forKey: "theme") ?? "system"
        self.selectedTheme = Theme(rawValue: savedTheme) ?? .system
        
        // Set default values if not already set
        if self.hourlyWage == 0 {
            self.hourlyWage = 40.04
            self.taxDeduction = 11.78
            self.baseHoursWeekday = 8
            self.baseHoursSpecialDay = 8
            self.startWorkOnSunday = true
            saveSettings()
        }
        
        // Check if we should show the setup reminder
        checkSetupStatus()
    }
    
    // Check if basic setup is complete
    func checkSetupStatus() {
        let hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        // Only show reminder if the app has been launched before (onboarding completed)
        // but user hasn't saved settings at least once
        if hasLaunchedBefore && !hasCompletedSetup && username.isEmpty {
            showSetupReminder = true
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(hourlyWage, forKey: "hourlyWage")
        UserDefaults.standard.set(taxDeduction, forKey: "taxDeduction")
        UserDefaults.standard.set(baseHoursWeekday, forKey: "baseHoursWeekday")
        UserDefaults.standard.set(baseHoursSpecialDay, forKey: "baseHoursSpecialDay")
        UserDefaults.standard.set(startWorkOnSunday, forKey: "startWorkOnSunday")
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        UserDefaults.standard.set(selectedCountry.rawValue, forKey: "country")
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "theme")
        
        // Mark that setup has been completed
        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        
        // Update LocalizationManager
        LocalizationManager.shared.setLanguage(selectedLanguage.rawValue)
        LocalizationManager.shared.setCountry(selectedCountry)
        
        showingSaveConfirmation = true
    }
    
    // Method to apply language change immediately
    func applyLanguageChange(_ language: Language) {
        selectedLanguage = language
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        LocalizationManager.shared.setLanguage(selectedLanguage.rawValue)
    }
    
    func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return String(format: "%dh %dm", hours, minutes)
    }
} 