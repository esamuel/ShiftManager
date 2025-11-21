# Quick Testing Guide - Legal Documents Localization

## ⚡ Quick Start (5 minutes)

### Step 1: Build & Run (1 minute)
```bash
⌘ + B  # Build
⌘ + R  # Run
```

### Step 2: Quick Test (4 minutes)
1. Open app → Settings → Upgrade to Premium
2. Tap "Terms of Service" → Should see full English terms
3. Tap "Privacy Policy" → Should see full English privacy policy
4. Change language to Hebrew
5. Open Premium again → Tap both links
6. ✅ Text should be in Hebrew and aligned RIGHT

## 🌍 Language Testing Matrix

| Language | Code | Test Terms | Test Privacy | Check RTL | Status |
|----------|------|------------|--------------|-----------|--------|
| English  | en   | ☐          | ☐            | N/A       | ☐      |
| Hebrew   | he   | ☐          | ☐            | ☐         | ☐      |
| German   | de   | ☐          | ☐            | N/A       | ☐      |
| French   | fr   | ☐          | ☐            | N/A       | ☐      |
| Spanish  | es   | ☐          | ☐            | N/A       | ☐      |
| Russian  | ru   | ☐          | ☐            | N/A       | ☐      |

## 🎯 What to Check

### ✅ Terms of Service Should Show:
- 12 numbered sections
- Last updated date at bottom
- All bullet points display correctly
- Text is fully scrollable
- "Done" button works

### ✅ Privacy Policy Should Show:
- Yellow/purple highlight box at top ("Our Core Privacy Principle")
- 14 numbered sections
- Green highlight box at bottom (Privacy Summary with checkmarks)
- Last updated date
- "Done" button works

### ✅ Hebrew (RTL) Specific Checks:
- Text flows RIGHT to LEFT
- Bullet points (•) appear on the RIGHT side
- Section numbers align correctly
- Highlight boxes align to the right
- Scrolling feels natural
- Navigation bar shows correctly

## 🐛 Common Issues & Fixes

### Issue: Text is in English when Hebrew selected
**Fix**: Localization strings might not be loaded
1. Clean build folder: ⇧⌘K
2. Rebuild: ⌘B
3. Check that .strings files were modified correctly

### Issue: Hebrew text aligns LEFT instead of RIGHT
**Fix**: RTL logic might not be working
1. Verify `LocalizationManager.shared.currentLanguage` returns "he"
2. Check that `isRTL` computed property is working
3. Restart app completely

### Issue: Cannot scroll to see all text
**Fix**: ScrollView might not be working
1. This shouldn't happen - both views use ScrollView
2. Try on different device/simulator
3. Check console for errors

### Issue: "Done" button doesn't dismiss
**Fix**: Environment dismiss might not be working
1. This is a SwiftUI environment issue
2. Restart Xcode and rebuild
3. Try on different iOS version

## 📱 Device Testing Recommendations

### Minimum Test Devices
- ✅ iPhone 14 Pro (or later) - for latest iOS
- ✅ iPhone SE - for small screen
- ✅ iPad - for large screen layout

### iOS Versions to Test
- ✅ iOS 17.0+ (minimum deployment target)
- ✅ Latest iOS version

## 🔍 Visual Inspection Checklist

### English (and other LTR languages)
```
[Navigation Bar: Terms of Service]          [Done]
┌─────────────────────────────────────────┐
│ TERMS OF SERVICE                        │
│                                         │
│ Last Updated: November 2025             │
│                                         │
│ 1. ACCEPTANCE OF TERMS                  │
│ By purchasing ShiftManager Premium...   │
│                                         │
│ 2. PREMIUM SUBSCRIPTION                 │
│ ShiftManager offers three...            │
│   • Lifetime Access: One-time...        │
│   • Annual Subscription...              │
│                                         │
│ [... scrollable content ...]            │
│                                         │
│ Last Updated: November 18, 2025         │
└─────────────────────────────────────────┘
```

