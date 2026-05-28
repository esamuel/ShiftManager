# 05_PRODUCT_CONCEPT.md

## App Name Options
1. **ShiftManager** (current — functional, generic, not memorable)
2. **PaySafe** (clear promise, but trademark crowded)
3. **PayCheck** (clear, but generic)
4. **MyShift** (warm, simple)
5. **WageGuard** / **שומר שכר** (strong promise in both languages)

## Recommended Name
**Keep "ShiftManager" for now.** Renaming a shipping App Store product carries real cost (reviews, search ranking, brand equity). Revisit *after* the payslip-verification feature ships and the product's true positioning is proven. If a rename happens later, **WageGuard / שומר שכר** best fits the new promise.

## Target Audience
**Primary (next 6 months):**
Hebrew-speaking hourly workers in Israel — waiters, baristas, retail, security, healthcare aides, hotel staff — paid by the hour, often with shift variation (regular / Shabbat / overtime / multi-role like *"סייר"*).

**Hard requirements for this user:**
- Owns an iPhone.
- Receives a written payslip (digital or paper).
- Suspects, at least sometimes, that their payslip is wrong.

**Secondary (later):** same profile in English-speaking markets (USA tipped workers, UK hospitality).

## Value Proposition
> **Log your shifts in seconds. We tell you what you should be paid. If your boss pays less — you'll know.**

## MVP Scope
The next version (v-next) must include only:

1. **Frictionless shift entry** — "Add same as yesterday" / repeat last shift / pick from saved templates. Goal: < 10 seconds per shift.
2. **Work Stations (multi-wage)** — user defines named stations (e.g., *"מלצרות"* at ₪40/h, *"סייר"* at ₪55/h); each shift picks a station; the station's wage drives the math. Replaces the current note-hack of typing "סייר" inside the note field.
3. **Notes visible on upcoming shifts** — if a shift has a note, show it in the upcoming-shifts list (currently invisible until tap).
4. **Monthly verification screen** — clear, single-number answer: *"You should be paid ₪X,XXX net this month."* Plus a one-tap "compare to my payslip" entry (manual input v1, OCR v2).
5. **iCloud sync** — survives phone change. Non-negotiable for a trust app.
6. **Analytics + crash reporting** — privacy-respecting, no PII (TelemetryDeck or similar). Tracks: shift added, station used, monthly report opened, payslip-compared, paywall viewed, paywall purchased, language.

## Not Included in MVP
- AI Support (text or voice). **Removed.**
- Voice features of any kind.
- Languages beyond **Hebrew + English**. Existing translations stay in the binary but receive no new work.
- Payslip OCR (deferred to v-next+1; manual payslip entry comes first).
- Team / multi-user / employer-side anything.
- Apple Watch, widgets, complications.
- New chart types in reports.
- Advanced overtime-rule editing UI (lock to good Israeli defaults).
- The 1,342-line SettingsView stays functionally as-is, but is **frozen** — no new toggles added until it is refactored.

## Business Model
- **Free**: unlimited shift logging, monthly summary (gross hours + estimated wage).
- **Paid (Premium, existing IAP)**: payslip verification (manual now, OCR later), Work Stations / multi-wage, iCloud sync, export (PDF/CSV), unlimited history.
- **Subscription vs one-time**: keep current model (whatever ships now). Don't change pricing until analytics show conversion baseline.
- **Recommended model going forward**: monthly subscription with a generous free tier. The verification screen is the wedge — show the *"you may have been underpaid"* banner to free users; require Premium to see the breakdown and export the proof.

## Differentiation
- **Not a time tracker.** Time trackers help freelancers bill clients. ShiftManager helps employees verify they were paid correctly. Different verb, different user, different feature set.
- **Worker-side, not employer-side.** Every shift app on the market (Deputy, When I Work, Sling, 7shifts) is sold to the employer. ShiftManager is the only one in the worker's pocket and on the worker's side.
- **Honest math.** Encodes the actual labor law of the worker's country, not a generic hours × rate.
- **Privacy-first by design** — local + iCloud, no employer access, no data sold.

## Success Metrics
Track from day one of analytics rollout:

1. **D7 retention** of new installs. Target: ≥ 30%.
2. **Shifts logged per active user per week.** Target: ≥ 3.
3. **% of monthly users who open the monthly report.** Target: ≥ 60%.
4. **% of monthly report viewers who use payslip-compare.** Target: ≥ 20% by month 3.
5. **Free → Premium conversion.** Track baseline first, then target +50%.
6. **Crashes per session.** Target: < 0.5%.
7. **Median time to add a shift.** Target: < 15 seconds.

Anything not moving these numbers is not a priority.
