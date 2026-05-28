import Foundation

/// FAQ Database for instant answers without API calls
/// Multilingual support for 6 languages
/// Covers the top 20 most frequently asked questions
struct FAQDatabase {
    struct MatchResult {
        let answer: String
        let score: Int
        let phraseHits: Int
        let tokenHits: Int
        let entryID: String
    }
    
    // MARK: - FAQ Entry Structure
    
    struct FAQEntry {
        let id: String
        let category: String
        let keywords: [String]
        let englishAnswer: String
        let hebrewAnswer: String?
        let russianAnswer: String?
        let spanishAnswer: String?
        let frenchAnswer: String?
        let germanAnswer: String?
        
        init(id: String, 
             category: String,
             keywords: [String],
             en: String,
             he: String? = nil,
             ru: String? = nil,
             es: String? = nil,
             fr: String? = nil,
             de: String? = nil) {
            self.id = id
            self.category = category
            self.keywords = keywords
            self.englishAnswer = en
            self.hebrewAnswer = he
            self.russianAnswer = ru
            self.spanishAnswer = es
            self.frenchAnswer = fr
            self.germanAnswer = de
        }
        
        func answer(for languageCode: String) -> String? {
            switch languageCode.lowercased() {
            case "he": return hebrewAnswer // Returns nil if missing, forcing AI fallback
            case "ru": return russianAnswer
            case "es": return spanishAnswer
            case "fr": return frenchAnswer
            case "de": return germanAnswer
            default: return englishAnswer // English always returns
            }
        }
    }
    
    // MARK: - Top 20 FAQ Entries (Covers 80% of questions)
    
