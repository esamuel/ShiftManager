import Foundation

/// Canonical support knowledge used by AI support prompts.
/// Keep this aligned with real app behavior and UI labels.
enum CanonicalSupportKnowledge {
    static let content = """
    # ShiftManager Canonical User Support Knowledge

    ## Supported Languages
    - English (en), Hebrew (he), Russian (ru), Spanish (es), French (fr), German (de)
    - AI answers should be in the user's language.

    ## Main Navigation
    - Main tabs: Home, Manager, Reports.
    - Home includes shortcuts: Coming Shifts, Shift Manager, Reports, Guide, Overtime Rules, Settings, AI Support Agent.

    ## Shift Manager (Manager Tab)
    - Add shift flow: Select Date -> Start Time -> End Time -> Add Note -> Add Shift.
    - Existing Shifts list supports Current Month / All Months filtering.
    - Shift cards support Edit (pencil), Delete (trash), and Special Day toggle (star).
    - Edit flow: Date, Start Time, End Time, Special Day, Notes, Save Changes.
    - Key constraints:
      - Overlapping shifts are blocked.
      - Long shifts show warning.
      - Daily hour limit warning exists (12-hour max messaging).
      - Free tier shift limit: 50 shifts, then Upgrade to Premium prompt.

    ## Reports
    - Main report supports Weekly View and Monthly View.
    - Includes period navigation and summary metrics (working days, hours, gross, net).
    - Search flow: Search Period (start/end date) -> Search -> Export to PDF.
    - Monthly report flow supports month selection and Export to PDF.
    - Do not claim export from a top-right share icon on the main report screen.

    ## Settings
    - Sections include: Profile, Regional, Language, Appearance, Wage Settings, Hours Settings, Notifications, Backup & Restore, Help & FAQ, About, Legal, Danger Zone.
    - Language: Settings -> Language -> Select Language.
    - Appearance: System / Light / Dark.
    - Wage settings: Hourly Wage, Tax Deduction (%), Deduction Calculator.
    - Hours settings: Base hours (weekday/special day), start work on Sunday or Monday.
    - Notifications:
      - Enable Notifications
      - Reminder lead times: 15m, 30m, 45m, 1h
    - Backup & Restore:
      - Export shifts backup (JSON)
      - Import shifts backup (JSON)
    - Danger zone supports delete-all data with confirmation.

    ## Overtime Rules
    - User can add/edit/delete overtime rules.
    - Rule fields include hours threshold, rate, and applies-to-special-days behavior.

    ## Premium
    - Paywall includes subscription/lifetime options, continue, restore purchases, redeem code.
    - Premium gating includes free-shift-limit upgrade prompt and monthly report PDF export gating.

    ## Coming Shifts
    - Upcoming shifts list is accessible from Home shortcut.

    ## Help and AI
    - Guide and FAQ/help entries are available from app navigation/settings.
    - Voice AI supports EN/HE/RU/ES/FR/DE.

    ## Important Accuracy Rules
    - Do not mention features that are not present in the app UI.
    - If uncertain, say you are not sure and ask one short clarifying question.
    - Prefer exact in-app labels/paths from this document.
    """
}
