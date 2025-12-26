import Foundation

struct AppKnowledgeBase {
    static let content = """
    # ShiftManager App Knowledge Base
    
    ## Core Functionality
    - **Logging Shifts**: Users can log shifts by tapping "Start Shift" on the home screen or manually adding them via the "Shift Manager" tab. A shift includes Start Time, End Time, Break Duration, and Hourly Rate.
    - **Shift Manager Tab**: Displays a history of all shifts. Users can edit or delete shifts here by swiping left or tapping.
    
    ## Wage & Overtime Calculation
    - **Hourly Rate**: Set a default hourly rate in Settings. This can be overridden per shift.
    - **Overtime Rules**: 
        - **How to set Overtime Rules**: Standard structure is often: First 8 hours = Regular Pay (1x). Next 2 hours (8-10) = 1.25x (or 1.75x on holidays). Next 2 hours (10-12) = 1.5x (or 2.0x on holidays).
        - **Customization**: You can set ANY specific multiplier (1.25, 1.5, 2.0, etc.) to match your country's laws. Note that shifts are typically capped at 12 hours maximum.
        - **General Overtime**: Applies default rules to all days unless a specific rule (like "Saturday") overrides it.
    - **Deductions**: 
        - Deduction percentage is calculated on the *Gross* total. 
        - Formula: `Total Wage = (Hours * Rate) + Overtime - (Deduction %)`
        - Users can set a fixed deduction percentage in Settings (e.g., for taxes or benefits).
        - **How to calculate?**: To estimate the right % to enter: Take your **total deduction amount** from the last 3 months, divide it by your **total gross wage** from the same period, and multiply by 100. (Result example: 12.6 or 14.3).
    
    ## Reports & Exporting
    - **Visual Reports**: The "Reports" tab shows charts for Monthly Earnings, Hours Worked, and Shift Distribution.
    - **PDF Export**:
        1. Go to the **Reports** tab.
        2. Tap the **Share/Export icon** (top right).
        3. Select the date range.
        4. A PDF is generated including a summary table and totals.
        5. You can share this PDF via Email, WhatsApp, or save to Files.
    
    ## Settings & Customization
    - **Currency**: Change the currency symbol in Settings.
    - **Theme**: Supports Light and Dark mode (follows system).
    - **Language**: App language can be changed in System Settings or via the in-app Language Selector (for AI).
    
    ## Data & Privacy
    - **Local Storage**: All data is stored locally on the device using CoreData.
    - **iCloud Sync**: If enabled, data syncs across devices signed into the same Apple ID.
    - **Privacy**: We do not sell or view user data. It is strictly private to the user.
    
    ## Troubleshooting
    - **Notifications not working?** Check iOS Settings > Notifications > ShiftManager and ensure "Allow Notifications" is on.
    - **Wrong calculations?** Check your "Break Duration" and ensuring "Overtime Rules" are not conflicting.
    """
}
