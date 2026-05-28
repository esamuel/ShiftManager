# ShiftManager App - FAQ Template for AI Support

## Instructions for User:
Please provide SHORT and ACCURATE answers (1-3 sentences max) for each question below.
I will then implement these as an instant FAQ system in the iOS app to reduce API calls.

---

## 📱 GETTING STARTED

### Q1: How do I add my first shift?
Go to the Shift Manager, select the Date, tap and select the start time, and  End time, add a note if needed, click Add shift, Done. 

### Q2: How do I set my default hourly rate?
Go to Settings, in Wage settings, add or change the Hourly rate, add the Tax deduction in %, save, and exit. 

### Q3: What is the difference between "Start Shift" and manual entry?
No different, there is a default start and End times, and you can change it as needed.

### Q4: Can I import shifts from another app?
No, this is not available in Shift Manager. 

---

## 🏠 HOME SCREEN

### Q5: What does the home screen show?
There are all the app functions. Shift manager -managing your actual shifts.
Coming Shifts -a list of your upcoming shifts, from today to the next 7 days.

### Q6: How do I start tracking a shift in real-time?
In the Shift Manager button, you change the default time to the time you start your shift, and when you finish your shift, you change the End Time to the correct time.

### Q7: What are "Upcoming Shifts"?
A list of your upcoming shifts, from today to the next 7 days.

### Q8: How do I set shift reminders/notifications?
Go to Settings, scroll to Notifications, enable it, select the Remind time, click save (V)

### Q9: Why aren't my notifications working?
Check these: 1) Go to iPhone Settings → ShiftManager → ensure "Allow Notifications" is ON. 2) Make sure Do Not Disturb/Focus mode is off. 3) Check that notifications are enabled in the app (Settings → Notifications). 4) If still not working, restart your iPhone.

---

## 📅 CALENDAR (Weekly & Monthly)

### Q10: How do I view my shifts in calendar format?
Tap the Reports tab at the bottom of the screen to see your shifts in weekly or monthly calendar view. 

### Q11: Can I see a monthly overview of all my shifts?
Yes, in the Reports tab, tap the month view toggle at the top to see all shifts for the entire month.

### Q12: How do I navigate between weeks/months?
Swipe left or right on the calendar, or tap the arrows at the top to move between weeks/months. 

### Q13: Can I add a shift directly from the calendar?
No, you need to go to the Shift Manager tab to add new shifts.

---

## 💼 SHIFT MANAGER

### Q14: Where can I see all my past shifts?
Go to the Shift Manager tab to see all your shifts, including past ones, in chronological order. You can select the Current button to view only your current shifts. 

### Q15: How do I edit an existing shift?
Tap on the shift in Shift Manager, find the shift you want to change, click the small pencil icon, make your changes, then tap Save (✓) at the top.

### Q16: How do I delete a shift?
Search for the shift in Shift Manager, then tap the Delete button.

### Q17: Can I duplicate a shift for recurring work?
No, this feature is not available. You need to add each shift manually. 

### Q18: How do I search for specific shifts?
Go to the Reports tab and tap the Search icon to find shifts by date, amount, or other details.

### Q19: Can I filter shifts by date or workplace?
Yes, in the Reports tab, you can select a custom date range to filter shifts by specific dates. 

---

## 💰 WAGES & CALCULATIONS

### Q20: How is my wage calculated?
Your wage is calculated as: (Hours × Hourly Rate) + Overtime - Deductions. The formula automatically applies your overtime rules and deduction percentage from Settings.

### Q21: What is the "Salary Calculator"?
The Salary Calculator is in Settings and helps you estimate your total monthly or weekly wages based on expected hours and your current rates.

### Q22: How do I set up overtime rules?
Go to Settings → Overtime Rules → Add Rule. Select the day type (General, Saturday, etc.), set hour ranges, and assign multipliers (1.25x, 1.5x, 2.0x).

### Q23: What overtime multipliers should I use? (1.25x, 1.5x, 2.0x)
Use multipliers based on your country's labor laws. Common: First 8 hours = 1x, hours 9-10 = 1.25x, hours 11-12 = 1.5x. Check your employment contract.

