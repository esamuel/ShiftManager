# App Store Setup Guide for ShiftManager

## 1. Apple Developer Program Setup

### Prerequisites
- [ ] Apple Developer Program Membership ($99/year)
- [ ] Valid Apple ID
- [ ] Credit card for payment
- [ ] Government-issued ID for verification

### Enrollment Steps
1. Visit [developer.apple.com](https://developer.apple.com)
2. Click "Enroll" in the Apple Developer Program
3. Sign in with your Apple ID
4. Complete the enrollment form
5. Pay the $99 annual fee
6. Complete identity verification (may take 24-48 hours)

## 2. App Store Connect Setup

### Account Creation
1. Visit [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Sign in with your Apple Developer account
3. Accept the App Store Connect agreement
4. Complete your account profile

### User Roles (if working with a team)
- **App Manager**: Can manage app metadata and submit for review
- **Developer**: Can upload builds and manage certificates
- **Admin**: Full access to all features

## 3. App Registration

### In Apple Developer Portal
1. Go to [developer.apple.com/account](https://developer.apple.com/account)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Click "Identifiers" → "+" to add new identifier
4. Select "App IDs" → "App"
5. Configure your app:
   - **Description**: ShiftManager
   - **Bundle ID**: com.samueleskenasy.ShiftManager
   - **Capabilities**: 
     - [x] CloudKit (you have this)
     - [ ] Push Notifications (if needed)
     - [ ] In-App Purchase (if needed)

### In App Store Connect
1. Go to "My Apps" → "+" → "New App"
2. Fill in the form:
   - **Platform**: iOS
   - **Name**: ShiftManager
   - **Primary Language**: English
   - **Bundle ID**: com.samueleskenasy.ShiftManager
   - **SKU**: ShiftManager2024 (unique identifier for your use)
   - **User Access**: Full Access

## 4. Provisioning Profiles & Certificates

### Distribution Certificate
1. In Xcode: Xcode → Preferences → Accounts
2. Add your Apple ID if not already added
3. Click "Manage Certificates"
4. Click "+" → "Apple Distribution"
5. Download and install the certificate

### Provisioning Profile
1. In Apple Developer Portal: "Profiles" → "+"
2. Select "App Store" distribution
3. Select your App ID: com.samueleskenasy.ShiftManager
4. Select your distribution certificate
5. Name: "ShiftManager App Store Distribution"
6. Download and install in Xcode

## 5. Xcode Project Configuration

### Current Configuration (Verified)
- ✅ Bundle Identifier: com.samueleskenasy.ShiftManager
- ✅ Version: 1.0
- ✅ Build: 1
- ✅ Deployment Target: iOS 18.4

### Required Updates
1. **Signing & Capabilities**:
   - Team: Your Apple Developer Team
   - Bundle Identifier: com.samueleskenasy.ShiftManager
   - Provisioning Profile: Automatic (recommended)

2. **Build Settings**:
   - Code Signing Identity: Apple Distribution
   - Provisioning Profile: Automatic

## 6. App Icons

### Required Icon Sizes
- [ ] 1024x1024 (App Store)
- [ ] 180x180 (iPhone 6 Plus and later)
- [ ] 167x167 (iPad Pro)
- [ ] 152x152 (iPad, iPad mini)
- [ ] 120x120 (iPhone 4 and later)
- [ ] 87x87 (iPhone 6 Plus and later)
- [ ] 80x80 (Spotlight)
- [ ] 76x76 (iPad)
- [ ] 60x60 (iPhone 4 and later)
- [ ] 40x40 (Spotlight)

### Icon Requirements
- Format: PNG
- No transparency
- No rounded corners (iOS will add them)
- No alpha channel
- Must be exactly the specified dimensions

## 7. Build Configuration

### Archive Build
1. In Xcode: Product → Archive
2. Select "Any iOS Device" as target
3. Wait for build to complete
4. In Organizer: Validate App
5. Upload to App Store Connect

### Build Validation Checklist
- [ ] No warnings or errors
- [ ] All required icons present
- [ ] Proper signing configuration
- [ ] Correct bundle identifier
- [ ] Valid provisioning profile

## 8. TestFlight Setup

### Internal Testing
1. Upload build to App Store Connect
2. Add internal testers (up to 100)
3. Test on real devices
4. Fix any issues found

### External Testing (Optional)
1. Submit for external testing review
2. Add external testers (up to 10,000)
3. Get feedback before App Store submission

## 9. Pre-Submission Checklist

### Technical Requirements
- [ ] App builds without errors
- [ ] All required icons included
- [ ] Proper signing configuration
- [ ] Correct bundle identifier
- [ ] Valid provisioning profile
- [ ] TestFlight testing completed
- [ ] No crashes during testing
- [ ] All features functional
- [ ] Performance acceptable
- [ ] Memory usage reasonable

### App Store Connect
- [ ] App created in App Store Connect
- [ ] Bundle ID matches Xcode project
- [ ] Build uploaded successfully
- [ ] App metadata prepared
- [ ] Screenshots ready
- [ ] Privacy policy URL accessible
- [ ] Terms of use URL accessible

## 10. Common Issues & Solutions

### Signing Issues
- **Problem**: "No provisioning profiles found"
- **Solution**: Check team selection and automatic signing

### Bundle ID Issues
- **Problem**: "Bundle identifier already exists"
- **Solution**: Use unique bundle ID or contact Apple

### Icon Issues
- **Problem**: "Missing required icon"
- **Solution**: Ensure all required sizes are included

### Build Issues
- **Problem**: Archive fails
- **Solution**: Check deployment target and device support

## Next Steps

After completing this setup:
1. Move to App Store Review Guidelines compliance
2. Prepare app metadata and screenshots
3. Implement any missing features
4. Submit for App Store review

## Support Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Xcode Documentation](https://developer.apple.com/xcode/) 