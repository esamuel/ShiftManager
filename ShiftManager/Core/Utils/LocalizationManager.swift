import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }
    
    @Published var currentCountry: Country {
        didSet {
            UserDefaults.standard.set(currentCountry.rawValue, forKey: "country")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name("CountryChanged"), object: nil)
        }
    }
    
    var currencySymbol: String {
        return currentCountry.currencySymbol
    }
    
    private let isFirstLaunchKey = "isFirstLaunch"
    
    private init() {
        // Check if it's the first launch
        if !UserDefaults.standard.bool(forKey: isFirstLaunchKey) {
            // First launch - use device language
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = deviceLanguage
            UserDefaults.standard.set(true, forKey: isFirstLaunchKey)
            UserDefaults.standard.set(deviceLanguage, forKey: "selectedLanguage")
            UserDefaults.standard.synchronize()
        } else {
            // Not first launch - use saved language or default to English
            self.currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        }
        
        // Initialize current country
        let countryString = UserDefaults.standard.string(forKey: "country") ?? "israel"
        self.currentCountry = Country(rawValue: countryString) ?? .israel
    }
    
    func localizedString(for key: String) -> String {
        let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj")
        let bundle = path != nil ? Bundle(path: path!) : Bundle.main
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
    
    func availableLanguages() -> [AppLanguage] {
        return [
            AppLanguage(code: "en", name: "English"),
            AppLanguage(code: "he", name: "עברית"),
            AppLanguage(code: "ru", name: "Русский"),
            AppLanguage(code: "es", name: "Español"),
            AppLanguage(code: "fr", name: "Français"),
            AppLanguage(code: "de", name: "Deutsch")
        ]
    }
    
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    func setCountry(_ country: Country) {
        currentCountry = country
    }
    
    func resetToDeviceLanguage() {
        let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        setLanguage(deviceLanguage)
    }
}

struct AppLanguage {
    let code: String
    let name: String
} 