### Q24: How do breaks affect my wage calculation?
Break duration is subtracted from total shift time before calculating wages. For example, a 9-hour shift with 1-hour break = 8 paid hours.

### Q25: What are deductions and how do I set them?
Deductions are taxes or benefits taken from gross pay. Go to Settings → Wage Settings → Set deduction percentage (e.g., 12% for taxes).

### Q26: How do I calculate the right deduction percentage?
Take your total deductions from the last 3 months, divide by your total gross wage for the same period, then multiply by 100 to get the percentage.

### Q27: Do overtime rules apply to holidays?
Yes, if you create specific overtime rules for holidays or specific days, they will override the general overtime rules for those days.

### Q28: What's the maximum shift length supported?
The app supports shifts up to 24 hours. Shifts longer than 12 hours may have special overtime calculations based on your rules.

---

## ⏰ OVERTIME RULES

### Q29: Where do I configure overtime rules?
Go to Settings → Overtime Rules. Here you can add, edit, or delete rules for different days and hour ranges.

### Q30: What is "General Overtime" vs specific day rules?
General Overtime applies to all days by default. Specific day rules (like Saturday or holidays) override the general rules for those specific days.

### Q31: Can I have different rules for Saturday vs Sunday?
Yes, create separate overtime rules for each day. Go to Settings → Overtime Rules → Add Rule → Select the specific day.

### Q32: How do I set up holiday overtime?
Create a new overtime rule in Settings → Overtime Rules, select "Holiday" or the specific day, then set higher multipliers like 2.0x or 2.5x.

### Q33: Can I edit or delete overtime rules?
Yes, go to Settings → Overtime Rules, tap on any rule to edit it, or swipe left to delete. Changes apply to future shifts only.

---

## 📊 REPORTS & ANALYTICS

### Q34: Where can I see my earnings reports?
Go to the Reports tab at the bottom. You'll see charts and summaries of your monthly earnings, hours worked, and shift distribution.

### Q35: How do I view monthly earnings?
In the Reports tab, the monthly earnings chart shows your total wages by month. Tap on any month to see detailed breakdown.

### Q36: What charts are available?
The Reports tab includes: Monthly Earnings chart, Hours Worked chart, Wage Distribution pie chart, and shift timeline calendar view.

### Q37: How do I export a PDF report?
Go to Reports tab → Tap the Share icon (top right) → Select your date range → Tap Share to save or send the PDF.

### Q38: Can I select a custom date range for reports?
Yes, when exporting a PDF or using the search feature, you can select any start and end date to view specific periods.

### Q39: How do I share reports via email or WhatsApp?
After generating a PDF report, tap Share and select Email, WhatsApp, or any other sharing method from the iOS share sheet.

### Q40: What information is included in the PDF export?
The PDF includes: date range, list of all shifts with details, total hours worked, gross wages, overtime breakdown, and net pay after deductions.

---

## ⚙️ SETTINGS

### Q41: How do I change the app language?
Go to Settings → Language, select your preferred language (English, Hebrew, Russian, etc.), and the app will restart with the new language.

### Q42: How do I change the currency symbol?
Go to Settings → Wage Settings → Currency Symbol, select or enter your preferred currency (₪, $, €, etc.).

### Q43: Can I switch between light and dark mode?
The app automatically follows your iPhone's appearance settings. Change it in iPhone Settings → Display & Brightness → Dark/Light mode.

### Q44: How do I backup my data?
Your data is automatically backed up to iCloud if enabled. Go to iPhone Settings → [Your Name] → iCloud → ensure ShiftManager is turned ON.

### Q45: How do I restore data from backup?
If you reinstall the app and sign in to the same iCloud account, your data will automatically restore from the iCloud backup.

### Q46: Where do I find app version and about info?
Go to Settings → About. You'll see the app version, developer info, and links to support resources.

### Q47: How do I send feedback or report a bug?
Go to Settings → Feedback, describe your issue or suggestion, and tap Send. You can also contact support via the About section.

---

## 🎓 HELP & TUTORIALS

