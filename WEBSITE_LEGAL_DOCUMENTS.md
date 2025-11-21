# 🌐 Website Legal Documents for App Store

## 📋 Overview

Apple requires publicly accessible URLs for:
1. **Privacy Policy** (Required for ALL apps)
2. **Terms of Service** (Required for apps with IAP/subscriptions)

These must be hosted on a **public website** (not just in-app).

---

## 🎯 Quick Setup Options

### **Option 1: Use a Simple Website** (Recommended)

Create pages at:
- `https://yourwebsite.com/shiftmanager/privacy`
- `https://yourwebsite.com/shiftmanager/terms`

### **Option 2: Use GitHub Pages** (FREE!)

1. Create a GitHub repository: `shiftmanager-legal`
2. Enable GitHub Pages in Settings
3. URLs will be: `https://yourusername.github.io/shiftmanager-legal/privacy.html`

### **Option 3: Use Google Sites** (FREE & Easy)

1. Create a Google Site: sites.google.com
2. Create two pages: Privacy Policy & Terms of Service
3. Publish and get public URLs

---

## 📄 Privacy Policy for Website

### **Filename: `privacy.html` or `privacy-policy.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShiftManager - Privacy Policy</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }
        h1 {
            color: #5856D6;
            border-bottom: 3px solid #5856D6;
            padding-bottom: 10px;
        }
        h2 {
            color: #5856D6;
            margin-top: 30px;
        }
        .highlight {
            background-color: #f0f0f5;
            padding: 15px;
            border-left: 4px solid #5856D6;
            margin: 20px 0;
        }
        .last-updated {
            color: #666;
            font-size: 0.9em;
            margin-top: 40px;
        }
    </style>
