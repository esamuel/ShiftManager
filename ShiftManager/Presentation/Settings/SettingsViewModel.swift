import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var hourlyWage: Double = UserDefaults.standard.double(forKey: "hourlyWage")
    @Published var taxDeduction: Double = UserDefaults.standard.double(forKey: "taxDeduction")
    @Published var baseHoursWeekday: Int = UserDefaults.standard.integer(forKey: "baseHoursWeekday")
    @Published var baseHoursSpecialDay: Int = UserDefaults.standard.integer(forKey: "baseHoursSpecialDay")
    @Published var startWorkOnSunday: Bool = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
    @Published var darkMode: Bool = UserDefaults.standard.bool(forKey: "darkMode")
    @Published var selectedLanguage: Language = Language(rawValue: UserDefaults.standard.string(forKey: "language") ?? "english") ?? .english
    @Published var selectedCountry: Country = Country(rawValue: UserDefaults.standard.string(forKey: "country") ?? "israel") ?? .israel
    
    @Published var showingSaveConfirmation = false
    
    init() {
        // Set default values if not already set
        if UserDefaults.standard.object(forKey: "hourlyWage") == nil {
            hourlyWage = 40.04
            taxDeduction = 11.78
            baseHoursWeekday = 8
            baseHoursSpecialDay = 8
            startWorkOnSunday = true
            darkMode = true
            selectedLanguage = .english
            selectedCountry = .israel
            saveSettings()
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(hourlyWage, forKey: "hourlyWage")
        UserDefaults.standard.set(taxDeduction, forKey: "taxDeduction")
        UserDefaults.standard.set(baseHoursWeekday, forKey: "baseHoursWeekday")
        UserDefaults.standard.set(baseHoursSpecialDay, forKey: "baseHoursSpecialDay")
        UserDefaults.standard.set(startWorkOnSunday, forKey: "startWorkOnSunday")
        UserDefaults.standard.set(darkMode, forKey: "darkMode")
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "language")
        UserDefaults.standard.set(selectedCountry.rawValue, forKey: "country")
        
        // Apply dark mode setting
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
        }
        
        showingSaveConfirmation = true
    }
} 