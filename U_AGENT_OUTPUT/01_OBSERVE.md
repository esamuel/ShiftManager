# 01_OBSERVE.md

## App Idea
ShiftManager — an iOS app that lets shift workers log their hours, calculate net wages (including overtime, special-day rates, and tax deductions), and verify that the salary they receive matches what they actually earned. The product exists to **protect workers from employer payroll errors**.

## Target User
- **Primary (now)**: shift workers in **Israel** — waiters, retail, security, healthcare, hospitality — who are paid hourly and do not fully trust the payslip they receive.
- **Secondary (future)**: same job profile in **Europe, USA, and Latin America**.
- Age range: roughly 20–55, smartphone-first, modest tech comfort.
- Critical attribute: motivated enough to *care about being paid correctly*, but **not motivated enough to spend 3 minutes a day on data entry**.

## Problem
1. Hourly workers cannot independently verify their paycheck.
2. Bosses make payroll errors (intentional or accidental) and the worker has no proof.
3. Workers want to know "how many hours did I really work this week / this month, and what should my net wage be?"

## Current Reality
- Most workers: trust the payslip blindly, or scribble hours on paper / notes app.
- The few who try: open a generic spreadsheet, give up after a week.
- Some use generic time-trackers built for freelancers (not shift workers), which don't model overtime rules or special-day rates.

## Existing Alternatives
- Pen + paper / Notes app (free, fragile, no math).
- Excel/Google Sheets (manual, error-prone, no overtime logic).
- Generic time trackers (Toggl, Clockify) — built for freelance billing, not for *"did my boss underpay me"*.
- Israeli HR/payroll apps from the employer side — worker has no control over them.
- Asking a friend / accountant / union rep — slow, embarrassing.

## Pain Level
**High — but silent.** Workers feel it on payday, shrug, and move on. The pain is real but rarely loud enough to trigger active app-searching. This is a "should exist but nobody is looking for it" problem.

## Frequency
- The *checking* event: **monthly** (payday).
- The *logging* event that the app requires: **daily or per-shift** — and this is where users drop off.

## Initial Feasibility Score
**7/10.**
- Strong real-world need.
- Already built and shipping.
- Real risk: **logging friction kills retention** before the monthly payoff arrives.

## Open Questions
1. Can shift entry be reduced from "3 minutes" to "10 seconds" (templates, repeat last shift, auto-fill)?
2. Could the app **auto-detect** shifts via calendar, location, or NFC tag at the workplace?
3. Would users let the app **read their payslip** (camera + OCR) and tell them "you were underpaid by ₪87"?
4. Is the Israeli market large enough to validate before going multi-country, or should Europe/USA come immediately?
5. Are the existing **6 languages premature** for a product without 10 validated paying users?
6. Does the **AI/voice feature** deserve to exist at all? (See `03_ASSUMPTIONS_TO_RELEASE.md`.)
