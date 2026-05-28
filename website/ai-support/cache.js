/**
 * Smart Caching System for AI Support
 * Reduces API calls by caching responses and providing instant answers
 */

class AICache {
    constructor() {
        this.cacheKey = 'shiftmanager_ai_cache';
        this.maxCacheSize = 100; // Maximum number of cached responses
        this.cacheExpiry = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
    }

    /**
     * Generate a cache key from user question
     */
    generateKey(question, language) {
        const normalized = question.toLowerCase().trim()
            .replace(/[?!.,]/g, '') // Remove punctuation
            .replace(/\s+/g, ' '); // Normalize whitespace
        return `${language}_${normalized}`;
    }

    /**
     * Get cached response if available
     */
    get(question, language) {
        try {
            const cache = this.getCache();
            const key = this.generateKey(question, language);
            const cached = cache[key];

            if (cached && Date.now() - cached.timestamp < this.cacheExpiry) {
                console.log('✅ Cache hit:', key);
                return cached.response;
            }

            if (cached) {
                // Expired, remove it
                delete cache[key];
                this.saveCache(cache);
            }

            console.log('❌ Cache miss:', key);
            return null;
        } catch (error) {
            console.error('Cache read error:', error);
            return null;
        }
    }

    /**
     * Save response to cache
     */
    set(question, language, response) {
        try {
            const cache = this.getCache();
            const key = this.generateKey(question, language);

            cache[key] = {
                response,
                timestamp: Date.now(),
                question: question.substring(0, 100) // Store original for debugging
            };

            // Enforce max cache size (LRU - remove oldest)
            const entries = Object.entries(cache);
            if (entries.length > this.maxCacheSize) {
                entries.sort((a, b) => a[1].timestamp - b[1].timestamp);
                const toRemove = entries.slice(0, entries.length - this.maxCacheSize);
                toRemove.forEach(([key]) => delete cache[key]);
                console.log(`🗑️ Removed ${toRemove.length} old cache entries`);
            }

            this.saveCache(cache);
            console.log('💾 Cached response for:', key);
        } catch (error) {
            console.error('Cache write error:', error);
        }
    }

    /**
     * Get entire cache from localStorage
     */
    getCache() {
        try {
            const cached = localStorage.getItem(this.cacheKey);
            return cached ? JSON.parse(cached) : {};
        } catch {
            return {};
        }
    }

    /**
     * Save entire cache to localStorage
     */
    saveCache(cache) {
        try {
            localStorage.setItem(this.cacheKey, JSON.stringify(cache));
        } catch (error) {
            console.error('Failed to save cache:', error);
        }
    }

    /**
     * Clear all cached responses
     */
    clear() {
        localStorage.removeItem(this.cacheKey);
        console.log('🗑️ Cache cleared');
    }

    /**
     * Get cache statistics
     */
    getStats() {
        const cache = this.getCache();
        const entries = Object.values(cache);
        const validEntries = entries.filter(e => Date.now() - e.timestamp < this.cacheExpiry);

        return {
            total: entries.length,
            valid: validEntries.length,
            expired: entries.length - validEntries.length,
            size: new Blob([JSON.stringify(cache)]).size
        };
    }
}

/**
 * Frequently Asked Questions
 * Instant answers without API calls
 */
