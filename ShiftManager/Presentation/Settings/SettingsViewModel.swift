import Foundation
import SwiftUI

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
    @Published var showingSaveConfirmation = false
    @Published var showingLanguagePicker = false
    
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
        
        // Set default values if not already set
        if self.hourlyWage == 0 {
            self.hourlyWage = 40.04
            self.taxDeduction = 11.78
            self.baseHoursWeekday = 8
            self.baseHoursSpecialDay = 8
            self.startWorkOnSunday = true
            saveSettings()
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