    static let entries: [FAQEntry] = [
        
        // Q1: How do I add my first shift?
        FAQEntry(
            id: "q1",
            category: "Getting Started",
            keywords: ["add shift", "first shift", "create shift", "new shift", "start shift", "הוסף משמרת", "משמרת חדשה", "יצירה", "добавить смену", "создать смену", "crear turno", "agrego", "agregar", "añadir", "nuevo turno", "ajouter quart", "créer", "schicht hinzufügen", "neue schicht"],
            en: "Go to the Shift Manager, select the Date, tap and select the start time, and End time, add a note if needed, click Add shift, Done.",
            he: "עבור למנהל משמרות, בחר תאריך, הקש ובחר שעת התחלה ושעת סיום, הוסף הערה במידת הצורך, לחץ על הוסף משמרת, סיום.",
            ru: "Перейдите в Менеджер смен, выберите дату, нажмите и выберите время начала и окончания, добавьте заметку при необходимости, нажмите Добавить смену, Готово.",
            es: "Ve al Administrador de Turnos, selecciona la Fecha, toca y selecciona la hora de inicio y fin, añade una nota si es necesario, haz clic en Agregar turno, Listo.",
            fr: "Allez dans le Gestionnaire de quarts, sélectionnez la date, appuyez et sélectionnez l'heure de début et de fin, ajoutez une note si nécessaire, cliquez sur Ajouter un quart, Terminé.",
            de: "Gehen Sie zum Schichtmanager, wählen Sie das Datum, tippen Sie und wählen Sie Start- und Endzeit, fügen Sie bei Bedarf eine Notiz hinzu, klicken Sie auf Schicht hinzufügen, Fertig."
        ),
        
        // Q2: How do I set my default hourly rate?
        FAQEntry(
            id: "q2",
            category: "Getting Started",
            keywords: ["hourly rate", "default rate", "set rate", "wage", "תעריף שעתי", "שכר", "почасовая ставка", "tarifa horaria", "taux horaire", "stundensatz"],
            en: "Go to Settings, in Wage settings, add or change the Hourly rate, add the Tax deduction in %, save, and exit.",
            he: "עבור להגדרות, בהגדרות שכר, הוסף או שנה את התעריף השעתי, הוסף ניכוי מס באחוזים, שמור וצא.",
            ru: "Перейдите в Настройки, в настройках зарплаты добавьте или измените почасовую ставку, добавьте налоговый вычет в %, сохраните и выйдите.",
            es: "Ve a Configuración, en ajustes de salario, añade o cambia la tarifa horaria, añade la deducción fiscal en %, guarda y sal.",
            fr: "Allez dans Paramètres, dans les paramètres de salaire, ajoutez ou modifiez le taux horaire, ajoutez la déduction fiscale en %, enregistrez et quittez.",
            de: "Gehen Sie zu Einstellungen, in den Lohneinstellungen fügen Sie den Stundensatz hinzu oder ändern ihn, fügen Sie den Steuerabzug in % hinzu, speichern und beenden."
        ),
        
        // Q3: Export PDF
        FAQEntry(
            id: "q37",
            category: "Reports",
            keywords: ["export", "pdf", "report", "share", "ייצוא", "דוח", "שיתוף", "экспорт", "отчет", "exportar", "informe", "exporter", "rapport", "exportieren", "bericht"],
            en: "Go to Reports tab → Tap the Share icon (top right) → Select your date range → Tap Share to save or send the PDF.",
            he: "עבור ללשונית דוחות ← הקש על סמל השיתוף (למעלה מימין) ← בחר טווח תאריכים ← הקש שתף כדי לשמור או לשלוח את ה-PDF.",
            ru: "Перейдите на вкладку Отчеты → Нажмите значок Поделиться (вверху справа) → Выберите диапазон дат → Нажмите Поделиться, чтобы сохранить или отправить PDF.",
            es: "Ve a la pestaña Informes → Toca el icono Compartir (arriba a la derecha) → Selecciona tu rango de fechas → Toca Compartir para guardar o enviar el PDF.",
            fr: "Allez dans l'onglet Rapports → Appuyez sur l'icône Partager (en haut à droite) → Sélectionnez votre plage de dates → Appuyez sur Partager pour enregistrer ou envoyer le PDF.",
            de: "Gehen Sie zur Registerkarte Berichte → Tippen Sie auf das Teilen-Symbol (oben rechts) → Wählen Sie Ihren Datumsbereich → Tippen Sie auf Teilen, um das PDF zu speichern oder zu senden."
        ),
        
        // Q15: Edit shift
        FAQEntry(
            id: "q15",
            category: "Shift Manager",
            keywords: ["edit shift", "modify", "change shift", "ערוך משמרת", "שנה", "редактировать", "изменить", "editar turno", "modificar", "modifier quart", "schicht bearbeiten"],
            en: "Tap on the shift in Shift Manager, find the shift you want to change, click the small pencil icon, make your changes, then tap Save (✓) at the top.",
            he: "הקש על המשמרת במנהל משמרות, מצא את המשמרת שברצונך לשנות, לחץ על סמל העיפרון הקטן, בצע שינויים, ואז הקש שמור (✓) בחלק העליון.",
            ru: "Нажмите на смену в Менеджере смен, найдите смену, которую хотите изменить, нажмите на маленький значок карандаша, внесите изменения, затем нажмите Сохранить (✓) вверху.",
            es: "Toca el turno en el Administrador de Turnos, encuentra el turno que quieres cambiar, haz clic en el pequeño icono de lápiz, realiza tus cambios y luego toca Guardar (✓) arriba.",
            fr: "Appuyez sur le quart dans le Gestionnaire de quarts, trouvez le quart que vous souhaitez modifier, cliquez sur la petite icône de crayon, effectuez vos modifications, puis appuyez sur Enregistrer (✓) en haut.",
            de: "Tippen Sie auf die Schicht im Schichtmanager, finden Sie die Schicht, die Sie ändern möchten, klicken Sie auf das kleine Stiftsymbol, nehmen Sie Ihre Änderungen vor und tippen Sie dann oben auf Speichern (✓)."
        ),
        
        // Q16: Delete shift
        FAQEntry(
            id: "q16",
            category: "Shift Manager",
            keywords: ["delete shift", "remove", "erase", "מחק משמרת", "הסר", "удалить", "eliminar", "supprimer", "löschen"],
            en: "Search for the shift in Shift Manager, then tap the Delete button.",
            he: "חפש את המשמרת במנהל משמרות, ואז הקש על כפתור מחק.",
            ru: "Найдите смену в Менеджере смен, затем нажмите кнопку Удалить.",
            es: "Busca el turno en el Administrador de Turnos, luego toca el botón Eliminar.",
            fr: "Recherchez le quart dans le Gestionnaire de quarts, puis appuyez sur le bouton Supprimer.",
            de: "Suchen Sie die Schicht im Schichtmanager und tippen Sie dann auf die Schaltfläche Löschen."
        ),
        
        // Q9: Notifications not working
        FAQEntry(
            id: "q9",
            category: "Troubleshooting",
            keywords: ["notification", "not working", "no alert", "reminder", "התראות", "לא עובד", "уведомления", "no funciona", "ne fonctionne pas", "funktioniert nicht"],
            en: "Check these: 1) Go to iPhone Settings → ShiftManager → ensure 'Allow Notifications' is ON. 2) Make sure Do Not Disturb/Focus mode is off. 3) Check that notifications are enabled in the app (Settings → Notifications). 4) If still not working, restart your iPhone.",
            he: "בדוק: 1) עבור להגדרות iPhone ← ShiftManager ← ודא ש'אפשר התראות' מופעל. 2) ודא שמצב אל תפריע/פוקוס כבוי. 3) בדוק שההתראות מופעלות באפליקציה (הגדרות ← התראות). 4) אם עדיין לא עובד, הפעל מחדש את ה-iPhone.",
            ru: "Проверьте: 1) Перейдите в Настройки iPhone → ShiftManager → убедитесь, что «Разрешить уведомления» включено. 2) Убедитесь, что режим «Не беспокоить/Фокус» выключен. 3) Проверьте, что уведомления включены в приложении (Настройки → Уведомления). 4) Если все еще не работает, перезагрузите iPhone.",
            es: "Verifica: 1) Ve a Ajustes de iPhone → ShiftManager → asegúrate de que 'Permitir notificaciones' está ACTIVADO. 2) Asegúrate de que el modo No molestar/Concentración esté desactivado. 3) Verifica que las notificaciones estén habilitadas en la app (Ajustes → Notificaciones). 4) Si aún no funciona, reinicia tu iPhone.",
            fr: "Vérifiez: 1) Allez dans Réglages iPhone → ShiftManager → assurez-vous que 'Autoriser les notifications' est ACTIVÉ. 2) Assurez-vous que le mode Ne pas déranger/Concentration est désactivé. 3) Vérifiez que les notifications sont activées dans l'app (Paramètres → Notifications). 4) Si cela ne fonctionne toujours pas, redémarrez votre iPhone.",
            de: "Überprüfen Sie: 1) Gehen Sie zu iPhone-Einstellungen → ShiftManager → stellen Sie sicher, dass 'Mitteilungen erlauben' EIN ist. 2) Stellen Sie sicher, dass der Nicht stören/Fokus-Modus ausgeschaltet ist. 3) Überprüfen Sie, dass Benachrichtigungen in der App aktiviert sind (Einstellungen → Benachrichtigungen). 4) Wenn es immer noch nicht funktioniert, starten Sie Ihr iPhone neu."
        ),
        
        // Q20: Wage calculation
        FAQEntry(
            id: "q20",
            category: "Wages",
            keywords: ["wage", "salary", "calculation", "payment", "שכר", "חישוב", "зарплата", "расчет", "salario", "cálculo", "salaire", "calcul", "gehalt", "berechnung"],
            en: "Your wage is calculated as: (Hours × Hourly Rate) + Overtime - Deductions. The formula automatically applies your overtime rules and deduction percentage from Settings.",
            he: "השכר מחושב כך: (שעות × תעריף שעתי) + שעות נוספות - ניכויים. הנוסחה מיישמת אוטומטית את כללי השעות הנוספות ואחוז הניכויים מההגדרות.",
            ru: "Ваша зарплата рассчитывается как: (Часы × Почасовая ставка) + Сверхурочные - Вычеты. Формула автоматически применяет ваши правила сверхурочных и процент вычетов из Настроек.",
            es: "Tu salario se calcula como: (Horas × Tarifa horaria) + Horas extras - Deducciones. La fórmula aplica automáticamente tus reglas de horas extras y porcentaje de deducciones desde Configuración.",
            fr: "Votre salaire est calculé comme: (Heures × Taux horaire) + Heures supplémentaires - Déductions. La formule applique automatiquement vos règles d'heures supplémentaires et le pourcentage de déduction depuis les Paramètres.",
            de: "Ihr Gehalt wird berechnet als: (Stunden × Stundensatz) + Überstunden - Abzüge. Die Formel wendet automatisch Ihre Überstundenregeln und den Abzugsprozentsatz aus den Einstellungen an."
        ),
        
        // Q22: Overtime rules
        FAQEntry(
            id: "q22",
            category: "Wages",
            keywords: ["overtime", "rules", "setup", "שעות נוספות", "כללים", "сверхурочные", "правила", "horas extras", "reglas", "heures supplémentaires", "règles", "überstunden", "regeln"],
            en: "Go to Settings → Overtime Rules → Add Rule. Select the day type (General, Saturday, etc.), set hour ranges, and assign multipliers (1.25x, 1.5x, 2.0x).",
            he: "עבור להגדרות ← כללי שעות נוספות ← הוסף כלל. בחר סוג יום (כללי, שבת וכו'), קבע טווחי שעות והקצה מכפילים (1.25x, 1.5x, 2.0x).",
            ru: "Перейдите в Настройки → Правила сверхурочных → Добавить правило. Выберите тип дня (Общий, Суббота и т.д.), установите диапазоны часов и назначьте множители (1.25x, 1.5x, 2.0x).",
            es: "Ve a Configuración → Reglas de horas extras → Agregar regla. Selecciona el tipo de día (General, Sábado, etc.), establece los rangos de horas y asigna multiplicadores (1.25x, 1.5x, 2.0x).",
            fr: "Allez dans Paramètres → Règles d'heures supplémentaires → Ajouter une règle. Sélectionnez le type de jour (Général, Samedi, etc.), définissez les plages horaires et attribuez des multiplicateurs (1.25x, 1.5x, 2.0x).",
            de: "Gehen Sie zu Einstellungen → Überstundenregeln → Regel hinzufügen. Wählen Sie den Tagestyp (Allgemein, Samstag usw.), legen Sie Stundenbereiche fest und weisen Sie Multiplikatoren zu (1.25x, 1.5x, 2.0x)."
        ),
        
        // Q41: Change language
        FAQEntry(
            id: "q41",
            category: "Settings",
            keywords: ["language", "change", "hebrew", "english", "שפה", "עברית", "язык", "idioma", "langue", "sprache"],
            en: "Go to Settings → Language, select your preferred language (English, Hebrew, Russian, etc.), and the app will restart with the new language.",
            he: "עבור להגדרות ← שפה, בחר את השפה המועדפת (אנגלית, עברית, רוסית וכו'), והאפליקציה תאותחל מחדש עם השפה החדשה.",
            ru: "Перейдите в Настройки → Язык, выберите предпочитаемый язык (английский, иврит, русский и т.д.), и приложение перезапустится с новым языком.",
            es: "Ve a Configuración → Idioma, selecciona tu idioma preferido (inglés, hebreo, ruso, etc.), y la app se reiniciará con el nuevo idioma.",
            fr: "Allez dans Paramètres → Langue, sélectionnez votre langue préférée (anglais, hébreu, russe, etc.), et l'app redémarrera avec la nouvelle langue.",
            de: "Gehen Sie zu Einstellungen → Sprache, wählen Sie Ihre bevorzugte Sprache (Englisch, Hebräisch, Russisch usw.), und die App wird mit der neuen Sprache neu gestartet."
        ),

        // Q42: Regional settings / locale
        FAQEntry(
            id: "q42",
            category: "Settings",
            keywords: [
                "regional settings", "region settings", "locale", "language and region", "region",
                "הגדרות אזוריות", "אזוריות", "אזור",
                "региональные настройки", "регион", "локаль",
                "configuracion regional", "configuración regional", "region",
                "parametres regionaux", "paramètres régionaux", "region",
                "regionale einstellungen", "region"
            ],
            en: "There is no separate Regional Settings screen in ShiftManager. Change language in Settings → Language, and change currency in Settings → Wage Settings → Currency Symbol. Date format follows your iPhone region settings.",
            he: "אין מסך נפרד של הגדרות אזוריות באפליקציה. שינוי שפה: הגדרות ← שפה. שינוי מטבע: הגדרות ← הגדרות שכר ← סמל מטבע. תצוגת תאריך נקבעת לפי הגדרות האזור באייפון.",
            ru: "В ShiftManager нет отдельного экрана «Региональные настройки». Язык: Настройки → Язык. Валюта: Настройки → Настройки зарплаты → Символ валюты. Формат даты берется из региональных настроек iPhone.",
            es: "ShiftManager no tiene una pantalla separada de Configuración regional. Idioma: Configuración → Idioma. Moneda: Configuración → Ajustes salariales → Símbolo de moneda. El formato de fecha sigue la región de tu iPhone.",
            fr: "ShiftManager n'a pas d'écran séparé « Paramètres régionaux ». Langue : Paramètres → Langue. Devise : Paramètres → Paramètres de salaire → Symbole de devise. Le format de date suit la région de votre iPhone.",
            de: "ShiftManager hat keinen separaten Bereich „Regionale Einstellungen“. Sprache: Einstellungen → Sprache. Währung: Einstellungen → Lohneinstellungen → Währungssymbol. Das Datumsformat folgt den Regionseinstellungen des iPhones."
        ),
        
        // Q44: Backup
        FAQEntry(
            id: "q44",
            category: "Data Management",
            keywords: ["backup", "data", "save", "גיבוי", "נתונים", "резервная копия", "respaldo", "sauvegarde", "sicherung"],
            en: "Your data is automatically backed up to iCloud if enabled. Go to iPhone Settings → [Your Name] → iCloud → ensure ShiftManager is turned ON.",
            he: "הנתונים שלך מגובים אוטומטית ל-iCloud אם הופעל. עבור להגדרות iPhone ← [שמך] ← iCloud ← ודא ש-ShiftManager מופעל.",
            ru: "Ваши данные автоматически резервируются в iCloud, если это включено. Перейдите в Настройки iPhone → [Ваше имя] → iCloud → убедитесь, что ShiftManager включен.",
            es: "Tus datos se respaldan automáticamente en iCloud si está habilitado. Ve a Ajustes de iPhone → [Tu nombre] → iCloud → asegúrate de que ShiftManager esté ACTIVADO.",
            fr: "Vos données sont automatiquement sauvegardées sur iCloud si activé. Allez dans Réglages iPhone → [Votre nom] → iCloud → assurez-vous que ShiftManager est ACTIVÉ.",
            de: "Ihre Daten werden automatisch in iCloud gesichert, wenn aktiviert. Gehen Sie zu iPhone-Einstellungen → [Ihr Name] → iCloud → stellen Sie sicher, dass ShiftManager EIN ist."
        ),
        
        // Q66: App crashing
        FAQEntry(
            id: "q66",
            category: "Troubleshooting",
            keywords: ["crash", "bug", "stuck", "closes", "קורסת", "נתקע", "краш", "вылетает", "cierra", "error", "plante", "absturz"],
            en: "First restart your iPhone, then ensure the app is updated to the latest version. If it persists, contact support via Settings → Feedback."
        ),
        
        // Q52: Premium
        FAQEntry(
            id: "q52",
            category: "Premium",
            keywords: ["premium", "pro", "upgrade", "cost", "price", "פרימיום", "מחיר", "שדרוג", "премиум", "цена", "costo", "prix", "kosten"],
            en: "Premium includes: unlimited shifts, advanced reports, PDF export, priority support, cloud backup. Check Settings → Premium for local pricing."
        ),
        
        // Q34: Earnings
        FAQEntry(
            id: "q34",
            category: "Reports",
            keywords: ["earnings", "month", "money", "report", "רווחים", "כסף", "חודשי", "заработок", "ganancias", "gains", "einnahmen"],
            en: "Go to the Reports tab at the bottom to see charts of your monthly earnings, hours worked, and shift distribution."
        )
        
    ]
    
