# App Store Submission Guide: ShiftManager

This guide outlines the step-by-step process for submitting **ShiftManager** to the Apple App Store.

---

## Phase 1: Preparation

### 1. Apple Developer Program
Ensure you have an active **Apple Developer Program** membership ($99/year). You cannot submit to the App Store without it.

### 2. App Store Connect
1. Log in to [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **My Apps** and click the **"+"** button to create a NEW app.
3. **Platform**: iOS
4. **Name**: ShiftManager (If taken, try "ShiftManager: Work Tracker")
5. **Primary Language**: English (or your preference)
6. **Bundle ID**: Select the one matching your Xcode project (usually `com.samueleskenasy.ShiftManager`).
7. **SKU**: A unique ID for your records (e.g., `SM-2025-001`).

---

## Phase 2: Xcode (The Build)

### 1. Versioning
In Xcode, select the **ShiftManager** target:
*   **Version**: 1.0.0
*   **Build**: 1 (Increment this every time you upload a new build of the same version).

### 2. Archive
1. Select **"Any iOS Device (arm64)"** as the build target in the top scheme selector.
2. Go to the menu: **Product > Archive**.
3. Wait for the build to complete. The **Organizer** window will open.

### 3. Upload
1. In the Organizer, select your latest archive and click **"Distribute App"**.
2. Select **"App Store Connect"** > **"Upload"**.
3. Follow the prompts (keep "Strip Swift symbols" and "Manage version number" checked).
4. Once finished, Xcode will say "App successfully uploaded." It will take 10-30 minutes to appear in App Store Connect.

---

## Phase 3: App Store Connect (The Metadata)

### 1. App Information
*   **Subtitle**: Track shifts, wages & overtime.
*   **Category**: Business or Finance.
*   **Content Rights**: Select "No" (you own all content).
*   **Age Rating**: Click "Edit" and answer the questionnaire (usually 4+ for this app).

### 2. Pricing and Availability
*   **Price Schedule**: Choose "Free" (if using the in-app purchases we implemented) or set a price.
*   **Availability**: Select "All countries".

### 3. App Privacy
This is CRITICAL. Answer the questionnaire:
*   **Data Collection**: "No, we do not collect data from this app." (Since everything is local/iCloud).
*   **Privacy Policy URL**: You must host the text from `PrivacyPolicyView.swift` on a website and provide the link here.

### 4. Version 1.0.0 Settings
*   **Screenshots**: Upload screenshots for 6.5" iPhone and 5.5" iPhone.
*   **Promotional Text**: A short hook (displays above the description).
*   **Description**: (Use the draft provided in the previous message).
*   **Keywords**: `shifts, work, hours, tracker, wage, local, payroll`.
*   **Support URL**: Link to a support page or email.

### 5. Build
Scroll down to the **Build** section. Once processing is finished, click the **"+"** and select the build you uploaded from Xcode.

---

## Phase 4: Review and Release

### 1. Export Compliance
When selecting the build, Apple will ask about **Encryption**.
*   **Does the app use encryption?** Select **Yes** (Standard Apple encryption for HTTPS/iCloud).
*   **Is it exempt?** Select **Yes** (as it uses standard encryption for system services).

### 2. Submit for Review
Click **"Add for Review"** at the top right, then **"Submit to App Review"**.

### 3. Timeline
*   **Waiting for Review**: 24-48 hours usually.
*   **In Review**: 1-2 hours.
*   **Pending Developer Release**: Once approved, you can release it manually or let it release automatically.

---

## Troubleshooting Tips
*   **Build not showing up?** Check your email. Apple often sends an email if there's a missing key in `Info.plist` (like a missing usage description).
*   **Metadata rejected?** This is common. Apple might ask for more info about how the "Wage Calculation" works. Just reply with a brief explanation.
*   **In-App Purchases**: If you are using our `ShiftManager.storekit` features, you must also set up the "In-App Purchases" section in App Store Connect before submitting the build.
