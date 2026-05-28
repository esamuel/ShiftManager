import SwiftUI
import NaturalLanguage

struct SimplifiedAISupportView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AISupportViewModel()
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .tint(.purple)
                                    Text("Thinking... 🤔")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input bar
                HStack(spacing: 12) {
                    TextField("Ask me anything! 💬".localized, text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.send)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.isEmpty ? .gray : .purple)
                    }
                    .disabled(messageText.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("AI Support Agent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageText = ""
        viewModel.sendMessage(text)
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.isUser ? Color.purple : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)

                if !message.isUser, let source = message.source {
                    HStack(spacing: 6) {
                        Text(source)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .foregroundColor(sourceTextColor(for: source))
                            .background(sourceColor(for: source).opacity(0.18))
                            .overlay(
                                Capsule()
                                    .stroke(sourceColor(for: source).opacity(0.35), lineWidth: 0.8)
                            )
                            .clipShape(Capsule())

                        if let confidence = message.confidence {
                            Text("\(confidence)%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if !message.isUser { Spacer() }
        }
    }

    private func sourceColor(for source: String) -> Color {
        switch source.lowercased() {
        case "faq":
            return .green
        case "cache":
            return .blue
        case "ai":
            return .purple
        case "fallback":
            return .orange
        default:
            return .gray
        }
    }

    private func sourceTextColor(for source: String) -> Color {
        switch source.lowercased() {
        case "faq", "cache", "ai", "fallback":
            return sourceColor(for: source)
        default:
            return .secondary
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let source: String?
    let confidence: Int?
}

@MainActor
class AISupportViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private let apiKey = AIConfig.apiKey
    private let apiURLs = AIConfig.apiURLs
    private let proxyToken = AIConfig.proxyToken
    
    // System prompt is now centered in AIConfig to ensure consistency
    private let systemContext = AIConfig.systemPrompt

    private struct AssistantAnswer {
        let text: String
        let source: String
        let confidence: Int
    }

    private struct GuardedAIResponse: Codable {
        let language: String?
        let answer: String?
        let text: String?
        let confidence: Int?
        let needsClarification: Bool?
        let clarifyingQuestion: String?
    }
    
    func sendMessage(_ text: String) {
        messages.append(ChatMessage(text: text, isUser: true, source: nil, confidence: nil))
        isLoading = true
        
        Task {
            let response = await generateResponse(for: text)
            isLoading = false
            messages.append(
                ChatMessage(
                    text: response.text,
                    isUser: false,
                    source: response.source,
                    confidence: response.confidence
                )
            )
        }
    }
    
    private func generateResponse(for message: String) async -> AssistantAnswer {
        let language = detectLanguage(message)

        // AI-ONLY MODE: always call Gemini API for every question.
        UsageTracker.shared.recordQuestion()
        let prompt = """
        \(systemContext)

        STRICT KNOWLEDGE SOURCE (use this as ground truth):
        \(CanonicalSupportKnowledge.content)

        RULES FOR ACCURACY:
        1) Answer ONLY with features/actions that exist in ShiftManager.
        2) If the answer is not clearly in the knowledge above, say you are not sure and ask one short clarifying question.
        3) Do not invent screens, buttons, or capabilities.
        4) Keep the answer concise and in the user's language (\(language)).

        OUTPUT FORMAT (REQUIRED JSON ONLY):
        {
          "language": "\(language)",
          "answer": "final answer text in \(language)",
          "confidence": 0-100,
          "needsClarification": true/false,
          "clarifyingQuestion": "short follow-up question in \(language) if confidence is low"
        }

        HARD GUARD:
        - If confidence is below 70, set needsClarification=true and do NOT guess.
        - If needsClarification=true, answer field must be a brief "I'm not sure" style sentence + clarifyingQuestion.
        - Do not return markdown. Return JSON object only.

        User: \(message)
        """
        
        let payload: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            return AssistantAnswer(text: getFriendlyErrorMessage(for: message), source: "Fallback", confidence: 35)
        }

        do {
            let data = try await requestGeminiData(jsonData: jsonData)
            
            if let response = try? JSONDecoder().decode(GeminiAPIResponse.self, from: data),
               let text = response.candidates.first?.content.parts.first?.text {
                return resolveGuardedAnswer(from: text, userMessage: message, detectedLanguage: language)
            }
            
            // Check for API errors
            if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorResponse["error"] as? [String: Any],
               let errorMessage = error["message"] as? String {
                
                // Handle specific error types with friendly messages
                if errorMessage.contains("quota") || errorMessage.contains("limit") {
                    return AssistantAnswer(text: getQuotaExceededMessage(for: message), source: "Fallback", confidence: 30)
                }
                if errorMessage.lowercased().contains("api key") || errorMessage.contains("PERMISSION_DENIED") {
                    return AssistantAnswer(text: getAPIKeyIssueMessage(for: message), source: "Fallback", confidence: 20)
                }
                
                // For other errors, return friendly message
                return AssistantAnswer(text: getFriendlyErrorMessage(for: message), source: "Fallback", confidence: 35)
            }
        } catch let configError as AIConfigurationError {
            switch configError {
            case .missingCredentials, .invalidProxyURL:
                return AssistantAnswer(text: getConfigurationIssueMessage(for: message), source: "Fallback", confidence: 20)
            }
        } catch {
            // Network error - return friendly message
            return AssistantAnswer(text: getConnectionErrorMessage(for: message), source: "Fallback", confidence: 35)
        }
        
        // Fallback - couldn't process
        return AssistantAnswer(text: getFriendlyErrorMessage(for: message), source: "Fallback", confidence: 35)
    }

    private func requestGeminiData(jsonData: Data) async throws -> Data {
        var lastError: Error?

        if let proxyURL = AIConfig.proxyURL {
            guard let url = URL(string: proxyURL) else {
                throw AIConfigurationError.invalidProxyURL
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let proxyToken, !proxyToken.isEmpty {
                request.addValue("Bearer \(proxyToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = jsonData

            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        }

        guard !apiKey.isEmpty else {
            throw AIConfigurationError.missingCredentials
        }

        for endpoint in apiURLs {
            guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else { continue }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let http = response as? HTTPURLResponse, http.statusCode == 404 {
                    continue
                }
                return data
            } catch {
                lastError = error
            }
        }

        throw lastError ?? URLError(.badServerResponse)
    }

    private func resolveGuardedAnswer(from rawText: String, userMessage: String, detectedLanguage: String) -> AssistantAnswer {
        let cleanText = rawText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let data = cleanText.data(using: .utf8),
           let guarded = try? JSONDecoder().decode(GuardedAIResponse.self, from: data) {
            let confidence = max(0, min(100, guarded.confidence ?? 60))
            let needsClarification = guarded.needsClarification ?? (confidence < 70)

            if needsClarification || confidence < 70 {
                let clarify = guarded.clarifyingQuestion ?? getFriendlyErrorMessage(for: userMessage)
                let unsurePrefix = localizedUnsurePrefix(for: detectedLanguage)
                return AssistantAnswer(text: "\(unsurePrefix) \(clarify)", source: "AI", confidence: max(35, confidence))
            }

            let finalText = (guarded.answer ?? guarded.text ?? cleanText).trimmingCharacters(in: .whitespacesAndNewlines)
            return AssistantAnswer(text: finalText, source: "AI", confidence: confidence)
        }

        return AssistantAnswer(text: cleanText, source: "AI", confidence: 60)
    }

    private func localizedUnsurePrefix(for language: String) -> String {
        switch language {
        case "he": return "אני לא בטוח."
        case "ru": return "Я не уверен."
        case "fr": return "Je ne suis pas sûr."
        case "es": return "No estoy seguro."
        case "de": return "Ich bin mir nicht sicher."
        default: return "I'm not sure."
        }
    }
    
    // Helper function to detect language and return appropriate friendly error message
    private func getFriendlyErrorMessage(for message: String) -> String {
        let language = detectLanguage(message)
        
        switch language {
        case "he":
            return "🤔 אני לא בטוח שהבנתי. תוכל לשאול שאלה יותר ספציפית? למשל: 'איך אני מוסיף משמרת?' או 'מה זה פרימיום?'"
        case "ru":
            return "🤔 Я не совсем понял. Можете задать более конкретный вопрос? Например: 'Как добавить смену?' или 'Что такое премиум?'"
        case "fr":
            return "🤔 Je ne suis pas sûr de comprendre. Pouvez-vous poser une question plus précise? Par exemple: 'Comment ajouter un quart?' ou 'Qu'est-ce que Premium?'"
        case "es":
            return "🤔 No estoy seguro de entender. ¿Puedes hacer una pregunta más específica? Por ejemplo: '¿Cómo agrego un turno?' o '¿Qué es Premium?'"
        case "de":
            return "🤔 Ich bin mir nicht sicher, ob ich verstehe. Können Sie eine spezifischere Frage stellen? Zum Beispiel: 'Wie füge ich eine Schicht hinzu?' oder 'Was ist Premium?'"
        default: // English
            return "🤔 I'm not sure I understood that. Could you ask a more specific question? For example: 'How do I add a shift?' or 'What is Premium?'"
        }
    }
    
    private func getQuotaExceededMessage(for message: String) -> String {
        let language = detectLanguage(message)
        
        switch language {
        case "he":
            return "⏳ הגעתי למגבלה היומית שלי. נסה שוב מחר, או בדוק את ההגדרות לעזרה!"
        case "ru":
            return "⏳ Я достиг своего дневного лимита. Попробуйте завтра или проверьте Настройки для помощи!"
        case "fr":
            return "⏳ J'ai atteint ma limite quotidienne. Réessayez demain ou consultez les Paramètres pour obtenir de l'aide!"
        case "es":
            return "⏳ He alcanzado mi límite diario. ¡Inténtalo mañana o consulta Configuración para obtener ayuda!"
        case "de":
            return "⏳ Ich habe mein Tageslimit erreicht. Versuchen Sie es morgen erneut oder überprüfen Sie die Einstellungen für Hilfe!"
        default:
            return "⏳ I've reached my daily limit. Try again tomorrow, or check Settings for help!"
        }
    }
    
    private func getConnectionErrorMessage(for message: String) -> String {
        let language = detectLanguage(message)
        
        switch language {
        case "he":
            return "📡 אין חיבור לאינטרנט. בדוק את החיבור שלך ונסה שוב!"
        case "ru":
            return "📡 Нет подключения к интернету. Проверьте соединение и попробуйте снова!"
        case "fr":
            return "📡 Pas de connexion Internet. Vérifiez votre connexion et réessayez!"
        case "es":
            return "📡 Sin conexión a Internet. ¡Verifica tu conexión e inténtalo de nuevo!"
        case "de":
            return "📡 Keine Internetverbindung. Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut!"
        default:
            return "📡 No internet connection. Check your connection and try again!"
        }
    }

    private func getAPIKeyIssueMessage(for message: String) -> String {
        let language = detectLanguage(message)
        switch language {
        case "he":
            return "שירות ה-AI לא זמין כרגע בגלל מפתח API לא תקין. יש לעדכן מפתח חדש בהגדרות המפתח של האפליקציה."
        case "ru":
            return "Сервис AI временно недоступен из-за недействительного API-ключа. Обновите ключ в настройках приложения."
        case "fr":
            return "Le service IA est indisponible en raison d'une clé API invalide. Mettez à jour la clé dans la configuration de l'application."
        case "es":
            return "El servicio de IA no está disponible por una clave API inválida. Actualiza la clave en la configuración de la app."
        case "de":
            return "Der KI-Dienst ist wegen eines ungültigen API-Schlüssels nicht verfügbar. Aktualisieren Sie den Schlüssel in der App-Konfiguration."
        default:
            return "AI service is unavailable due to an invalid API key. Please update the app's API key configuration."
        }
    }

    private func getConfigurationIssueMessage(for message: String) -> String {
        let language = detectLanguage(message)
        switch language {
        case "he":
            return "שירות ה-AI לא מוגדר כרגע. יש להגדיר AI_PROXY_URL (מומלץ) או GEMINI_API_KEY בקונפיגורציה."
        case "ru":
            return "Сервис AI сейчас не настроен. Укажите AI_PROXY_URL (рекомендуется) или GEMINI_API_KEY в конфигурации."
        case "fr":
            return "Le service IA n'est pas configuré. Configurez AI_PROXY_URL (recommandé) ou GEMINI_API_KEY."
        case "es":
            return "El servicio de IA no está configurado. Configura AI_PROXY_URL (recomendado) o GEMINI_API_KEY."
        case "de":
            return "Der KI-Dienst ist nicht konfiguriert. Bitte AI_PROXY_URL (empfohlen) oder GEMINI_API_KEY setzen."
        default:
            return "AI service is not configured. Set AI_PROXY_URL (recommended) or GEMINI_API_KEY in app configuration."
        }
    }
    
    // Simple language detection based on common words/characters
    private func detectLanguage(_ text: String) -> String {
        if text.range(of: "[א-ת]", options: .regularExpression) != nil { return "he" }
        if text.range(of: "[а-яА-Я]", options: .regularExpression) != nil { return "ru" }

        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        switch recognizer.dominantLanguage {
        case .french: return "fr"
        case .spanish: return "es"
        case .german: return "de"
        case .russian: return "ru"
        case .hebrew: return "he"
        default: return "en"
        }
    }
}

// Response Models
struct GeminiAPIResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

#Preview {
    SimplifiedAISupportView()
}
