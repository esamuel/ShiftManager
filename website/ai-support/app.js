
// Configuration
const API_KEY = ""; // Set via secure backend/proxy. Do not commit provider keys.
const MODEL_NAME = "gemini-1.5-flash"; // Using 1.5-flash for better quota limits

// Knowledge Base (Mirrors the iOS AppKnowledgeBase.swift)
const APP_KNOWLEDGE_BASE = `
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
    - Formula: \`Total Wage = (Hours * Rate) + Overtime - (Deduction %)\`
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

## Troubleshooting
- **Notifications not working?** Check iOS Settings > Notifications > ShiftManager and ensure "Allow Notifications" is on.
- **Wrong calculations?** Check your "Break Duration" and ensuring "Overtime Rules" are not conflicting.
`;

const SYSTEM_PROMPT = `
You are the ShiftManager AI Support Assistant.

CONTEXT (Use this to answer questions):
${APP_KNOWLEDGE_BASE}

INSTRUCTIONS:
1. Detect the language of the user's question.
2. Answer ONLY in that ONE language.
3. Return your answer as a JSON object with two fields: "language" (2-letter code) and "text".

Example response:
{
  "language": "es",
  "text": "Para exportar a PDF, ve a la pestaña Reportes y toca el icono de compartir."
}

Keep text concise (1-2 sentences). Do NOT wrap the JSON in markdown blocks.
`;

// State
let isListening = false;
let recognition = null;
let currentLanguage = 'en-US';

// DOM Elements
const startBtn = document.getElementById('start-btn');
const statusText = document.getElementById('status-text');
const promptText = document.getElementById('prompt-text');
const responseText = document.getElementById('response-text');
const langSelect = document.getElementById('lang-select');
const voiceSelect = document.getElementById('voice-select');
const responseCard = document.getElementById('response-card');
const flagIcon = document.getElementById('response-flag');

let availableVoices = [];
let selectedVoiceName = localStorage.getItem('preferredVoice') || 'auto';

// Initialize cache system
const cache = new AICache();

// Stats tracking
let apiCallsSaved = parseInt(localStorage.getItem('ai_calls_saved')) || 0;
let totalQuestions = parseInt(localStorage.getItem('ai_total_questions')) || 0;

// Load available voices
function loadVoices() {
    availableVoices = window.speechSynthesis.getVoices();

    if (availableVoices.length === 0) {
        // Voices not loaded yet, retry
        setTimeout(loadVoices, 100);
        return;
    }

    populateVoiceSelector();
}

// Populate voice selector with high-quality voices
function populateVoiceSelector() {
    if (!voiceSelect) return;

    // Clear existing options except auto
    voiceSelect.innerHTML = '<option value="auto">Auto (Best Available)</option>';

    // Prioritize high-quality voices
    const qualityVoices = availableVoices.filter(voice => {
        const name = voice.name.toLowerCase();
        // Look for premium/enhanced voices
        return name.includes('premium') ||
            name.includes('enhanced') ||
            name.includes('google') ||
            name.includes('natural') ||
            name.includes('neural');
    });

    // Get all unique voices (prefer quality over quantity)
    const voicesToShow = qualityVoices.length > 0 ? qualityVoices : availableVoices;

    // Group by language
    const groupedVoices = {};
    voicesToShow.forEach(voice => {
        const langCode = voice.lang.split('-')[0];
        if (!groupedVoices[langCode]) {
            groupedVoices[langCode] = [];
        }
        groupedVoices[langCode].push(voice);
    });

    // Add voices to selector
    Object.keys(groupedVoices).sort().forEach(langCode => {
        groupedVoices[langCode].forEach(voice => {
            const option = document.createElement('option');
            option.value = voice.name;
            option.textContent = `${voice.name} (${voice.lang})`;
            if (voice.name === selectedVoiceName) {
                option.selected = true;
            }
            voiceSelect.appendChild(option);
        });
    });
}

// Update selected voice when user changes it
if (voiceSelect) {
    voiceSelect.addEventListener('change', (e) => {
        selectedVoiceName = e.target.value;
        localStorage.setItem('preferredVoice', selectedVoiceName);
    });
}

