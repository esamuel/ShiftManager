import SwiftUI
import AVFoundation
import Speech
import NaturalLanguage

struct VoiceAISupportView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VoiceAISupportViewModel()
    @State private var showingLanguageSelector = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.11, blue: 0.29), Color(red: 0.06, green: 0.09, blue: 0.16)],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("AI Support Agent")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Multilingual Voice Assistant")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Language Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.supportedLanguages) { lang in
                                Button(action: {
                                    viewModel.setLanguage(lang.code)
                                }) {
                                    HStack {
                                        Text(lang.flag)
                                        Text(lang.nativeName)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(viewModel.selectedLanguageCode == lang.code ? Color.blue : Color.white.opacity(0.1))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Response Card
                    ScrollView {
                        if viewModel.currentResponse.isEmpty {
                            // Empty State / Welcome
                            VStack(spacing: 16) {
                                Image(systemName: "waveform.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("Tap Start and ask a question in any language")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            // Show Response
                            ForEach(Array(viewModel.currentResponse.keys), id: \.self) { langCode in
                                let responseText = viewModel.currentResponse[langCode] ?? ""
                                let language = viewModel.supportedLanguages.first(where: { $0.code == langCode })
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(language?.flag ?? "🌐")
                                            .font(.title)
                                        Text(language?.nativeName ?? langCode.uppercased())
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    
                                    Text(responseText)
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .lineSpacing(6)
                                }
                                .padding(24)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Main Control Button
                    VStack(spacing: 16) {
                        ZStack {
                            // Pulse rings when active
                            if viewModel.isListening {
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                    .frame(width: 180, height: 180)
                                    .scaleEffect(viewModel.isPulsing ? 1.3 : 1.0)
                                    .opacity(viewModel.isPulsing ? 0 : 1)
                                    .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: viewModel.isPulsing)
                            }
                            
                            Button(action: {
                                viewModel.toggleSession()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(viewModel.isListening ? Color.red : Color.blue)
                                        .frame(width: 140, height: 140)
                                        .shadow(color: (viewModel.isListening ? Color.red : Color.blue).opacity(0.4), radius: 20)
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: viewModel.isListening ? "stop.circle.fill" : "mic.circle.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                        
                                        Text(viewModel.isListening ? "Stop" : "Start")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .textCase(.uppercase)
                                    }
                                }
                            }
                            .rotationEffect(.degrees(viewModel.isListening ? 180 : 0))
                            .animation(.spring(response: 0.6), value: viewModel.isListening)
                        }
                        
                        // Status text
                        Text(viewModel.statusText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Show current transcription
                        if !viewModel.currentTranscription.isEmpty {
                            Text(viewModel.currentTranscription)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            
                            Button(action: {
                                viewModel.sendCurrentTranscription()
                            }) {
                                Text("Send Question")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .cornerRadius(25)
                            }
                        } else {
                            Text(viewModel.isListening ? "Speak in any language" : "Tap to start")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        viewModel.stopSession()
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                viewModel.requestPermissions()
            }
        }
    }
}

struct LanguageCardView: View {
    let language: SupportedLanguage
    let isActive: Bool
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(language.flag)
                    .font(.title2)
                Text(language.nativeName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                if isActive {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
            
            if !text.isEmpty {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
            } else {
                Text("Waiting...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .italic()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isActive ? 0.15 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(isActive ? 0.3 : 0.1), lineWidth: 1)
                )
        )
    }
}

struct SupportedLanguage: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let nativeName: String
    let flag: String
}

@MainActor
class VoiceAISupportViewModel: ObservableObject {
    @Published var isListening = false
    @Published var isPulsing = false
    @Published var statusText = "Ready to help"
    @Published var currentResponse: [String: String] = [:]
    @Published var currentTranscription = ""
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let apiKey = AIConfig.apiKey
    private let apiURLs = AIConfig.apiURLs
    private let proxyToken = AIConfig.proxyToken
    
    let supportedLanguages = [
        SupportedLanguage(code: "en", name: "English", nativeName: "English", flag: "🇺🇸"),
        SupportedLanguage(code: "he", name: "Hebrew", nativeName: "עברית", flag: "🇮🇱"),
        SupportedLanguage(code: "ru", name: "Russian", nativeName: "Русский", flag: "🇷🇺"),
        SupportedLanguage(code: "fr", name: "French", nativeName: "Français", flag: "🇫🇷"),
        SupportedLanguage(code: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸"),
        SupportedLanguage(code: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪")
    ]
    
    private var systemPrompt: String {
        var basePrompt = AIConfig.systemPrompt
        basePrompt += "\n\nSTRICT KNOWLEDGE SOURCE (use this as ground truth):\n"
        basePrompt += CanonicalSupportKnowledge.content
        basePrompt += "\n\nACCURACY RULES:\n"
        basePrompt += "1. Answer ONLY with features/actions that exist in ShiftManager.\n"
        basePrompt += "2. If not sure, explicitly say you are not sure and ask one clarifying question.\n"
        basePrompt += "3. Do NOT invent buttons, tabs, or capabilities.\n"
        
        // Add voice-specific instructions
        basePrompt += "\n\nVOICE SPECIFIC INSTRUCTIONS:\n"
        basePrompt += "1. Return JSON only with fields: \"language\", \"text\", \"confidence\", \"needsClarification\", \"clarifyingQuestion\".\n"
        basePrompt += "2. Keep text super concise (1-2 sentences max) for voice.\n"
        basePrompt += "3. HARD GUARD: if confidence < 70, set needsClarification=true and do NOT guess.\n"
        basePrompt += "4. If needsClarification=true, \"text\" must be a short \"I'm not sure\" sentence + one clarifying question.\n"
        basePrompt += "5. Do NOT wrap JSON in markdown blocks."
        
        return basePrompt
    }
    
    @Published var selectedLanguageCode: String = Locale.current.languageCode ?? "en"
    
    // ... prompt ...
    
    init() {
        // Initialize with default/device language
        let deviceLanguage = Locale.current.languageCode ?? "en"
        selectedLanguageCode = deviceLanguage
        setupRecognizer(languageCode: deviceLanguage)
    }
    
    func setLanguage(_ code: String) {
        selectedLanguageCode = code
        setupRecognizer(languageCode: code)
        statusText = "Language set to \(supportedLanguages.first(where: { $0.code == code })?.name ?? code)"
    }
    
    private func setupRecognizer(languageCode: String) {
        // Map our codes to iOS Locale identifiers
        let localeIdentifier: String
        switch languageCode {
        case "en": localeIdentifier = "en-US"
        case "he": localeIdentifier = "he-IL"
        case "ru": localeIdentifier = "ru-RU"
        case "fr": localeIdentifier = "fr-FR"
        case "es": localeIdentifier = "es-ES"
        case "de": localeIdentifier = "de-DE"
        default: localeIdentifier = "en-US"
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        print("Speech Recognizer set to: \(localeIdentifier)")
    }
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.statusText = "Ready to help"
                case .denied:
                    self?.statusText = "Speech recognition denied"
                case .restricted:
                    self?.statusText = "Speech recognition restricted"
                case .notDetermined:
                    self?.statusText = "Speech recognition not determined"
                @unknown default:
                    self?.statusText = "Unknown authorization status"
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if !granted {
                    self?.statusText = "Microphone access denied"
                }
            }
        }
    }
    
    func toggleSession() {
        if isListening {
            stopSession()
        } else {
            startSession()
        }
    }
    
    func startSession() {
        guard !audioEngine.isRunning else { return }
        
        // Reset responses and transcription
        currentResponse = [:]
        currentTranscription = ""
        
        do {
            try startRecording()
            isListening = true
            isPulsing = true
            statusText = "Listening..."
        } catch {
            statusText = "Error: \(error.localizedDescription)"
            print("Recording error: \(error)")
        }
    }
    
    func stopSession() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        // Deactivate audio session to allow clean transition to playback
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("🔇 Recording session deactivated")
        } catch {
            print("⚠️ Failed to deactivate recording session: \(error.localizedDescription)")
        }
        
        isListening = false
        isPulsing = false
        statusText = "Ready to help"
    }
    
    private func startRecording() throws {
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session with robust error handling
        let audioSession = AVAudioSession.sharedInstance()
        
        // Strategy: Try multiple approaches in order of preference
        var sessionActivated = false
        var lastError: Error?
        
        // APPROACH 1: Try with clean slate (deactivate first)
        do {
            // Only deactivate if there's an active session
            // Trying to deactivate an inactive session can cause errors
            if audioSession.isOtherAudioPlaying == false {
                do {
                    try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                    print("🔇 Deactivated previous audio session")
                    Thread.sleep(forTimeInterval: 0.05)
                } catch {
                    // Ignore deactivation errors - session might not be active
                    print("ℹ️ Session deactivation skipped: \(error.localizedDescription)")
                }
            }
            
            // Configure for recording
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            sessionActivated = true
            print("✅ Recording session activated (approach 1)")
            
        } catch let error {
            lastError = error
            print("⚠️ Approach 1 failed: \(error.localizedDescription)")
        }
        
        // APPROACH 2: Try with .playAndRecord category (more flexible)
        if !sessionActivated {
            do {
                try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth, .duckOthers])
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                
                sessionActivated = true
                print("✅ Recording session activated (approach 2 - playAndRecord)")
                
            } catch let error {
                lastError = error
                print("⚠️ Approach 2 failed: \(error.localizedDescription)")
            }
        }
        
        // APPROACH 3: Try without deactivating, just override
        if !sessionActivated {
            do {
                try audioSession.setCategory(.record, mode: .default, options: [])
                try audioSession.setActive(true, options: [])
                
                sessionActivated = true
                print("✅ Recording session activated (approach 3 - simple override)")
                
            } catch let error {
                lastError = error
                print("⚠️ Approach 3 failed: \(error.localizedDescription)")
            }
        }
        
        // If all approaches failed, throw the last error
        if !sessionActivated {
            print("❌ All audio session activation approaches failed")
            throw lastError ?? NSError(domain: "VoiceAI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to activate audio session"])
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "VoiceAI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create request"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Ensure we have a speech recognizer
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw NSError(domain: "VoiceAI", code: 2, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available"])
        }
        
        let inputNode = audioEngine.inputNode
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let transcription = result.bestTranscription.formattedString
                let isFinal = result.isFinal
                
                // Update UI with partial transcription
                Task { @MainActor in
                    self.currentTranscription = transcription
                }
                
                print("Transcription: \(transcription), isFinal: \(isFinal)")
                
                // Don't auto-send on final - let user tap Send button
            }
            
            if error != nil {
                print("Recognition error: \(String(describing: error))")
                Task { @MainActor in
                    self.stopSession()
                }
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        print("Audio engine started successfully")
    }
    
    func sendCurrentTranscription() {
        let transcription = currentTranscription
        guard !transcription.isEmpty else { return }
        
        stopSession()
        
        Task {
            await processQuestion(transcription)
        }
    }
    
    /// Process user question with 3-tier strategy
    /// AI-only mode: always call Gemini API for every question.
    private func processQuestion(_ userQuestion: String) async {
        // Track statistics
        UsageTracker.shared.recordQuestion()

        // Always use AI for the final answer.
        await MainActor.run {
            statusText = "Asking AI..."
        }
        await sendToGemini(userQuestion)
    }
    
    private func sendToGemini(_ userQuestion: String) async {
        print("=== SENDING TO GEMINI ===")
        print("Question: \(userQuestion)")
        
        let prompt = "\(systemPrompt)\n\nUser Question: \(userQuestion)"
        print("Full prompt length: \(prompt.count) characters")
        
        let payload: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("ERROR: Failed to create request")
            await MainActor.run {
                statusText = "Error creating request"
            }
            return
        }

        print("Sending request to AI endpoint list")
        
        do {
            let (data, response) = try await requestGeminiData(jsonData: jsonData)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status: \(httpResponse.statusCode)")
            }
            
            // Try to print raw response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response: \(rawResponse)")
            }
            
            // Try to decode success response
            if let geminiResponse = try? JSONDecoder().decode(GeminiAPIResponse.self, from: data),
               let fullText = geminiResponse.candidates.first?.content.parts.first?.text {
                print("✅ SUCCESS - Gemini response received")
                print("Response text: \(fullText)")
                
                await MainActor.run {
                    parseMultilingualResponse(fullText)
                    statusText = "Response received"
                }
            } else {
                // Try to decode error
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorDict["error"] as? [String: Any] {
                    print("❌ ERROR Response: \(errorDict)")
                    
                    let code = error["code"] as? Int ?? 0
                    let status = error["status"] as? String ?? ""
                    let message = error["message"] as? String ?? "Unknown error"
                    
                    await MainActor.run {
                        // Handle errors by speaking a friendly help message instead of a technical error
                        let fallbackMessage: String
                        if status == "PERMISSION_DENIED" || message.lowercased().contains("api key") || code == 403 {
                            fallbackMessage = getAPIKeyIssueMessage(for: userQuestion)
                        } else {
                            fallbackMessage = getFriendlyFallback(for: userQuestion)
                        }
                        statusText = "Please be more specific"
                        speak(text: fallbackMessage, languageCode: detectLanguage(userQuestion))
                        print("🤖 AI Fallback: \(fallbackMessage)")
                    }
                } else {
                    await MainActor.run {
                        let fallbackMessage = getFriendlyFallback(for: userQuestion)
                        statusText = "Please be more specific"
                        speak(text: fallbackMessage, languageCode: detectLanguage(userQuestion))
                    }
                }
            }
        } catch let configError as AIConfigurationError {
            print("❌ CONFIG ERROR: \(configError)")
            await MainActor.run {
                let fallbackMessage = getConfigurationIssueMessage(for: userQuestion)
                statusText = "AI not configured"
                speak(text: fallbackMessage, languageCode: detectLanguage(userQuestion))
            }
        } catch {
            print("❌ NETWORK ERROR: \(error.localizedDescription)")
            await MainActor.run {
                let fallbackMessage = getFriendlyFallback(for: userQuestion)
                statusText = "Connection issue"
                speak(text: fallbackMessage, languageCode: detectLanguage(userQuestion))
            }
        }
        
        print("=== END GEMINI CALL ===")
    }

    private func requestGeminiData(jsonData: Data) async throws -> (Data, URLResponse) {
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

            return try await URLSession.shared.data(for: request)
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
                return (data, response)
            } catch {
                lastError = error
            }
        }

        throw lastError ?? URLError(.badServerResponse)
    }
    
    // Helper to provide a friendly spoken response when Gemini fails or provides an error
    private func getFriendlyFallback(for message: String) -> String {
        let language = detectLanguage(message)
        
        switch language {
        case "he":
            return "אני לא בטוח שהבנתי. תוכל לשאול שאלה יותר ספציפית? למשל: איך אני מוסיף משמרת?"
        case "ru":
            return "Я не совсем понял. Можете задать более конкретный вопрос? Например: Как добавить смену?"
        case "fr":
            return "Je ne suis pas sûr de comprendre. Pouvez-vous poser une question plus précise? Par exemple: Comment ajouter un quart?"
        case "es":
            return "No estoy seguro de entender. ¿Puedes hacer una pregunta más específica? Por ejemplo: ¿Cómo agrego un turno?"
        case "de":
            return "Ich bin mir nicht sicher, ob ich verstehe. Können Sie eine spezifischere Frage stellen? Zum Beispiel: Wie füge ich eine Schicht hinzu?"
        default: // English
            return "I'm not sure I understood that. Could you ask a more specific question? For example: How do I add a shift?"
        }
    }

    private func getAPIKeyIssueMessage(for message: String) -> String {
        let language = detectLanguage(message)
        switch language {
        case "he":
            return "שירות ה-AI לא זמין כרגע בגלל מפתח API לא תקין. צריך לעדכן מפתח חדש."
        case "ru":
            return "Сервис AI временно недоступен из-за недействительного API-ключа. Нужно обновить ключ."
        case "fr":
            return "Le service IA est indisponible en raison d'une clé API invalide. Veuillez mettre à jour la clé."
        case "es":
            return "El servicio de IA no está disponible por una clave API inválida. Hay que actualizar la clave."
        case "de":
            return "Der KI-Dienst ist wegen eines ungültigen API-Schlüssels nicht verfügbar. Bitte aktualisieren Sie den Schlüssel."
        default:
            return "AI service is unavailable due to an invalid API key. Please update the key."
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
    
    // Simple language detection for the fallback system
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
    
    struct AIResponse: Codable {
        let language: String
        let text: String
        let confidence: Int?
        let needsClarification: Bool?
        let clarifyingQuestion: String?
    }
    
    private func parseMultilingualResponse(_ rawText: String) {
        var responseText = rawText
        var languageCode = Locale.current.languageCode ?? "en"
        
        // Clean up markdown code blocks if present (e.g. ```json ... ```)
        let cleanText = rawText.replacingOccurrences(of: "```json", with: "")
                               .replacingOccurrences(of: "```", with: "")
                               .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let data = cleanText.data(using: .utf8),
           let jsonResponse = try? JSONDecoder().decode(AIResponse.self, from: data) {
            languageCode = jsonResponse.language.lowercased()
            let parsedConfidence = max(0, min(100, jsonResponse.confidence ?? 60))
            let needsClarification = jsonResponse.needsClarification ?? (parsedConfidence < 70)

            if needsClarification || parsedConfidence < 70 {
                let fallbackClarify = localizedUnsurePrefix(for: languageCode)
                let question = jsonResponse.clarifyingQuestion?.trimmingCharacters(in: .whitespacesAndNewlines)
                if let question, !question.isEmpty {
                    responseText = "\(fallbackClarify) \(question)"
                } else {
                    responseText = getFriendlyFallback(for: responseText)
                }
                statusText = "Need clarification"
            } else {
                responseText = jsonResponse.text
            }
            print("✅ Parsed JSON: Lang=\(languageCode), confidence=\(parsedConfidence), needsClarification=\(needsClarification)")
        } else {
            print("⚠️ Failed to parse JSON, falling back to raw text path")
            // Try to rescue if it's just the prefix format from before
             let pattern = "^\\[([a-zA-Z]{2})\\]\\s*(.*)"
             if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
                let match = regex.firstMatch(in: rawText, range: NSRange(rawText.startIndex..., in: rawText)) {
                 if let langRange = Range(match.range(at: 1), in: rawText),
                    let textRange = Range(match.range(at: 2), in: rawText) {
                     languageCode = String(rawText[langRange]).lowercased()
                     responseText = String(rawText[textRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                 }
             }
        }
        
        // Update UI
        currentResponse = [languageCode: responseText]
        
        // Speak
        speak(text: responseText, languageCode: languageCode)
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
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private func speak(text: String, languageCode: String) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Clean up text for better speech (remove emojis for cleaner pronunciation)
        let cleanedText = text.replacingOccurrences(of: "[\\p{Emoji_Presentation}\\p{Emoji}\\u{FE0F}]", with: "", options: .regularExpression)
        
        let utterance = AVSpeechUtterance(string: cleanedText)
        
        let targetLanguage = mapLanguageCode(languageCode)
        
        // Get the best quality voice for each language
        var selectedVoice: AVSpeechSynthesisVoice?
        
        // STEP 1: Try to get the absolute best premium voices by specific identifiers
        // These are the most natural-sounding voices on iOS
        let premiumVoiceIdentifiers: [String] = {
            switch languageCode.lowercased() {
            case "en":
                // English: Samantha (Premium), Ava (Enhanced), or other premium voices
                return [
                    "com.apple.voice.premium.en-US.Zoe",      // Premium female (very natural)
                    "com.apple.voice.enhanced.en-US.Ava",     // Enhanced female
                    "com.apple.voice.premium.en-US.Samantha", // Premium female (classic)
                    "com.apple.voice.enhanced.en-US.Nicky",   // Enhanced male
                    "com.apple.ttsbundle.Samantha-premium"    // Alternative identifier
                ]
            case "he":
                // Hebrew: Carmit (Premium)
                return [
                    "com.apple.voice.premium.he-IL.Carmit",   // Premium female
                    "com.apple.voice.enhanced.he-IL.Carmit",  // Enhanced female
                    "com.apple.ttsbundle.Carmit-premium"      // Alternative identifier
                ]
            case "ru":
                // Russian: Milena (Premium), Yuri (Male)
                return [
                    "com.apple.voice.premium.ru-RU.Milena",   // Premium female
                    "com.apple.voice.enhanced.ru-RU.Milena",  // Enhanced female
                    "com.apple.voice.premium.ru-RU.Yuri",     // Premium male
                    "com.apple.ttsbundle.Milena-premium"      // Alternative identifier
                ]
            case "fr":
                // French: Amelie (Premium), Thomas (Male)
                return [
                    "com.apple.voice.premium.fr-FR.Amelie",   // Premium female
                    "com.apple.voice.enhanced.fr-FR.Thomas",  // Enhanced male
                    "com.apple.voice.premium.fr-FR.Thomas",   // Premium male
                    "com.apple.ttsbundle.Amelie-premium"      // Alternative identifier
                ]
            case "es":
                // Spanish: Monica (Premium), Paulina (Mexico)
                return [
                    "com.apple.voice.premium.es-ES.Monica",   // Premium female (Spain)
                    "com.apple.voice.enhanced.es-ES.Monica",  // Enhanced female
                    "com.apple.voice.premium.es-MX.Paulina",  // Premium female (Mexico)
                    "com.apple.ttsbundle.Monica-premium"      // Alternative identifier
                ]
            case "de":
                // German: Anna (Premium), Markus (Male)
                return [
                    "com.apple.voice.premium.de-DE.Anna",     // Premium female
                    "com.apple.voice.enhanced.de-DE.Anna",    // Enhanced female
                    "com.apple.voice.premium.de-DE.Markus",   // Premium male
                    "com.apple.ttsbundle.Anna-premium"        // Alternative identifier
                ]
            default:
                return []
            }
        }()
        
        // STEP 1: Search by quality AND user gender preference
        // Priority 1: Premium/Enhanced quality voices with matching gender
        // Priority 2: Standard quality voices with matching gender
        // Priority 3: Fallback to best available
        
        let preferredGenderString = UserDefaults.standard.string(forKey: "preferredVoiceGender") ?? "female"
        let preferredGender: AVSpeechSynthesisVoiceGender = (preferredGenderString == "male") ? .male : .female
        
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        let languageVoices = availableVoices.filter { voice in
            voice.language.hasPrefix(targetLanguage.prefix(2))
        }
        
        // Priority 1: Premium/Enhanced voices of PREFERRED gender
        if #available(iOS 16.0, *) {
            selectedVoice = languageVoices.first { voice in
                (voice.quality == .premium || voice.quality == .enhanced) && voice.gender == preferredGender
            }
        }
        
        // Priority 2: Any voice of PREFERRED gender
        if selectedVoice == nil {
            if #available(iOS 13.0, *) {
                selectedVoice = languageVoices.first { voice in
                    voice.gender == preferredGender
                }
            }
        }
        
        // Priority 3: Try specifically by previous premium identifiers (legacy fallback)
        if selectedVoice == nil {
            for identifier in premiumVoiceIdentifiers {
                if let voice = AVSpeechSynthesisVoice(identifier: identifier) {
                    selectedVoice = voice
                    break
                }
            }
        }
        
        // Priority 4: Any premium/enhanced voice regardless of gender
        if selectedVoice == nil {
            if #available(iOS 16.0, *) {
                selectedVoice = languageVoices.first { voice in
                    voice.quality == .premium || voice.quality == .enhanced
                }
            }
        }
        
        // Priority 5: Any voice at all for the language
        if selectedVoice == nil {
            selectedVoice = languageVoices.first
        }
        
        // STEP 3: Fallback to default voice for language
        if selectedVoice == nil {
            selectedVoice = AVSpeechSynthesisVoice(language: targetLanguage)
        }
        
        utterance.voice = selectedVoice
        
        // USER CUSTOMIZED SPEECH PARAMETERS
        // Rate: Loaded from settings, default to 0.53
        let savedRate = UserDefaults.standard.double(forKey: "voiceSpeechRate")
        utterance.rate = Float(savedRate == 0 ? 0.53 : savedRate)
        
        // Pitch: Loaded from settings, default to 1.0
        let savedPitch = UserDefaults.standard.double(forKey: "voicePitchMultiplier")
        utterance.pitchMultiplier = Float(savedPitch == 0 ? 1.0 : savedPitch)
        
        // Volume: Full but not overwhelming
        utterance.volume = 0.95
        
        // Pre-utterance delay: Small pause before speaking (more natural)
        utterance.preUtteranceDelay = 0.1
        
        // Post-utterance delay: Small pause after speaking
        utterance.postUtteranceDelay = 0.05
        
        // Log voice details
        if let voice = selectedVoice {
            print("🎙️ Using voice: \(voice.name) (\(voice.language))")
            print("   Identifier: \(voice.identifier)")
            if #available(iOS 16.0, *) {
                print("   Quality: \(voice.quality.rawValue)")
            }
            if #available(iOS 13.0, *) {
                print("   Gender: \(voice.gender.rawValue)")
            }
        }
        
        
        // Configure audio session for optimal playback quality
        // Use .playAndRecord to support both playback and future recording
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Configure for playback with optimal settings
            // .playAndRecord allows both recording and playback (prevents conflicts)
            // .defaultToSpeaker ensures it plays through speaker, not earpiece
            // .allowBluetooth enables AirPods and other Bluetooth devices
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            
            // Activate the session for playback (will override recording session if active)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("✅ Audio session configured for high-quality playback")
        } catch {
            print("⚠️ Failed to configure audio session: \(error.localizedDescription)")
            // Continue anyway - synthesizer might still work with current session
        }
        
        // Speak the utterance
        synthesizer.speak(utterance)
        print("🗣️ Speaking: \"\(cleanedText)\"")
    }
    
    // Helper function to map language codes to full locale identifiers
    private func mapLanguageCode(_ code: String) -> String {
        switch code.lowercased() {
        case "en": return "en-US"
        case "he": return "he-IL"
        case "ru": return "ru-RU"
        case "fr": return "fr-FR"
        case "es": return "es-ES"
        case "de": return "de-DE"
        default: return code
        }
    }
}

#Preview {
    VoiceAISupportView()
}
