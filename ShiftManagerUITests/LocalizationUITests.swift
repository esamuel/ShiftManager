import XCTest

final class LocalizationUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testLanguageChangeInSettings() throws {
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        
        // Wait for settings to load
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        
        // Test each language
        let languages = [
            ("he", "עברית"),
            ("es", "Español"),
            ("de", "Deutsch"),
            ("ru", "Русский"),
            ("fr", "Français"),
            ("en", "English")
        ]
        
        for (code, name) in languages {
            // Change language
            app.buttons[name].tap()
            
            // Verify UI elements are translated
            XCTAssertTrue(app.navigationBars["Settings".localized].exists)
            XCTAssertTrue(app.staticTexts["Language".localized].exists)
            
            // Wait for UI to update
            sleep(1)
        }
    }
    
    func testLanguagePersistence() throws {
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        
        // Change to Hebrew
        app.buttons["עברית"].tap()
        
        // Terminate and relaunch app
        app.terminate()
        app.launch()
        
        // Navigate back to Settings
        app.tabBars.buttons["Settings".localized].tap()
        
        // Verify language is still Hebrew
        XCTAssertTrue(app.navigationBars["הגדרות"].exists)
    }
} 