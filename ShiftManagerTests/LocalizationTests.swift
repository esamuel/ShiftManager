import XCTest
@testable import ShiftManager

final class LocalizationTests: XCTestCase {
    func testLanguageSelection() {
        let manager = LocalizationManager.shared
        
        // Test Hebrew
        manager.currentLanguage = "he"
        XCTAssertEqual("Language".localized, "שפה")
        XCTAssertEqual("Settings".localized, "הגדרות")
        
        // Test Spanish
        manager.currentLanguage = "es"
        XCTAssertEqual("Language".localized, "Idioma")
        XCTAssertEqual("Settings".localized, "Ajustes")
        
        // Test German
        manager.currentLanguage = "de"
        XCTAssertEqual("Language".localized, "Sprache")
        XCTAssertEqual("Settings".localized, "Einstellungen")
        
        // Test Russian
        manager.currentLanguage = "ru"
        XCTAssertEqual("Language".localized, "Язык")
        XCTAssertEqual("Settings".localized, "Настройки")
        
        // Test French
        manager.currentLanguage = "fr"
        XCTAssertEqual("Language".localized, "Langue")
        XCTAssertEqual("Settings".localized, "Paramètres")
        
        // Test English (fallback)
        manager.currentLanguage = "en"
        XCTAssertEqual("Language".localized, "Language")
        XCTAssertEqual("Settings".localized, "Settings")
    }
    
    func testLanguagePersistence() {
        let manager = LocalizationManager.shared
        let testLanguage = "he"
        
        // Set and save language
        manager.currentLanguage = testLanguage
        
        // Create new instance to test persistence
        let newManager = LocalizationManager.shared
        XCTAssertEqual(newManager.currentLanguage, testLanguage)
    }
    
    func testAvailableLanguages() {
        let manager = LocalizationManager.shared
        let languages = manager.availableLanguages()
        
        XCTAssertEqual(languages.count, 6) // Including English as fallback
        XCTAssertTrue(languages.contains(where: { $0.code == "he" && $0.name == "עברית" }))
        XCTAssertTrue(languages.contains(where: { $0.code == "es" && $0.name == "Español" }))
        XCTAssertTrue(languages.contains(where: { $0.code == "de" && $0.name == "Deutsch" }))
        XCTAssertTrue(languages.contains(where: { $0.code == "ru" && $0.name == "Русский" }))
        XCTAssertTrue(languages.contains(where: { $0.code == "fr" && $0.name == "Français" }))
        XCTAssertTrue(languages.contains(where: { $0.code == "en" && $0.name == "English" }))
    }
} 