    // MARK: - Search Functions
    
    /// Search FAQ for matching entry using word-based scoring
    static func search(question: String, languageCode: String) -> String? {
        return searchWithMetadata(question: question, languageCode: languageCode)?.answer
    }

    /// Search FAQ and return answer + match metadata.
    static func searchWithMetadata(question: String, languageCode: String) -> MatchResult? {
        let normalizedQuestion = normalize(question)
        let questionWords = tokenSet(from: normalizedQuestion)
        guard !questionWords.isEmpty else { return nil }

        var bestMatch: (entry: FAQEntry, score: Int, phraseHits: Int, tokenHits: Int)? = nil
        
        for entry in entries {
            var score = 0
            var phraseHits = 0
            var tokenHits = 0
            
            for keyword in entry.keywords {
                let lowerKeyword = normalize(keyword)
                guard !lowerKeyword.isEmpty else { continue }
                
                let keywordWords = tokenSet(from: lowerKeyword)
                guard !keywordWords.isEmpty else { continue }

                // Phrase matching:
                // - Multi-word keywords: allow substring phrase match in normalized question
                // - Single-word keywords: require exact token match to avoid false positives
                if keywordWords.count > 1 {
                    if normalizedQuestion.contains(lowerKeyword) {
                        score += 12
                        phraseHits += 1
                    }
                } else if let singleKeyword = keywordWords.first, questionWords.contains(singleKeyword) {
                    score += 10
                    phraseHits += 1
                }
                
                // Word-by-word match
                for kw in keywordWords where kw.count > 2 {
                    if questionWords.contains(kw) {
                        score += 3
                        tokenHits += 1
                    }
                }
            }
            
            if score > 0 {
                if let currentBest = bestMatch {
                    if score > currentBest.score {
                        bestMatch = (entry, score, phraseHits, tokenHits)
                    }
                } else {
                    bestMatch = (entry, score, phraseHits, tokenHits)
                }
            }
        }
        
        // Guardrail: only return when confidence is high enough to avoid wrong FAQ answers.
        // Accept either a direct phrase hit, or multiple token matches with decent score.
        if let match = bestMatch,
           match.phraseHits >= 1 || (match.tokenHits >= 2 && match.score >= 8) {
            print("📚 FAQ Match found! ID: \(match.entry.id), Score: \(match.score), phrases: \(match.phraseHits), tokens: \(match.tokenHits)")
            
            // Checks if a translation exists. Returns nil if translation is missing for the requested non-English language.
            // This allows the AI (Tier 3) to handle the question with a proper translation.
            if let answer = match.entry.answer(for: languageCode) {
                return MatchResult(
                    answer: answer,
                    score: match.score,
                    phraseHits: match.phraseHits,
                    tokenHits: match.tokenHits,
                    entryID: match.entry.id
                )
            }
        }
        
        return nil
    }

