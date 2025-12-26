import SwiftUI

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
                                    Text("Thinking...")
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
                    TextField("Ask me anything...".localized, text: $messageText)
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
            }
            
            if !message.isUser { Spacer() }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

@MainActor
class AISupportViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private let apiKey = "AIzaSyAQZXciegzMpCz0wVzTa1N28Wm-aN4_Z5U"
    private let apiURL = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent"
    
    private let systemContext = """
    You are the ShiftsManager AI Support Assistant. Answer questions about the ShiftsManager app naturally and helpfully.
    
    Key Features:
    - Shift Tracking: Add, edit, delete shifts with start/end times
    - Wage Calculation: Automatic gross/net pay calculation
    - Overtime: Multiple tiers (125%, 150%) in Settings > Overtime Rules
    - Reports: Visual charts, monthly summaries
    - Export: PDF export (Premium feature)
    - iCloud Sync: Backup across Apple devices
    - Notifications: Reminders for upcoming shifts
    - Pricing: Free (up to 50 shifts), Premium Lifetime ($14.99), Annual ($9.99)
    - Privacy: No data collection, local storage only
    
    Always respond in the same language the user asks in. Be concise and helpful.
    """
    
    func sendMessage(_ text: String) {
        messages.append(ChatMessage(text: text, isUser: true))
        isLoading = true
        
        Task {
            let response = await generateResponse(for: text)
            isLoading = false
            messages.append(ChatMessage(text: response, isUser: false))
        }
    }
    
    private func generateResponse(for message: String) async -> String {
        let prompt = "\(systemContext)\n\nUser: \(message)"
        
        let payload: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let url = URL(string: "\(apiURL)?key=\(apiKey)") else {
            return "Error formatting request"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let response = try? JSONDecoder().decode(GeminiAPIResponse.self, from: data),
               let text = response.candidates.first?.content.parts.first?.text {
                return text
            }
            
            if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorResponse["error"] as? [String: Any],
               let errorMessage = error["message"] as? String {
                return "Error: \(errorMessage)"
            }
        } catch {
            return "Connection error: \(error.localizedDescription)"
        }
        
        return "Sorry, I couldn't process that request."
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
