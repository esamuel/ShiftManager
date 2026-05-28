# 02_USER_INSIGHTS.md

## User Persona
**Name:** Yossi
**Age:** 28
**Situation:** Works rotating shifts as a waiter at a café in Tel Aviv. Picks up extra security shifts on weekends. Paid hourly, with overtime rules and special rates for Shabbat/holidays. Receives a payslip he barely understands.
**Skill level:** Comfortable with WhatsApp, Instagram, banking apps. Will not read a tutorial.
**Main pain:** Suspects he's being underpaid most months but can't prove it. Doesn't have the energy to log every shift manually.
**Current behavior:** Sometimes writes hours in WhatsApp self-chat. Forgets within a week. Trusts the payslip because arguing isn't worth it.

## Emotional Map

### Frustrations
- "I worked Shabbat — was I paid the right multiplier?"
- "My payslip has 12 numbers and none of them are explained."
- "I logged 3 shifts and stopped — now my data is useless."
- "The app wants me to set up overtime rules but I don't know what mine are."

### Fears
- Being underpaid silently, month after month.
- Confronting the boss, being labeled "difficult," losing shifts.
- Wasting time on an app that won't help anyway.
- Looking stupid for not understanding wage math.

### Desired Outcome
- A monthly number he can trust: **"This month you worked X hours and should receive ₪Y net."**
- Quiet confidence on payday — open app, compare to payslip, done.
- Evidence he could show if he ever did want to push back.

### Trust Builders
- The wage math is **demonstrably correct** for Israeli labor law (overtime thresholds, Shabbat rates).
- Logging takes **seconds, not minutes**.
- The app remembers his typical shifts so he doesn't re-enter them.
- His data is safe even if he changes phones.

### Reasons They May Quit
- Entry takes too long (the friend feedback: *"lazy to add 3 min"*).
- Forgets for a few days and feels behind — abandons.
- Loses data on phone change → catastrophic trust loss.
- The wage calculation looks wrong once, even slightly, → never trusts it again.
- Hits a paywall before seeing real value.

## Key Insight
> **ShiftManager is not a productivity tool. It is a trust tool.**
>
> Users don't open it to "manage shifts." They open it once a month to verify their paycheck. Everything between paydays — the daily logging — is the *tax* the user pays to use the product. The job of every feature is to **reduce that tax**.

This reframes the entire roadmap:

- ❌ Voice AI does not reduce the tax. Cut it (see `03_ASSUMPTIONS_TO_RELEASE.md`).
- ❌ A 1,342-line Settings screen *increases* the tax.
- ✅ "Repeat last shift" reduces the tax.
- ✅ Shift templates reduce the tax.
- ✅ Calendar/location auto-detect would crush the tax.
- ✅ iCloud sync prevents the worst possible trust event (data loss).
- ✅ Payslip OCR ("you were underpaid by ₪87") delivers the *magic moment* — the one screen users would screenshot and send to friends.