    private static func normalize(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "[?!.,:;()\\[\\]{}\"'`]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func tokenSet(from text: String) -> Set<String> {
        let stopWords: Set<String> = [
            "the", "and", "for", "with", "this", "that", "how", "what", "when", "why",
            "can", "you", "app", "shiftmanager", "please", "help"
        ]

        return Set(
            text.components(separatedBy: .whitespacesAndNewlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.count > 2 && !stopWords.contains($0) }
        )
    }
    
    /// Get statistics about FAQ usage
    static func getStats() -> (totalEntries: Int, languages: Int) {
        return (entries.count, 6)
    }
}

// MARK: - Response Cache

/// Caches API responses to reduce future API calls
class ResponseCache {
    static let shared = ResponseCache()
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "ai_response_cache"
    private let maxCacheSize = 100
    private let cacheExpiryDays = 7
    
    private init() {}
    
    struct CachedResponse: Codable {
        let question: String
        let answer: String
        let language: String
        let timestamp: Date
    }
    
    /// Generate cache key from question
    private func generateKey(question: String, language: String) -> String {
        let normalized = question.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[?!.,]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return "\(language)_\(normalized)"
    }
    
    /// Get cached response if available
    func get(question: String, language: String) -> CachedResponse? {
        guard let data = userDefaults.data(forKey: cacheKey),
              let cache = try? JSONDecoder().decode([String: CachedResponse].self, from: data) else {
            return nil
        }
        
        let key = generateKey(question: question, language: language)
        guard let cached = cache[key] else {
            return nil
        }
        
        // Check if expired
        let daysSince = Calendar.current.dateComponents([.day], from: cached.timestamp, to: Date()).day ?? 0
        if daysSince > cacheExpiryDays {
            // Expired
            return nil
        }
        
        print("💾 Cache hit! Question: \(question.prefix(30))...")
        return cached
    }
    
