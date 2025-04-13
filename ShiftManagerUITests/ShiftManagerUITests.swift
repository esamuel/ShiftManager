//
//  ShiftManagerUITests.swift
//  ShiftManagerUITests
//
//  Created by Samuel Eskenasy on 4/11/25.
//

import XCTest

final class ShiftManagerUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-UITesting"]
        app.launch()
    }
    
    func testAppLaunch() throws {
        // Verify the app launches successfully
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
    
    func testTabBarNavigation() throws {
        // Test navigation between tabs
        let tabBar = app.tabBars.element
        XCTAssertTrue(tabBar.exists)
        
        // Test each tab
        let tabs = ["Home", "Shifts", "Settings"]
        for tab in tabs {
            tabBar.buttons[tab].tap()
            XCTAssertTrue(app.navigationBars[tab].exists)
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
