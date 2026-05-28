import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { URL } from "node:url";
import { fileURLToPath } from "node:url";

function loadDotEnv() {
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const envPath = path.join(__dirname, ".env");

  if (!fs.existsSync(envPath)) return;

  const raw = fs.readFileSync(envPath, "utf8");
  for (const line of raw.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;

    const separator = trimmed.indexOf("=");
    if (separator <= 0) continue;

    const key = trimmed.slice(0, separator).trim();
    const value = trimmed.slice(separator + 1).trim();

    process.env[key] = value;
  }
}

loadDotEnv();

const PORT = Number(process.env.PORT || 8787);
const GEMINI_API_KEY = (process.env.GEMINI_API_KEY || "").trim();
const PROXY_AUTH_TOKEN = (process.env.PROXY_AUTH_TOKEN || "").trim();
const RATE_LIMIT_PER_MINUTE = Number(process.env.RATE_LIMIT_PER_MINUTE || 30);

const MODEL_ENDPOINTS = [
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent"
];

const ipBuckets = new Map();

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Allow-Methods": "POST, OPTIONS, GET"
  });
  res.end(JSON.stringify(payload));
}

function getClientIP(req) {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string" && forwarded.length > 0) {
    return forwarded.split(",")[0].trim();
  }
  return req.socket.remoteAddress || "unknown";
}

function isRateLimited(ip) {
  const now = Date.now();
  const minuteWindow = 60_000;
  const entry = ipBuckets.get(ip) || { count: 0, startedAt: now };

  if (now - entry.startedAt > minuteWindow) {
    entry.count = 0;
    entry.startedAt = now;
  }

  entry.count += 1;
  ipBuckets.set(ip, entry);
  return entry.count > RATE_LIMIT_PER_MINUTE;
}

async function readBody(req) {
  return await new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 1024 * 1024) {
        reject(new Error("Payload too large"));
      }
    });
    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

async function callGemini(payload) {
  let lastErrorData = null;

  for (const endpoint of MODEL_ENDPOINTS) {
    const url = `${endpoint}?key=${GEMINI_API_KEY}`;
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    const data = await response.json().catch(() => ({}));

    if (response.status === 404) {
      lastErrorData = { status: response.status, data };
      continue;
    }

    return { status: response.status, data };
  }

  return lastErrorData || {
    status: 502,
    data: { error: { message: "No compatible Gemini model endpoint found." } }
  };
}

const server = http.createServer(async (req, res) => {
  const requestURL = new URL(req.url || "/", `http://${req.headers.host}`);
  const pathname = requestURL.pathname;

  if (req.method === "OPTIONS") {
    return sendJson(res, 200, { ok: true });
  }

  if (pathname === "/health" && req.method === "GET") {
    return sendJson(res, 200, {
      ok: true,
      configured: Boolean(GEMINI_API_KEY),
      rateLimitPerMinute: RATE_LIMIT_PER_MINUTE
    });
  }

  if (pathname !== "/ai/support" || req.method !== "POST") {
    return sendJson(res, 404, { error: "Not found" });
  }

  if (!GEMINI_API_KEY) {
    return sendJson(res, 500, { error: "Server missing GEMINI_API_KEY" });
  }

  if (PROXY_AUTH_TOKEN) {
    const authHeader = req.headers.authorization || "";
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!token || token !== PROXY_AUTH_TOKEN) {
      return sendJson(res, 401, { error: "Unauthorized" });
    }
  }

  const ip = getClientIP(req);
  if (isRateLimited(ip)) {
    return sendJson(res, 429, {
      error: {
        code: 429,
        status: "RESOURCE_EXHAUSTED",
        message: "Rate limit exceeded for this client."
      }
    });
  }

  try {
    const rawBody = await readBody(req);
    const payload = JSON.parse(rawBody || "{}");

    if (!payload || typeof payload !== "object" || !Array.isArray(payload.contents)) {
      return sendJson(res, 400, { error: "Invalid payload: expected Gemini contents array." });
    }

    const { status, data } = await callGemini(payload);
    return sendJson(res, status, data);
  } catch (error) {
    return sendJson(res, 500, {
      error: {
        message: "Proxy request failed",
        details: error instanceof Error ? error.message : "Unknown error"
      }
    });
  }
});

server.listen(PORT, () => {
  console.log(`AI proxy running on http://localhost:${PORT}`);
});
