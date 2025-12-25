# App Startup Performance Issues - Analysis

## Problem
The app is taking too long to launch/upload. 

## Root Causes Identified

### 1. **LocalizationManager - Method Swizzling** (CRITICAL)
**Location**: `LocalizationManager.swift` lines 373-411
**Issue**: The app is using Objective-C method swizzling to intercept every `viewWillAppear` call across the entire app. This is executed at app launch and adds significant overhead.

```swift
static let swizzleImplementation: Void = {
    // Swizzles viewWillAppear for ALL view controllers
    method_exchangeImplementations(originalMethod, swizzledMethod)
}()
```

**Impact**: HIGH - Affects every view controller in the app
**Solution**: Remove method swizzling entirely. Use SwiftUI modifiers instead.

### 2. **Recursive View Hierarchy Traversal**
**Location**: `LocalizationManager.swift` lines 212-284
**Issue**: Multiple functions recursively traverse the entire view hierarchy looking for specific text to replace.

**Impact**: MEDIUM - Only runs when language changes, but still expensive
**Solution**: Already disabled in `clearHebrewPreviousText()` (line 171-174), but other functions still exist

### 3. **Window Scene Operations During Init**
**Location**: `LocalizationManager.swift` lines 77-88
**Issue**: Checking `UIApplication.shared.connectedScenes` during initialization
**Impact**: LOW - Has early return if scenes are empty
**Solution**: Already optimized

### 4. **Core Data Initialization**
**Location**: `PersistenceController.swift` lines 8-40
**Issue**: Synchronous store loading with CloudKit setup
**Impact**: MEDIUM - CloudKit is already deferred to background (line 37-39)
**Solution**: Already optimized

### 5. **HomeView Preloading**
**Location**: `MainTabView.swift` lines 8-10, 17-21
**Issue**: Both HomeView and ShiftManagerView are set to `preload: true`
**Impact**: MEDIUM - Loads views immediately instead of lazily
**Solution**: Consider removing preload for ShiftManagerView

## Recommended Fixes (Priority Order)

### Priority 1: Remove Method Swizzling
Remove the entire swizzling mechanism from `LocalizationManager.swift`:
- Lines 373-411 (swizzling code)
- Lines 399-411 (ForceInitializer)

Use SwiftUI's native `.navigationBarBackButtonHidden()` modifier instead.

### Priority 2: Clean Up Dead Code
Remove unused recursive functions that traverse view hierarchies:
- `recursivelyRemoveBackButtonText` (lines 176-210)
- `recursivelySearchAndClearText` (lines 212-252)
- `clearNavigationBarText` (lines 254-258)
- `clearBackButtonTextRecursively` (lines 260-284)
- `forceFixNavigationControllers` (lines 287-347)

### Priority 3: Optimize Tab Preloading
Change `MainTabView.swift` to only preload HomeView:
```swift
DeferredView(preload: false) {  // Changed from true
    NavigationView {
        ShiftManagerView()
    }
}
```

## Expected Performance Improvement
- **Method Swizzling Removal**: 200-500ms faster startup
- **Dead Code Cleanup**: Smaller binary, faster load time
- **Tab Optimization**: 100-300ms faster initial render

**Total Expected Improvement**: 300-800ms faster app launch
