# ShiftManager AI Proxy

Secure proxy for iOS AI support. Keeps provider API keys on server side.

## 1) Configure environment

```bash
cp .env.example .env
```

Set values in `.env`:
- `GEMINI_API_KEY`: server-side Gemini key
- `PROXY_AUTH_TOKEN`: long random token (used by iOS as bearer token)
- `PORT`: default `8787`

## 2) Run locally

```bash
node server.js
```

Health check:

```bash
curl http://localhost:8787/health
```

## 3) iOS app configuration

In `ShiftManager/Info.plist` set:
- `AI_PROXY_URL` = your HTTPS proxy endpoint + `/ai/support`
- `AI_PROXY_TOKEN` = same value as `PROXY_AUTH_TOKEN`
- leave `GEMINI_API_KEY` empty in production

## 4) Test endpoint

```bash
curl -X POST http://localhost:8787/ai/support \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_PROXY_AUTH_TOKEN" \
  -d '{"contents":[{"parts":[{"text":"Say hello in JSON"}]}]}'
```

## 5) Personal device testing

iOS requires HTTPS for external calls. For quick personal testing:
- Run proxy locally
- Expose with HTTPS tunnel (Cloudflare Tunnel or ngrok)
- Put tunnel URL into `AI_PROXY_URL`

Example tunnel URL:
`https://your-subdomain.trycloudflare.com/ai/support`