const FAQ_DATABASE = {
    en: [
        {
            keywords: ['export', 'pdf', 'report'],
            answer: 'To export to PDF: Go to Reports tab → Tap Share icon (top right) → Select date range → Share or save the generated PDF.'
        },
        {
            keywords: ['overtime', 'calculate', 'rate'],
            answer: 'Overtime is calculated based on your settings. Go to Settings → Overtime Rules to configure multipliers (e.g., 1.25x, 1.5x, 2.0x) for different hour ranges.'
        },
        {
            keywords: ['notification', 'reminder', 'alert'],
            answer: 'To enable notifications: Go to iOS Settings → ShiftManager → Enable "Allow Notifications". You can also set reminder times in the app.'
        },
        {
            keywords: ['wage', 'salary', 'pay', 'money'],
            answer: 'Your wage is calculated as: (Hours × Rate) + Overtime - Deductions. Set your default hourly rate in Settings.'
        },
        {
            keywords: ['shift', 'add', 'create', 'log'],
            answer: 'To add a shift: Tap "Start Shift" on home screen OR go to Shift Manager tab → Tap + icon → Enter shift details.'
        }
    ],
    he: [
        {
            keywords: ['ייצוא', 'pdf', 'דוח'],
            answer: 'לייצא ל-PDF: לכו ללשונית דוחות ← הקישו על סמל השיתוף (למעלה מימין) ← בחרו טווח תאריכים ← שתפו או שמרו את ה-PDF.'
        },
        {
            keywords: ['שעות נוספות', 'חישוב', 'שכר'],
            answer: 'שעות נוספות מחושבות לפי ההגדרות שלכם. עברו להגדרות ← כללי שעות נוספות כדי להגדיר מכפילים (למשל 1.25, 1.5, 2.0).'
        },
        {
            keywords: ['התראה', 'תזכורת'],
            answer: 'להפעיל התראות: הגדרות iOS ← ShiftManager ← הפעילו "אפשר התראות". ניתן גם להגדיר זמני תזכורת באפליקציה.'
        },
        {
            keywords: ['משכורת', 'שכר', 'תשלום'],
            answer: 'השכר מחושב כך: (שעות × תעריף) + שעות נוספות - ניכויים. הגדירו תעריף שעתי ברירת מחדל בהגדרות.'
        },
        {
            keywords: ['משמרת', 'הוספה', 'יצירה'],
            answer: 'להוסיף משמרת: הקישו "התחל משמרת" במסך הבית או עברו ללשונית מנהל משמרות ← הקישו + ← הזינו פרטי משמרת.'
        }
    ],
    es: [
        {
            keywords: ['exportar', 'pdf', 'informe'],
            answer: 'Para exportar a PDF: Ve a Informes → Toca el icono de compartir (arriba a la derecha) → Selecciona el rango de fechas → Comparte o guarda el PDF.'
        },
        {
            keywords: ['horas extras', 'calcular', 'tarifa'],
            answer: 'Las horas extras se calculan según tu configuración. Ve a Ajustes → Reglas de horas extras para configurar multiplicadores (ej: 1.25x, 1.5x, 2.0x).'
        }
    ],
    ru: [
        {
            keywords: ['экспорт', 'pdf', 'отчет'],
            answer: 'Для экспорта в PDF: Перейдите в Отчеты → Нажмите значок "Поделиться" → Выберите диапазон дат → Поделитесь или сохраните PDF.'
        },
        {
            keywords: ['сверхурочные', 'рассчитать', 'ставка'],
            answer: 'Сверхурочные рассчитываются согласно настройкам. Перейдите в Настройки → Правила сверхурочных для настройки коэффициентов.'
        }
    ],
    fr: [
        {
            keywords: ['exporter', 'pdf', 'rapport'],
            answer: 'Pour exporter en PDF : Allez dans Rapports → Appuyez sur l\'icône de partage → Sélectionnez la plage de dates → Partagez ou enregistrez le PDF.'
        }
    ],
    de: [
        {
            keywords: ['exportieren', 'pdf', 'bericht'],
            answer: 'Um als PDF zu exportieren: Gehe zu Berichte → Tippe auf das Teilen-Symbol → Wähle Datumsbereich → Teile oder speichere das PDF.'
        }
    ]
};

/**
 * Check if question matches FAQ
 */
function checkFAQ(question, language) {
    const lang = language.split('-')[0]; // en-US -> en
    const faqs = FAQ_DATABASE[lang] || FAQ_DATABASE['en'];

    const normalizedQuestion = question.toLowerCase();

    for (const faq of faqs) {
        // Check if any keyword matches
        const matches = faq.keywords.some(keyword =>
            normalizedQuestion.includes(keyword.toLowerCase())
        );

        if (matches) {
            console.log('📚 FAQ match found!');
            return {
                language: lang,
                text: faq.answer
            };
        }
    }

    return null;
}

// Export for use in main app
window.AICache = AICache;
window.checkFAQ = checkFAQ;