</head>
<body>
    <h1>ShiftManager - Privacy Policy</h1>
    
    <div class="highlight">
        <strong>Key Principle:</strong> Your data stays on YOUR device. We do not collect, store, or transmit your personal information to our servers.
    </div>

    <h2>1. Introduction</h2>
    <p>ShiftManager ("we," "our," or "the app") is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use ShiftManager, including premium features purchased through the Apple App Store.</p>

    <h2>2. Information We Do NOT Collect</h2>
    <p>We DO NOT collect, store, or transmit:</p>
    <ul>
        <li>Personal identification information (name, email, phone number)</li>
        <li>Shift details, work schedules, or wage information</li>
        <li>Location data or device identifiers</li>
        <li>Usage analytics or behavioral tracking data</li>
        <li>Contact lists or calendar data beyond explicit permissions</li>
    </ul>

    <h2>3. Local Data Storage</h2>
    <p>All your shift data is stored <strong>exclusively on your device</strong> using:</p>
    <ul>
        <li>iOS Core Data (local database)</li>
        <li>iOS Keychain (secure settings storage)</li>
        <li>UserDefaults (user preferences)</li>
    </ul>
    <p>This data is:</p>
    <ul>
        <li>✓ Encrypted by iOS when your device is locked</li>
        <li>✓ Protected by your device passcode/Face ID/Touch ID</li>
        <li>✓ Isolated from other apps (iOS sandbox security)</li>
        <li>✓ Never transmitted to our servers</li>
    </ul>

    <h2>4. Premium Purchases</h2>
    <p>When you purchase premium features:</p>
    <ul>
        <li><strong>Apple handles ALL payment processing</strong> - we never see your payment information</li>
        <li>We receive only anonymous purchase verification (yes/no premium status)</li>
        <li>No personal information is shared with us</li>
        <li>All purchase data is governed by <a href="https://www.apple.com/legal/privacy/">Apple's Privacy Policy</a></li>
    </ul>

    <h2>5. iCloud Backup</h2>
    <p>If you enable iCloud backup on your iOS device:</p>
    <ul>
        <li>Your shift data may be backed up to your personal iCloud account</li>
        <li>This is controlled by iOS Settings, not by our app</li>
        <li>Backups are encrypted and only accessible with your Apple ID</li>
        <li>We have NO access to your iCloud data</li>
    </ul>
    <p>To manage: iOS Settings → [Your Name] → iCloud → Manage Storage → Backups</p>

    <h2>6. PDF Export & Data Sharing</h2>
    <p>When you export PDF reports (Premium feature):</p>
    <ul>
        <li>PDFs are generated locally on your device</li>
        <li>They contain only data YOU choose to include</li>
        <li>PDFs are shared only if YOU explicitly choose to send them</li>
        <li>We do not upload, access, or store exported PDFs</li>
    </ul>

    <h2>7. Permissions</h2>
    <p>The app may request these optional permissions:</p>
    <ul>
        <li><strong>Notifications:</strong> To remind you of upcoming shifts (handled by iOS, no data sent to us)</li>
        <li><strong>Calendar:</strong> To check for scheduling conflicts (read-only, never uploaded)</li>
    </ul>
    <p>All permissions are optional and can be managed in iOS Settings → ShiftManager</p>

    <h2>8. Third-Party Services</h2>
    <p>ShiftManager uses:</p>
    <ul>
        <li><strong>Apple App Store:</strong> For distribution and purchases (governed by Apple's policies)</li>
        <li><strong>StoreKit 2:</strong> For purchase verification (Apple's framework, runs locally)</li>
    </ul>
    <p>We do NOT use:</p>
    <ul>
        <li>Analytics services</li>
        <li>Advertising networks</li>
        <li>Social media integrations</li>
        <li>Cloud backends or external servers</li>
        <li>Third-party tracking tools</li>
    </ul>

    <h2>9. Children's Privacy</h2>
    <p>ShiftManager is intended for users 13 years and older. We do not knowingly collect information from children under 13. Users under 18 should obtain parental consent before making purchases.</p>

    <h2>10. Data Security</h2>
    <p>Your data is protected through:</p>
    <ul>
        <li>iOS-native security features (sandboxing, encryption)</li>
        <li>No server transmission = no transmission vulnerabilities</li>
        <li>Secure coding practices and regular updates</li>
    </ul>

    <h2>11. Data Deletion</h2>
    <p>To delete all your data:</p>
    <ol>
        <li>Delete the app from your device (removes all local data), or</li>
        <li>Settings → Clear All Data within the app</li>
        <li>If iCloud backup is enabled, delete backups from iCloud Settings</li>
    </ol>

    <h2>12. Your Rights</h2>
    <p>You have the right to:</p>
    <ul>
        <li>✓ Access all your data (it's on your device)</li>
        <li>✓ Export your data (PDF export feature)</li>
        <li>✓ Delete your data (delete shifts or app)</li>
        <li>✓ Opt out of notifications (iOS Settings)</li>
        <li>✓ Revoke app permissions (iOS Settings)</li>
    </ul>

    <h2>13. International Compliance</h2>
    <p>Since all data is stored locally on your device, ShiftManager complies with:</p>
    <ul>
        <li>GDPR (General Data Protection Regulation - EU)</li>
        <li>CCPA (California Consumer Privacy Act)</li>
        <li>Israeli Privacy Protection Law</li>
        <li>Other international privacy regulations</li>
    </ul>

    <h2>14. Updates to Privacy Policy</h2>
    <p>We may update this Privacy Policy to reflect new features or legal requirements. Changes will be communicated through app updates and in-app notifications.</p>

    <h2>15. Contact Us</h2>
    <p>Questions about privacy?</p>
    <ul>
        <li>Email: <a href="mailto:privacy@shiftmanager.app">privacy@shiftmanager.app</a></li>
        <li>In-App: Settings → About → Privacy Policy</li>
    </ul>

    <div class="highlight">
        <strong>Summary:</strong><br>
        🔒 Your data stays on YOUR device<br>
        📵 No data collection or tracking<br>
        💳 Payments handled securely by Apple<br>
        ✅ Full control over your information<br>
        🛡️ Protected by iOS security features
    </div>

    <p class="last-updated">
        <strong>Last Updated:</strong> December 2024<br>
        <strong>Version:</strong> 1.0<br>
        <strong>Effective Date:</strong> Upon app publication
    </p>
</body>
</html>
```

---

## 📄 Terms of Service for Website

### **Filename: `terms.html` or `terms-of-service.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShiftManager - Terms of Service</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }
        h1 {
            color: #5856D6;
            border-bottom: 3px solid #5856D6;
            padding-bottom: 10px;
        }
        h2 {
            color: #5856D6;
            margin-top: 30px;
        }
        .highlight {
            background-color: #f0f0f5;
            padding: 15px;
            border-left: 4px solid #5856D6;
            margin: 20px 0;
        }
        .last-updated {
            color: #666;
            font-size: 0.9em;
            margin-top: 40px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #5856D6;
            color: white;
        }
    </style>
</head>
<body>
    <h1>ShiftManager - Terms of Service</h1>

    <h2>1. Acceptance of Terms</h2>
    <p>By downloading, installing, or using ShiftManager ("the app"), you agree to these Terms of Service. If you do not agree, please do not use the app or purchase premium features.</p>

    <h2>2. Description of Service</h2>
    <p>ShiftManager is a shift tracking and wage calculation application for iOS devices. The app offers:</p>
    <ul>
        <li><strong>Free version:</strong> Basic shift tracking (up to 50 shifts), wage calculations, and calendar view</li>
        <li><strong>Premium version:</strong> Unlimited shifts, PDF export, advanced reports, split shifts, and additional features</li>
    </ul>

    <h2>3. Premium Subscriptions</h2>
    <p>ShiftManager offers three premium options:</p>
    
    <table>
        <tr>
            <th>Plan</th>
            <th>Price</th>
            <th>Billing</th>
        </tr>
        <tr>
            <td><strong>Lifetime Access</strong></td>
            <td>$14.99 USD</td>
            <td>One-time payment</td>
        </tr>
        <tr>
            <td><strong>Annual Subscription</strong></td>
            <td>$9.99 USD/year</td>
            <td>Auto-renews yearly</td>
        </tr>
        <tr>
            <td><strong>Monthly Subscription</strong></td>
            <td>$2.99 USD/month</td>
            <td>Auto-renews monthly</td>
        </tr>
    </table>

    <p>All purchases are processed through the Apple App Store and subject to <a href="https://www.apple.com/legal/internet-services/itunes/us/terms.html">Apple's Terms & Conditions</a>.</p>

    <h2>4. Premium Features</h2>
    <p>Premium unlocks:</p>
    <ul>
        <li>✓ Unlimited shift tracking (vs. 50 shift limit)</li>
        <li>✓ PDF export and advanced reporting</li>
        <li>✓ Split shift support</li>
        <li>✓ All 6 languages</li>
        <li>✓ Multiple currency support</li>
        <li>✓ Unlimited history access</li>
        <li>✓ Data backup and restore</li>
        <li>✓ Future premium features (Lifetime only)</li>
    </ul>

    <h2>5. Payment Terms</h2>
    <ul>
        <li><strong>Lifetime purchases:</strong> One-time charge, no recurring billing</li>
        <li><strong>Subscriptions:</strong> Auto-renew unless cancelled 24+ hours before period end</li>
        <li>Payment charged to iTunes Account at purchase confirmation</li>
        <li>Manage subscriptions in App Store Account Settings</li>
        <li>No refunds for unused subscription periods</li>
    </ul>

    <h2>6. Free Trial</h2>
    <p>If offered, free trials:</p>
    <ul>
        <li>Duration clearly stated at purchase</li>
        <li>Cancel 24+ hours before trial ends to avoid charges</li>
        <li>One trial per Apple ID</li>
        <li>Converts to paid subscription if not cancelled</li>
    </ul>

    <h2>7. Cancellation Policy</h2>
    <p><strong>For Subscriptions:</strong></p>
    <ul>
        <li>Cancel anytime via App Store Account Settings</li>
        <li>Access continues until end of billing period</li>
        <li>No refunds for partial periods</li>
    </ul>
    <p><strong>For Lifetime:</strong></p>
    <ul>
        <li>Contact Apple Support within 14 days for refund requests</li>
        <li>Evaluated case-by-case by Apple</li>
    </ul>

    <h2>8. User Responsibilities</h2>
    <p>You agree to:</p>
    <ul>
        <li>Use the app for personal, non-commercial purposes</li>
        <li>Verify all wage calculations with your employer</li>
        <li>Keep your device and app updated for security</li>
        <li>Not share your account or premium access</li>
        <li>Not reverse engineer or modify the app</li>
    </ul>

    <h2>9. Accuracy Disclaimer</h2>
    <div class="highlight">
        <strong>Important:</strong> ShiftManager provides wage calculations as a convenience tool. We do NOT guarantee 100% accuracy. You are responsible for verifying all calculations with your employer or accountant. We are not liable for any discrepancies or financial losses.
    </div>

    <h2>10. Disclaimer of Warranties</h2>
    <p>THE APP IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND. WE DO NOT GUARANTEE:</p>
    <ul>
        <li>Uninterrupted or error-free operation</li>
        <li>Accuracy of calculations or reports</li>
        <li>Compatibility with future iOS versions</li>
        <li>That the app meets your specific needs</li>
    </ul>

    <h2>11. Limitation of Liability</h2>
    <p>TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE ARE NOT LIABLE FOR:</p>
    <ul>
        <li>Any indirect, incidental, or consequential damages</li>
        <li>Lost wages, profits, or data</li>
        <li>Errors in calculations or reports</li>
        <li>Device failure or data loss</li>
    </ul>
    <p>Our total liability shall not exceed the amount you paid for premium features.</p>

    <h2>12. Modifications</h2>
    <p>We reserve the right to:</p>
    <ul>
        <li>Modify features with reasonable notice</li>
        <li>Update pricing for new subscribers (existing prices honored)</li>
        <li>Add new premium features</li>
        <li>Discontinue features with advance notice</li>
    </ul>

    <h2>13. Intellectual Property</h2>
    <p>ShiftManager and all its content (design, code, graphics, text) are owned by us and protected by copyright laws. You may not:</p>
    <ul>
        <li>Copy, modify, or distribute the app</li>
        <li>Remove copyright notices</li>
        <li>Create derivative works</li>
    </ul>

    <h2>14. Governing Law</h2>
    <p>These Terms are governed by:</p>
    <ul>
        <li>Laws of Israel</li>
        <li>International consumer protection laws</li>
        <li>Apple's App Store guidelines</li>
    </ul>
    <p>Disputes resolved through Apple's dispute process and applicable consumer agencies.</p>

    <h2>15. Contact Information</h2>
    <p>Questions or concerns?</p>
    <ul>
        <li>Email: <a href="mailto:support@shiftmanager.app">support@shiftmanager.app</a></li>
        <li>In-App: Settings → About → Contact Support</li>
        <li>Response time: Within 48 hours (business days)</li>
    </ul>

    <h2>16. Severability</h2>
    <p>If any provision is found unenforceable, the remaining provisions continue in full effect.</p>

    <h2>17. Changes to Terms</h2>
    <p>We may update these Terms periodically. Continued use constitutes acceptance. Material changes communicated via:</p>
    <ul>
        <li>In-app notification</li>
        <li>App Store update notes</li>
        <li>This website</li>
    </ul>

    <p class="last-updated">
        <strong>Last Updated:</strong> December 2024<br>
        <strong>Version:</strong> 1.0<br>
        <strong>Effective Date:</strong> Upon app publication<br>
        <strong>Contact:</strong> support@shiftmanager.app
    </p>
</body>
</html>
```

---

## 🚀 Quick Deployment Guide

### **GitHub Pages (FREE) - Step by Step:**

1. **Create Repository**
   ```bash
   # On GitHub.com
   - Click "New Repository"
   - Name: shiftmanager-legal
   - Public repository
   - Create
   ```

2. **Upload Files**
   - Upload `privacy.html` and `terms.html`
   - Commit changes

3. **Enable GitHub Pages**
   - Repository Settings → Pages
   - Source: main branch
   - Save

4. **Get Your URLs**
   ```
   Privacy: https://YOUR-USERNAME.github.io/shiftmanager-legal/privacy.html
   Terms: https://YOUR-USERNAME.github.io/shiftmanager-legal/terms.html
   ```

5. **Add to App Store Connect**
   - App Information → Privacy Policy URL
   - Enter your GitHub Pages URL

---

## ✅ App Store Connect Setup

1. Go to App Store Connect → Your App
2. **App Information** section
3. Add URLs:
   - **Privacy Policy URL:** (Required)
   - Enter: `https://yourusername.github.io/shiftmanager-legal/privacy.html`

4. **App Review Information**
   - Notes: "Privacy Policy and Terms accessible at provided URLs"

---

## 📧 Email Templates (Optional)

**Support Email Setup:**
Create email: `support@shiftmanager.app`  
Auto-responder:
```
Thank you for contacting ShiftManager Support!

We'll respond within 48 hours during business days.

Common Questions:
- Premium Purchase Issues: Settings → Restore Purchases
- Data Backup: Enable iCloud in iOS Settings
- Privacy: https://[your-url]/privacy.html

Best regards,
ShiftManager Team
```

---

## ✅ Final Checklist

Before App Store submission:

- [ ] Privacy Policy uploaded and publicly accessible
- [ ] Terms of Service uploaded and publicly accessible
- [ ] URLs added to App Store Connect
- [ ] URLs tested (open in browser, mobile-friendly)
- [ ] Contact email works (support@shiftmanager.app)
- [ ] In-app links work (PaywallView → PremiumTermsView/PremiumPrivacyView)
- [ ] About section links work (Settings → About → Privacy/Terms)

---

## 🎉 You're Ready!

Your app now has:
- ✅ Complete legal documentation (in-app)
- ✅ Public website documents (for App Store)
- ✅ Working links in paywall
- ✅ Professional presentation

**All legal requirements met for App Store submission!** 🚀

