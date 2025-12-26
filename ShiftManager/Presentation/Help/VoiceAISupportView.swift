import SwiftUI
import AVFoundation
import Speech

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
    
    private let apiKey = "AIzaSyAQZXciegzMpCz0wVzTa1N28Wm-aN4_Z5U"
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    let supportedLanguages = [
        SupportedLanguage(code: "en", name: "English", nativeName: "English", flag: "🇺🇸"),
        SupportedLanguage(code: "he", name: "Hebrew", nativeName: "עברית", flag: "🇮🇱"),
        SupportedLanguage(code: "ru", name: "Russian", nativeName: "Русский", flag: "🇷🇺"),
        SupportedLanguage(code: "fr", name: "French", nativeName: "Français", flag: "🇫🇷"),
        SupportedLanguage(code: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸"),
        SupportedLanguage(code: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪")
    ]
    
    private var systemPrompt: String {
        """
        You are the ShiftManager AI Support Assistant.
        
        CONTEXT (Use this to answer questions):
        \(AppKnowledgeBase.content)
        
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
        """
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
        
        isListening = false
        isPulsing = false
        statusText = "Ready to help"
    }
    
    private func startRecording() throws {
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
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
        statusText = "Processing..."
        
        Task {
            await sendToGemini(transcription)
        }
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
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let url = URL(string: "\(apiURL)?key=\(apiKey)") else {
            print("ERROR: Failed to create request")
            await MainActor.run {
                statusText = "Error creating request"
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("Sending request to: \(apiURL)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
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
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("❌ ERROR Response: \(errorDict)")
                    
                    if let error = errorDict["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        await MainActor.run {
                            statusText = "API Error: \(message)"
                        }
                    } else {
                        await MainActor.run {
                            statusText = "Failed to decode response"
                        }
                    }
                } else {
                    await MainActor.run {
                        statusText = "Invalid response format"
                    }
                }
            }
        } catch {
            print("❌ NETWORK ERROR: \(error.localizedDescription)")
            await MainActor.run {
                statusText = "Connection error: \(error.localizedDescription)"
            }
        }
        
        print("=== END GEMINI CALL ===")
    }
    
    struct AIResponse: Codable {
        let language: String
        let text: String
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
            responseText = jsonResponse.text
            print("✅ Parsed JSON: Lang=\(languageCode), Text=\(responseText)")
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
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private func speak(text: String, languageCode: String) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Ensure audio session is compatible with playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session for playback: \(error)")
        }
        
        synthesizer.speak(utterance)
    }
}

#Preview {
    VoiceAISupportView()
}