### Q48: Where can I find video tutorials?
Go to Settings → Video Tutorials to watch step-by-step guides on how to use different features of the app.

### Q49: Is there a quick start guide?
Yes, when you first open the app, there's an onboarding guide. You can also access it anytime from Settings → Guide.

### Q50: How do I access the AI Support?
Tap the Help icon or go to Settings → AI Support. You can ask questions in any language and get instant answers.

### Q51: Can the AI Support answer in Hebrew/Russian/etc?
Yes, the AI Support automatically detects your question language and responds in the same language (English, Hebrew, Russian, Spanish, French, German).

---

## 💎 PREMIUM FEATURES

### Q52: What features are included in Premium?
Premium includes: unlimited shifts, advanced reports, PDF export, priority support, cloud backup, and future premium features.

### Q53: How much does Premium cost?
Premium pricing varies by region. Tap Settings → Premium to see current pricing in your local currency.

### Q54: How do I upgrade to Premium?
Go to Settings → Premium → Select your plan (monthly or yearly) → Tap Subscribe and confirm with Face ID or password.

### Q55: Can I cancel my Premium subscription?
Yes, go to iPhone Settings → [Your Name] → Subscriptions → ShiftManager → Cancel Subscription. You'll keep Premium until the period ends.

### Q56: What happens to my data if I cancel Premium?
Your data is safe and won't be deleted. You'll just lose access to premium features but can still view all your existing shifts.

---

## 🔔 NOTIFICATIONS & REMINDERS

### Q57: How do I enable shift reminders?
Go to Settings → Notifications → Enable notifications → Set your preferred reminder time (e.g., 1 hour before shift).

### Q58: Can I set custom reminder times (e.g., 1 hour before)?
Yes, in Settings → Notifications, you can select from preset times: 15 minutes, 30 minutes, 1 hour, or 2 hours before your shift.

### Q59: Why am I not receiving notifications?
Check: 1) iPhone Settings → ShiftManager → Allow Notifications is ON. 2) Do Not Disturb is off. 3) In-app Settings → Notifications is enabled. 4) Restart iPhone if needed.

### Q60: How do I turn off notifications?
Go to Settings → Notifications → Toggle off "Enable Notifications", or disable them in iPhone Settings → ShiftManager → Notifications.

---

## 📱 DATA MANAGEMENT

### Q61: Is my data stored locally or in the cloud?
Your data is stored locally on your iPhone. If iCloud is enabled, it's also backed up to your iCloud account for safety.

### Q62: Can I export all my shift data?
Yes, you can export shift data as a PDF report from the Reports tab, or you can export to CSV if you have Premium.

### Q63: How do I delete all my data?
Go to Settings → Backup & Restore → Scroll down to "Delete All Data" → Tap the delete button. This permanently removes all shifts and settings and cannot be undone.

### Q64: Will I lose data if I delete the app?
If iCloud backup is enabled, your data will be restored when you reinstall. Otherwise, all local data will be lost permanently.

### Q65: Can I use the app on multiple devices?
Yes, if you enable iCloud in Settings, your data will sync across all your iOS devices signed in to the same Apple ID.

---

## 🐛 TROUBLESHOOTING

### Q66: The app is crashing, what should I do?
First restart your iPhone, then ensure the app is updated to the latest version. If it persists, contact support via Settings → Feedback.

### Q67: My calculations seem wrong, how do I check?
Verify: 1) Hourly rate in Settings. 2) Break duration is correct. 3) Overtime rules match your contract. 4) Deduction percentage is accurate.

### Q68: Shifts are not showing in the calendar, why?
Check the selected date range - swipe to the correct week/month. If shifts still don't show, try closing and reopening the app.

### Q69: How do I update the app?
Go to App Store → tap your profile icon → scroll to ShiftManager → tap Update. Or enable automatic updates in iPhone Settings.

### Q70: I forgot my overtime rules, how do I check them?
Go to Settings → Overtime Rules to see all your configured rules with their multipliers and hour ranges.

---

## 🌍 LOCALIZATION

