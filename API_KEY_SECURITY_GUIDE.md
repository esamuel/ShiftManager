# API Key Security Guide (Production)

## Core rule
Do **not** ship LLM provider API keys inside the iOS app binary.

## Recommended architecture
1. iOS app -> your backend endpoint (`AI_PROXY_URL`)
2. Backend -> Gemini/OpenAI/etc using server-side secret
3. Backend returns only model output (and optional metadata)

## Why
- App binaries can be reverse-engineered.
- Public keys in client apps get abused and revoked.
- Server side lets you enforce rate limits, auth, moderation, logging, and budget controls.

## What this project now supports
- `AI_PROXY_URL` (preferred)
- `GEMINI_API_KEY` as local/dev fallback only
- If neither is configured, app shows a clear configuration message.

## Setup checklist
- Create `ShiftManager/Config/Secrets.xcconfig` (gitignored) from `Secrets.example.xcconfig`
- Set either:
  - `AI_PROXY_URL=https://your-domain.com/ai/support` (recommended), or
  - `GEMINI_API_KEY=...` (dev only)
- Rotate any previously leaked key.

## Backend minimum requirements
- Require authenticated app requests (JWT/device token/session)
- Enforce per-user/IP rate limits
- Add abuse/misuse filtering
- Add request/response observability (without storing sensitive user data)
- Return deterministic JSON schema expected by app
