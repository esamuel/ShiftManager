import Foundation
import SwiftUI

public enum Language: String, CaseIterable, Identifiable {
    case english
    case hebrew
    
    public var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .hebrew: return "Hebrew"
        }
    }
}

public enum Country: String, CaseIterable, Identifiable {
    case israel
    case usa
    
    public var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .israel: return "Israel (ILS)"
        case .usa: return "USA (USD)"
        }
    }
}

public class SettingsViewModel: ObservableObject {
    @Published var hourlyWage: Double
    @Published var taxDeduction: Double
    @Published var baseHoursWeekday: Int
    @Published var baseHoursSpecialDay: Int
    @Published var startWorkOnSunday: Bool
    @Published var selectedLanguage: Language
    @Published var selectedCountry: Country
    @Published var showingSaveConfirmation = false
    
    public init() {
        // Load saved values or use defaults
        self.hourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
        self.taxDeduction = UserDefaults.standard.double(forKey: "taxDeduction")
        self.baseHoursWeekday = UserDefaults.standard.integer(forKey: "baseHoursWeekday")
        self.baseHoursSpecialDay = UserDefaults.standard.integer(forKey: "baseHoursSpecialDay")
        self.startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        self.selectedLanguage = Language(rawValue: UserDefaults.standard.string(forKey: "shiftLanguage") ?? "english") ?? .english
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
        UserDefaults.standard.set(hourlyWage, forKey: "hourlyWage")
        UserDefaults.standard.set(taxDeduction, forKey: "taxDeduction")
        UserDefaults.standard.set(baseHoursWeekday, forKey: "baseHoursWeekday")
        UserDefaults.standard.set(baseHoursSpecialDay, forKey: "baseHoursSpecialDay")
        UserDefaults.standard.set(startWorkOnSunday, forKey: "startWorkOnSunday")
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "shiftLanguage")
        UserDefaults.standard.set(selectedCountry.rawValue, forKey: "country")
        
        showingSaveConfirmation = true
    }
    
    func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return String(format: "%dh %dm", hours, minutes)
    }
} 