### Hebrew (RTL)
```
[Done]          [Navigation Bar: תנאי שימוש]
┌─────────────────────────────────────────┐
│                        תנאי שימוש        │
│                                         │
│             עדכון אחרון: נובמבר 2025    │
│                                         │
│                  1. קבלת התנאים         │
│   ...ברכישת ShiftManager Premium       │
│                                         │
│                  2. מנוי פרימיום        │
│           ...ShiftManager מציעה שלוש    │
│        ...גישה לכל החיים: תשלום חד •   │
│               ...מנוי שנתי: חיוב שנתי •  │
│                                         │
│ [... scrollable content ...]            │
│                                         │
│    עדכון אחרון: 18 בנובמבר 2025        │
└─────────────────────────────────────────┘
```

## 🎬 Step-by-Step Testing Procedure

### Test 1: English Terms of Service
1. Launch app
2. Settings → Language → English
3. Settings → Upgrade to Premium
4. Tap "Terms of Service" link at bottom
5. ✅ Verify: English text, 12 sections, scrollable
6. Tap "Done" to dismiss

### Test 2: English Privacy Policy
1. In Premium screen
2. Tap "Privacy Policy" link at bottom
3. ✅ Verify: Yellow highlight box at top
4. ✅ Verify: 14 sections of text
5. ✅ Verify: Green summary box near bottom
6. Scroll to bottom
7. ✅ Verify: Last updated date shows
8. Tap "Done" to dismiss

### Test 3: Hebrew Terms of Service
1. Settings → Language → עברית (Hebrew)
2. Settings → שדרוג לפרימיום (Upgrade to Premium)
3. Tap "תנאי שימוש" (Terms of Service) link
4. ✅ Verify: Hebrew text appears
5. ✅ Verify: Text aligns to RIGHT
6. ✅ Verify: Bullet points on right side
7. Scroll through entire document
8. Tap "סיום" (Done)

### Test 4: Hebrew Privacy Policy
1. In Premium screen
2. Tap "מדיניות פרטיות" (Privacy Policy) link
3. ✅ Verify: Hebrew text appears
4. ✅ Verify: Highlight box aligned to RIGHT
5. ✅ Verify: All content flows RTL naturally
6. Scroll to bottom
7. ✅ Verify: Summary box aligned to RIGHT
8. Tap "סיום" (Done)

### Test 5: German, French, Spanish, Russian
For each language:
1. Change app language
2. Open Premium screen
3. Tap both legal document links
4. ✅ Verify: Correct language displays
5. ✅ Verify: Full content is readable
6. ✅ Verify: No English text appears
7. ✅ Verify: "Done" button works

## ⏱️ Time Estimate
- **Quick Test** (English + Hebrew only): 5 minutes
- **Full Test** (All 6 languages): 15 minutes
- **Thorough Test** (All languages + edge cases): 30 minutes

## 📊 Success Criteria

### ✅ PASS if:
- All languages display complete legal text
- Hebrew displays RTL correctly
- All text is readable and properly formatted
- Scrolling works smoothly
- "Done" buttons work in all languages
- No crashes or console errors
- Last updated dates show correctly

### ❌ FAIL if:
- Any language shows English instead of translation
- Hebrew shows LTR (left-to-right) alignment
- Text is cut off or unreadable
- Cannot scroll to see full content
- "Done" button doesn't work
- App crashes when opening legal docs
- Bullet points or formatting looks broken

## 🚀 Production Readiness Checklist

Before submitting to App Store:
- [ ] All 6 languages tested and working
- [ ] Hebrew RTL verified on real device
- [ ] Legal text reviewed for accuracy
- [ ] Last updated dates are correct
- [ ] No console warnings or errors
- [ ] Tested on iPhone and iPad
- [ ] Tested on iOS 17.0+ minimum
- [ ] Screenshots taken for App Store listing
- [ ] Legal documents also hosted on website
- [ ] Website URLs added to App Store Connect

## 📞 Support

If you encounter issues:
1. Check `LEGAL_DOCUMENTS_LOCALIZATION_SUMMARY.md` for detailed implementation info
2. Verify all .strings files were updated correctly
3. Clean build folder and rebuild
4. Check Xcode console for error messages
5. Confirm `PremiumTermsView.swift` and `PremiumPrivacyView.swift` are part of the `ShiftManager` target

---

**Testing Time**: ~15 minutes for full coverage
**Critical Tests**: English + Hebrew (minimum)
**Last Updated**: November 18, 2025