    /// Save response to cache
    func set(question: String, answer: String, language: String) {
        var cache: [String: CachedResponse] = [:]
        if let data = userDefaults.data(forKey: cacheKey),
           let existing = try? JSONDecoder().decode([String: CachedResponse].self, from: data) {
            cache = existing
        }
        
        let key = generateKey(question: question, language: language)
        cache[key] = CachedResponse(
            question: question,
            answer: answer,
            language: language,
            timestamp: Date()
        )
        
        // Enforce max cache size (simple LRU: remove oldest)
        if cache.count > maxCacheSize {
            let sorted = cache.sorted { $0.value.timestamp < $1.value.timestamp }
            let toRemove = sorted.prefix(cache.count - maxCacheSize)
            toRemove.forEach { cache.removeValue(forKey: $0.key) }
        }
        
        if let encoded = try? JSONEncoder().encode(cache) {
            userDefaults.set(encoded, forKey: cacheKey)
            print("💾 Response cached for: \(question.prefix(30))...")
        }
    }
    
    /// Clear all cached responses
    func clear() {
        userDefaults.removeObject(forKey: cacheKey)
        print("🗑️ Cache cleared")
    }
    
    /// Get cache statistics
    func getStats() -> (count: Int, oldestDays: Int) {
        guard let data = userDefaults.data(forKey: cacheKey),
              let cache = try? JSONDecoder().decode([String: CachedResponse].self, from: data) else {
            return (0, 0)
        }
        
        let oldest = cache.values.map { $0.timestamp }.min() ?? Date()
        let daysSince = Calendar.current.dateComponents([.day], from: oldest, to: Date()).day ?? 0
        
        return (cache.count, daysSince)
    }
}

