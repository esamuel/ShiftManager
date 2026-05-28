# 06_MVP_PLAN.md

## MVP Goal
Prove that workers will (a) log shifts long enough to reach payday and (b) use the app to verify their payslip — and that doing so converts free users to Premium.

We are testing **trust**, not features.

## Core User Flow

### Daily (the "tax")
1. User finishes a shift.
2. Opens app → taps **"+ Add shift"** → taps **"Same as last"** (or picks a saved template).
3. Optional: changes station (e.g., *מלצרות* → *סייר*) or end time.
4. Saves. Total time: under 15 seconds.

### Weekly
1. User opens Home → sees this week's hours + estimated wage to date.
2. Sees upcoming shifts with **notes visible inline**.

### Monthly (the payoff)
1. Payday arrives. User opens **Monthly Report**.
2. Big number at top: *"You should be paid ₪X,XXX net for May."*
3. Taps **"Check my payslip"** → enters the net amount from the payslip (v1) or scans it (v2).
4. App shows: ✅ match, or ⚠️ banner with the gap and which shift is missing.
5. User screenshots, sends to boss / friend / WhatsApp.

## Screens

### Existing — kept, light polish
1. **Home** (`HomeView.swift`) — add inline notes on upcoming shifts; surface "Add same as last" button.
2. **Add/Edit Shift** (`ShiftManagerView.swift`) — add Station picker; add "Repeat last shift" path.
3. **Monthly Report** (`MonthlyReportView.swift`) — add the verification banner + "Check my payslip" entry.
4. **Settings** (`SettingsView.swift`) — frozen, no new toggles; add a new **"Work Stations"** section.

### New
5. **Work Stations** (manage list: name, hourly wage, optional color/icon).
6. **Payslip Compare** (modal): "Enter the net amount from your payslip" → result screen with match / mismatch + breakdown.

### Removed / hidden
- `VoiceAISupportView.swift`
- `SimplifiedAISupportView.swift`
- AI Support entry point in Settings / Help

## Data Needed
- **Shift** (existing) — adds `stationId` (optional, FK).
- **Station** (new CoreData entity):
  - `id: UUID`
  - `name: String` (e.g., "מלצרות", "סייר", "Bar")
  - `hourlyWage: Decimal`
  - `colorHex: String?`
  - `isDefault: Bool`
  - `createdAt: Date`
- **Settings** (existing) — adds: `defaultStationId`, `iCloudSyncEnabled`, `payslipCompareLastEntered`.
- **PayslipCheck** (new, local): `month`, `expectedNet`, `reportedNet`, `gap`, `checkedAt`. Optional, used for history.

## Migration of Existing User Data
The user's current convention: a note containing **"סייר"** means a different wage applies.

**One-time migration on first launch of the new build:**
- Read user's existing shifts; if any note contains a known keyword pattern, **prompt** the user: *"We noticed shifts marked 'סייר'. Create a Work Station for them?"* → if yes, create the station, retroactively link those shifts, recalculate the month.
- Never auto-link without confirmation.

## AI Features Needed
**None for MVP.**

Future-only (post-validation):
- Payslip OCR (Vision framework on-device or a server pipeline).
- Anomaly detection: *"Your boss has shorted you 3 months in a row."*

## Manual Features First
- Payslip verification = **manual entry first** (user types the net amount). OCR comes only after manual-entry usage proves the feature is wanted.
- Station setup = **manual one-time setup**, no smart suggestions in v1 beyond the keyword-migration prompt above.

## Technical Stack
- **Frontend:** SwiftUI (unchanged).
- **Backend:** none (local-only + iCloud).
- **Database:** CoreData (existing), with **CloudKit sync** for the user's private database.
- **AI:** removed in MVP.
- **Authentication:** none (CloudKit uses the device's Apple ID — invisible to the user).
- **Payments:** existing StoreKit / `PurchaseManager.swift` (unchanged).
- **Analytics:** **TelemetryDeck** (privacy-first, GDPR-friendly, no IDFA, no PII). Single Swift package, ~1 hour of integration. Backup choice: Firebase Analytics if a richer funnel is needed later.
- **Crash reporting:** **Sentry** or **Firebase Crashlytics** — pick one.

## Build Order
This is the **plan order only — no code yet.** Each step gets its own approval before I touch files.

1. **Cut AI/Voice surface** — hide entry points, gate the views behind a debug flag (not deletion yet, in case you change your mind). File-by-file plan to follow on your approval.
2. **Wire analytics + crash reporting** — TelemetryDeck + a crash reporter. Add event taxonomy (~12 events).
3. **Add Work Stations** — new CoreData entity, migration, Settings UI, Station picker on Add Shift screen, wage math respects station.
4. **Show notes on upcoming shifts** — Home view tweak; smallest change in the list.
5. **Plan iCloud (CloudKit) sync** — design doc only, then implementation. Has migration risks; do not rush.
6. **Monthly Report verification banner + manual payslip compare** — the magic-moment feature.
7. **Freeze and refactor SettingsView** — break the 1,342-line file into section subviews. No behavior change.
8. **Validation round** — 5–10 real users (Yossi-profile), 30-day usage, decision point on what's next.
9. **Payslip OCR** — only if step 6 shows clear engagement.

## What I Will Not Touch
- The wage calculation engine ([WageCalculationService.swift](../ShiftManager/Services/WageCalculationService.swift)) except to read `stationId` for the hourly rate.
- The CoreData model except to **add** `Station` and the `stationId` field. No destructive changes.
- The existing IAP / paywall flow.
- The existing 6 language files (no deletions; just no new translation work).

## Risks to Watch During Build
- **CoreData + CloudKit migration** is the highest-risk step. Pilot with a copy of your real database first.
- **Removing AI** must not break the build or leave dead navigation targets.
- **Analytics must not capture PII** — no shift contents, no note text, no wage amounts in events.