// Initialize Speech Recognition
function initSpeech() {
    if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
        alert("Speech recognition is not supported in this browser. Please use Chrome or Safari.");
        return;
    }

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    recognition = new SpeechRecognition();
    recognition.continuous = false;
    recognition.interimResults = false;

    recognition.onstart = () => {
        isListening = true;
        updateUI();
        statusText.textContent = "Listening...";
        promptText.textContent = "";
    };

    recognition.onend = () => {
        isListening = false;
        updateUI();
    };

    recognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        promptText.textContent = transcript;
        processQuestion(transcript);
    };

    recognition.onerror = (event) => {
        console.error("Speech error", event.error);
        statusText.textContent = "Error: " + event.error;
        isListening = false;
        updateUI();
    };
}

// Update Language
if (langSelect) {
    langSelect.addEventListener('change', (e) => {
        currentLanguage = e.target.value;
        if (recognition) recognition.lang = currentLanguage;
    });
}

// Start/Stop Logic
if (startBtn) {
    startBtn.addEventListener('click', () => {
        if (!recognition) initSpeech();

        if (isListening) {
            recognition.stop();
        } else {
            recognition.lang = currentLanguage;
            recognition.start();
        }
    });
}


function updateUI() {
    startBtn.textContent = isListening ? "Stop Listening" : "Start Speaking";
    startBtn.classList.toggle('listening', isListening);
}

/**
 * Process user question with smart caching and FAQ
 * Tier 1: Check FAQ for instant answer
 * Tier 2: Check cache for previous similar question
 * Tier 3: Call Gemini API and cache result
 */
async function processQuestion(userText) {
    totalQuestions++;
    localStorage.setItem('ai_total_questions', totalQuestions);

    // Tier 1: Check FAQ first (instant, free)
    statusText.textContent = "Searching knowledge base...";
    const faqResult = checkFAQ(userText, currentLanguage);
    if (faqResult) {
        apiCallsSaved++;
        localStorage.setItem('ai_calls_saved', apiCallsSaved);
        console.log(`💰 API call saved! Total saved: ${apiCallsSaved}/${totalQuestions}`);
        displayResponse(faqResult.language, faqResult.text);
        speakResponse(faqResult.text, faqResult.language);
        statusText.textContent = "📚 Answered from FAQ";
        return;
    }

    // Tier 2: Check cache (instant, free)
    const langCode = currentLanguage.split('-')[0]; // en-US -> en
    const cachedResponse = cache.get(userText, langCode);
    if (cachedResponse) {
        apiCallsSaved++;
        localStorage.setItem('ai_calls_saved', apiCallsSaved);
        console.log(`💰 API call saved! Total saved: ${apiCallsSaved}/${totalQuestions}`);
        displayResponse(cachedResponse.language, cachedResponse.text);
        speakResponse(cachedResponse.text, cachedResponse.language);
        statusText.textContent = "💾 Answered from cache";
        return;
    }

    // Tier 3: Call Gemini API (costs quota)
    statusText.textContent = "Asking AI...";
    await sendToGemini(userText);
}

// Gemini API Call
let currentUserQuestion = ''; // Track for caching