// MARK: - Usage Tracking

/// Tracks API usage and savings
class UsageTracker {
    static let shared = UsageTracker()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    private let totalQuestionsKey = "ai_total_questions"
    private let apiCallsSavedKey = "ai_calls_saved"
    private let faqHitsKey = "ai_faq_hits"
    private let cacheHitsKey = "ai_cache_hits"
    
    var totalQuestions: Int {
        get { userDefaults.integer(forKey: totalQuestionsKey) }
        set { userDefaults.set(newValue, forKey: totalQuestionsKey) }
    }
    
    var apiCallsSaved: Int {
        get { userDefaults.integer(forKey: apiCallsSavedKey) }
        set { userDefaults.set(newValue, forKey: apiCallsSavedKey) }
    }
    
    var faqHits: Int {
        get { userDefaults.integer(forKey: faqHitsKey) }
        set { userDefaults.set(newValue, forKey: faqHitsKey) }
    }
    
    var cacheHits: Int {
        get { userDefaults.integer(forKey: cacheHitsKey) }
        set { userDefaults.set(newValue, forKey: cacheHitsKey) }
    }
    
    func recordQuestion() {
        totalQuestions += 1
    }
    
    func recordFAQHit() {
        apiCallsSaved += 1
        faqHits += 1
        print("💰 FAQ answer used! Total saved: \(apiCallsSaved)/\(totalQuestions)")
    }
    
    func recordCacheHit() {
        apiCallsSaved += 1
        cacheHits += 1
        print("💰 Cached answer used! Total saved: \(apiCallsSaved)/\(totalQuestions)")
    }
    
    func getStats() -> String {
        let savingsPercent = totalQuestions > 0 ? (Double(apiCallsSaved) / Double(totalQuestions) * 100) : 0
        return """
        📊 AI Support Statistics:
        Total Questions: \(totalQuestions)
        API Calls Saved: \(apiCallsSaved) (\(String(format: "%.1f", savingsPercent))%)
        FAQ Hits: \(faqHits)
        Cache Hits: \(cacheHits)
        """
    }
    
    func reset() {
        userDefaults.removeObject(forKey: totalQuestionsKey)
        userDefaults.removeObject(forKey: apiCallsSavedKey)
        userDefaults.removeObject(forKey: faqHitsKey)
        userDefaults.removeObject(forKey: cacheHitsKey)
    }
}
