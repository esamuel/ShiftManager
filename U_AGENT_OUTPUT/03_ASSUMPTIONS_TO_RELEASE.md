# 03_ASSUMPTIONS_TO_RELEASE.md

## Risky Assumptions
1. **"Users will log their shifts."** — Direct user feedback says they won't. This is the foundational risk.
2. **"More AI = more value."** — You admitted voice AI was added "just for fun." It doesn't solve the real problem.
3. **"6 languages strengthen the product."** — They strengthen translation surface area, not validation. You have 0 paying users in 5 of those languages.
4. **"Local-only data is a privacy feature."** — For a wage-proof app, it's a **liability**. Phone change = total data loss = total trust loss.
5. **"Settings flexibility is good."** — A 1,342-line settings screen is a confession of indecision, not a feature.
6. **"Premium will convert because the app is useful."** — Without analytics, this is hope, not a hypothesis.
7. **"Israel + Europe + USA + LatAm simultaneously."** — Spreading thin before validating one market.
8. **"The user understands overtime rules well enough to configure them."** — Yossi doesn't. Asking him to set thresholds is asking him to do the boss's job.

## Features to Remove for MVP
- **AI Support (text + voice).** Built for fun, doesn't reduce logging friction, costs API money, adds binary size, adds support burden. Remove from the v-next build entirely — or hide behind a debug flag.
- **VoiceAISupportView (1,056 lines)** and **SimplifiedAISupportView (499 lines)** — delete or gate.
- **FAQDatabase (515 lines)** — if AI goes, this can become a simple static help screen.
- **The 4 non-validated languages** (de, fr, es, ru) — keep the strings, stop shipping new translation work until you have users in those locales.
- Anything in Settings that the user has never touched (you can find out once analytics exist).

## Features to Delay
- Multi-country labor-law presets (Europe / USA / LatAm) — wait until Israel works.
- Team management, cloud-shared rotas, API integration (from your TECHNICAL_DESIGN "future" list).
- Apple Watch companion, widgets — only after retention is proven.
- Advanced reporting/charts — current monthly report is enough.

## Possible Failure Points
- **Drop-off after day 3** of logging — most likely cause of death.
- **Data loss on device change** — the killer one-star review.
- **A single visible wage-math bug** destroys the trust premise entirely.
- **App Store rejection** for shipping an OpenAI/Gemini key inside the binary (your own `API_KEY_SECURITY_GUIDE.md` admits this concern).
- **Spreading across languages and markets** while none are validated.

## Simpler Alternative
Reposition the product around **one promise**:

> "At the end of every month, ShiftManager tells you exactly what your net wage should be — so you can check your payslip in 5 seconds."

Then build only what serves that promise:

1. **One-tap "I worked my usual shift today"** (template-based logging).
2. **Correct Israeli wage math** (single market, locked in, audited).
3. **Monthly verdict screen** — big number, plain language, shareable screenshot.
4. **iCloud sync** so the data survives the user.
5. **Payslip OCR** (later) — the killer differentiator.

Everything else waits.

## Brutally Honest Verdict
You have a real product solving a real problem, but you've been **building outward (AI, voice, 6 languages, settings)** when the product needs to grow **inward (less friction, more trust, one market)**.

Specifically:
- **The voice AI should be removed.** You said it yourself: built for fun, not for need. Every hour spent on it is an hour not spent fixing the only thing that actually kills the app — logging friction.
- **Stop adding languages.** Pick Hebrew + English. Lock the rest.
- **Stop adding settings.** Audit and cut.
- **Start measuring.** Without analytics you cannot tell whether anything you build matters. This is the single highest-leverage change you can make this month.
- **Plan iCloud sync as the next real feature** — it protects the trust premise.
- **Then attack logging friction** — repeat-last-shift, templates, smart defaults, eventually auto-detect.

The app is closer to good than you think. It's just pointed in the wrong direction.

**Verdict: Simplify, then validate. Do not add features until analytics are live and one market is working.**