### Q71: What languages does the app support?
The app supports: English, Hebrew (עברית), Russian (Русский), Spanish (Español), French (Français), and German (Deutsch).

### Q72: How do I change the app language to Hebrew?
Go to Settings → Language → Select "עברית" (Hebrew). The app will restart and display everything in Hebrew, including right-to-left layout.

### Q73: Are all features available in all languages?
Yes, all features, settings, and AI Support work in all supported languages with full translations.

---

## 📈 ADVANCED FEATURES

### Q74: Can I track multiple jobs separately?
Yes, add a note or tag to each shift indicating the workplace. You can then filter by notes in the Reports search.

### Q75: How do I use tags or categories for shifts?
Add descriptive notes when creating shifts (e.g., "Night shift", "Weekend", "Office A"), then use search to filter by these tags.

### Q76: Can I set different hourly rates for different shifts?
Yes, when adding or editing a shift, you can override the default hourly rate with a custom rate for that specific shift.

### Q77: Is there a way to track tips or bonuses?
Add tips or bonuses in the shift notes, or manually adjust the hourly rate to include the bonus amount for accurate total calculation.

### Q78: Can I export data to Excel or CSV?
CSV export is available with Premium. Go to Reports → Share → Select CSV format to export all shift data for use in Excel.

---

## 🔐 PRIVACY & SECURITY

### Q79: Is my wage data secure?
Yes, all data is stored locally on your device and encrypted. iCloud backups are also encrypted and only accessible with your Apple ID.

### Q80: Does the app share my data with third parties?
No, your data is private and never shared with third parties. The app only uses data locally for calculations and backup.

### Q81: Where can I read the privacy policy?
Go to Settings → Privacy Policy, or visit shiftsmanager.com/privacy to read the full privacy policy online.

---

## 📞 SUPPORT

### Q82: How do I contact support?
Go to Settings → Feedback or Settings → About → Contact Support. You can send a message directly from the app.

### Q83: Where can I find the terms of use?
Go to Settings → Terms of Use, or visit shiftsmanager.com/terms to read the full terms and conditions.

### Q84: Can I request a new feature?
Yes, go to Settings → Feedback, describe your feature request, and tap Send. The development team reviews all suggestions.

---

## 🎯 COMMON WORKFLOWS

### Q85: How do I track a typical work week?
Add each shift as it happens using Shift Manager. Set shift reminders to help you remember to log shifts. Review your week in the Reports tab.

### Q86: How do I calculate my monthly salary?
Go to Reports tab to see your monthly earnings automatically calculated. Or use Settings → Salary Calculator to estimate based on expected hours.

### Q87: What's the quickest way to add multiple shifts?
Go to Shift Manager, add the first shift with all details, then for similar shifts just change the date and times - the hourly rate and settings stay the same.

### Q88: How do I prepare a wage report for my employer?
Go to Reports → Export PDF → Select the pay period date range → Share the generated PDF which includes all shift details and totals.

---

## 🔄 UPDATES & WHAT'S NEW

### Q89: What's new in the latest version?
Check the App Store listing for ShiftManager or go to Settings → About to see the latest version notes and new features.

### Q90: How often is the app updated?
The app receives regular updates every 1-2 months with bug fixes, new features, and improvements based on user feedback. 

---

## ADDITIONAL QUESTIONS (Add any you think of):

### Q91: [Your question]
**Your Answer:** 

### Q92: [Your question]
**Your Answer:** 

### Q93: [Your question]
**Your Answer:** 

### Q94: [Your question]
**Your Answer:** 

### Q95: [Your question]
**Your Answer:** 

---

## NOTES & TIPS I SHOULD KNOW:
(Add any important context, tips, or common issues users face)

1. 

2. 

3. 

---

**After you fill this out, I will:**
1. Create a Swift FAQ database
2. Implement keyword matching (Hebrew & English)
3. Add caching system to iOS app
4. Connect it to the AI Support
5. Reduce API calls by 70%+

**This will make your iOS app's AI Support:**
- ⚡ Instant for common questions
- 💰 70% cheaper (less API calls)
- 🌍 Ready for worldwide users
- 📱 Work offline for cached/FAQ answers
