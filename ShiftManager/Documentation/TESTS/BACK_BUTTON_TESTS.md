# Back Button Text Test Plan

## Overview
This document outlines the test plan for verifying and fixing the issue with Hebrew text "Back" appearing in back buttons throughout the app.

## Test Cases

### 1. Navigation Bar Back Button Tests

#### Test Case 1.1: Basic Navigation
- **Steps:**
  1. Launch app
  2. Navigate to any screen
  3. Check back button text
- **Expected Result:** Back button should show only chevron (no text)
- **Actual Result:** [To be filled during testing]
- **Status:** [To be filled during testing]

#### Test Case 1.2: Deep Navigation
- **Steps:**
  1. Launch app
  2. Navigate through 3+ screens
  3. Check back button text at each level
- **Expected Result:** All back buttons should show only chevron
- **Actual Result:** [To be filled during testing]
- **Status:** [To be filled during testing]

### 2. Language Switching Tests

#### Test Case 2.1: Hebrew Language
- **Steps:**
  1. Set app language to Hebrew
  2. Navigate through screens
  3. Check back button text
- **Expected Result:** Back button should show only chevron
- **Actual Result:** [To be filled during testing]
- **Status:** [To be filled during testing]

#### Test Case 2.2: Language Switch During Navigation
- **Steps:**
  1. Start in English
  2. Navigate to a screen
  3. Switch to Hebrew
  4. Check back button text
- **Expected Result:** Back button should show only chevron
- **Actual Result:** [To be filled during testing]
- **Status:** [To be filled during testing]

### 3. View Controller Lifecycle Tests

#### Test Case 3.1: View Will Appear
- **Steps:**
  1. Navigate to screen
  2. Check back button in viewWillAppear
  3. Navigate back and forth
- **Expected Result:** Back button text remains empty
- **Actual Result:** [To be filled during testing]
- **Status:** [To be filled during testing]

#### Test Case 3.2: View Did Load
- **Steps:**
  1. Navigate to screen
  2. Check back button in viewDidLoad
  3. Navigate back and forth
- **Expected Result:** Back button text remains empty
- **Actual Result:** [To be filled during testing]
- **Status:** [To be filled during testing]

### 4. Edge Cases

#### Test Case 4.1: Modal Presentation
- **Steps:**
  1. Present view controller modally
  2. Check back/dismiss button text
- **Expected Result:** No Hebrew text in dismiss button
- **Actual Result:** [To be filled during testing]
- **Status:** [To be filled during testing]

#### Test Case 4.2: Tab Bar Navigation
- **Steps:**
  1. Switch between tabs
  2. Check back button text in each tab
- **Expected Result:** No Hebrew text in back buttons
- **Actual Result:** [To be filled during testing]
- **Status:** [To be filled during testing]

## Test Environment

### Devices
- iPhone 15 Pro (iOS 17.4)
- iPhone 14 (iOS 16.4)
- iPhone 13 (iOS 15.4)

### Languages
- Hebrew
- English
- Russian
- Spanish
- French
- German

## Test Implementation

### 1. Manual Testing
- Follow each test case step by step
- Document results in the test cases
- Take screenshots of any issues found

### 2. Automated Testing
```swift
// Example test code for back button verification
func testBackButtonText() {
    let app = XCUIApplication()
    app.launch()
    
    // Navigate through screens
    app.buttons["Next"].tap()
    app.buttons["Next"].tap()
    
    // Verify back button
    let backButton = app.navigationBars.buttons.element(boundBy: 0)
    XCTAssertFalse(backButton.label.contains("Back"))
    XCTAssertFalse(backButton.label.contains("Back"))
}
```

## Fix Implementation

### 1. Navigation Bar Configuration
```swift
// In AppDelegate
func configureNavigationBar() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
}
```

### 2. View Controller Extension
```swift
extension UIViewController {
    func configureBackButton() {
        navigationItem.backButtonTitle = ""
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
```

### 3. Localization Manager
```swift
extension LocalizationManager {
    func clearBackButtonText() {
        // Clear back button text in all navigation controllers
        if let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
            for scene in windowScenes {
                for window in scene.windows {
                    if let rootVC = window.rootViewController {
                        recursivelyClearBackButtonText(in: rootVC)
                    }
                }
            }
        }
    }
}
```

## Verification Steps

1. Build and run the app
2. Execute all test cases
3. Verify fixes in all supported languages
4. Check edge cases
5. Document any remaining issues

## Regression Testing

After implementing fixes:
1. Run all test cases again
2. Verify in all supported languages
3. Check all navigation scenarios
4. Document results

## Issue Tracking

- Create GitHub issues for any problems found
- Tag issues with "back-button" label
- Include screenshots and reproduction steps
- Assign priority based on impact

## Next Steps

1. Implement fixes
2. Run test cases
3. Document results
4. Update documentation
5. Create pull request 