async function sendToGemini(userText) {
    currentUserQuestion = userText; // Store for caching
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}`;

    const payload = {
        contents: [{
            role: "user",
            parts: [{ text: SYSTEM_PROMPT + "\nUser Question: " + userText }]
        }]
    };

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        const data = await response.json();

        if (data.error) {
            console.error("Gemini Error:", data.error);
            // Extract useful error info
            const errorInfo = {
                code: data.error.code,
                message: data.error.message,
                status: data.error.status
            };
            handleError(errorInfo);
            return;
        }

        const rawText = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (rawText) {
            processGeminiResponse(rawText, userText);
        } else {
            statusText.textContent = "No response from AI.";
        }

    } catch (error) {
        console.error("Fetch Error:", error);
        statusText.textContent = "Connection error. Please try again.";
    }
}

function handleError(error) {
    console.error('Gemini API Error:', error);

    // Handle quota exceeded errors (429)
    if (error.code === 429 || (error.message && error.message.includes("quota"))) {
        statusText.textContent = "⏳ Daily limit reached. Please try again tomorrow or upgrade your plan.";
        return;
    }

    // Handle API key errors
    if (error.message && error.message.includes("API_KEY_SERVICE_BLOCKED")) {
        statusText.textContent = "⚙️ Configuration Error: API Key needs Website restriction.";
        return;
    }

    // Handle rate limiting
    if (error.status === "RESOURCE_EXHAUSTED" || error.code === 429) {
        statusText.textContent = "⏳ Too many requests. Please wait a moment and try again.";
        return;
    }

    // Generic error
    statusText.textContent = "❌ Error: " + (error.message || "Please try again later.");
}

function processGeminiResponse(rawText, userQuestion) {
    // Clean markdown if present
    const cleanText = rawText.replace(/```json/g, '').replace(/```/g, '').trim();

    try {
        const jsonResponse = JSON.parse(cleanText);

        // Cache the response for future use
        if (userQuestion) {
            const langCode = currentLanguage.split('-')[0];
            cache.set(userQuestion, langCode, jsonResponse);
            console.log('💾 Response cached for future use');
        }

        displayResponse(jsonResponse.language, jsonResponse.text);
        speakResponse(jsonResponse.text, jsonResponse.language);
        statusText.textContent = "✨ AI answered";
    } catch (e) {
        // Fallback if not JSON
        console.warn("JSON Parse failed, showing raw text", e);
        displayResponse("en", cleanText);
    }
}

function displayResponse(langCode, text) {
    responseCard.classList.remove('hidden');
    responseText.textContent = text;

    // Set flag
    const flags = { 'en': '🇺🇸', 'es': '🇪🇸', 'fr': '🇫🇷', 'de': '🇩🇪', 'ru': '🇷🇺', 'he': '🇮🇱' };
    flagIcon.textContent = flags[langCode] || '🏳️';
}

function speakResponse(text, langCode) {
    window.speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance(text);

    // Map simplified codes to full locale if needed
    const locales = { 'en': 'en-US', 'es': 'es-ES', 'fr': 'fr-FR', 'de': 'de-DE', 'ru': 'ru-RU', 'he': 'he-IL' };
    const targetLang = locales[langCode] || langCode;
    utterance.lang = targetLang;

    let selectedVoice = null;

    // If user has manually selected a specific voice, use it
    if (selectedVoiceName && selectedVoiceName !== 'auto') {
        selectedVoice = availableVoices.find(v => v.name === selectedVoiceName);
    }

    // If no manual selection or voice not found, use intelligent selection
    if (!selectedVoice) {
        const langPrefix = targetLang.split('-')[0];

        // Filter voices by language
        const langVoices = availableVoices.filter(voice =>
            voice.lang.startsWith(langPrefix)
        );

        if (langVoices.length > 0) {
            // Priority 1: Premium/Enhanced/Neural voices (Google, Microsoft, etc.)
            selectedVoice = langVoices.find(voice => {
                const name = voice.name.toLowerCase();
                return (name.includes('google') && name.includes('us')) ||
                    name.includes('enhanced') ||
                    name.includes('premium') ||
                    name.includes('neural') ||
                    name.includes('natural');
            });

            // Priority 2: Male voices with quality indicators
            if (!selectedVoice) {
                selectedVoice = langVoices.find(voice => {
                    const name = voice.name.toLowerCase();
                    return name.includes('male') &&
                        !name.includes('female') &&
                        (name.includes('google') || name.includes('microsoft'));
                });
            }

            // Priority 3: Specific high-quality male voice names
            if (!selectedVoice) {
                selectedVoice = langVoices.find(voice => {
                    const name = voice.name.toLowerCase();
                    return name.includes('david') ||
                        name.includes('daniel') ||
                        name.includes('james') ||
                        name.includes('thomas') ||
                        name.includes('nathan') ||
                        name.includes('aaron') ||
                        name.includes('alex');
                });
            }

            // Priority 4: Any male voice
            if (!selectedVoice) {
                selectedVoice = langVoices.find(voice => {
                    const name = voice.name.toLowerCase();
                    return name.includes('male') && !name.includes('female');
                });
            }

            // Priority 5: First available voice for the language
            if (!selectedVoice) {
                selectedVoice = langVoices[0];
            }
        }
    }

    // Set the selected voice
    if (selectedVoice) {
        utterance.voice = selectedVoice;
        console.log('Using voice:', selectedVoice.name);
    }

    // Optimize speech parameters for natural sound
    utterance.pitch = 0.95;  // Slightly lower for masculine, natural tone
    utterance.rate = 0.92;   // Slower for clarity and natural cadence
    utterance.volume = 1.0;  // Full volume

    window.speechSynthesis.speak(utterance);
}

// Initial Setup
document.addEventListener('DOMContentLoaded', () => {
    initSpeech();
    loadVoices();
});

// Load voices when they become available (some browsers load them async)
if (window.speechSynthesis) {
    speechSynthesis.onvoiceschanged = loadVoices;
}
