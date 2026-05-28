import SwiftUI
import AVFoundation

struct VoiceSettingsView: View {
    @StateObject private var viewModel = VoiceSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                Picker("Voice Type", selection: $viewModel.preferredGender) {
                    Text("Female").tag(VoiceGender.female)
                    Text("Male").tag(VoiceGender.male)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("GENDER")
            } footer: {
                Text("Select the voice personality that feels most natural to you.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Speaking Speed")
                        Spacer()
                        Text(String(format: "%.0f%%", (viewModel.speechRate / 0.5) * 100))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $viewModel.speechRate, in: 0.4...0.6, step: 0.01)
                        .accentColor(.blue)
                    
                    HStack {
                        Text("Slower")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Normal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Faster")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Voice Pitch")
                        Spacer()
                        Text(String(format: "%.0f%%", viewModel.pitchMultiplier * 100))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $viewModel.pitchMultiplier, in: 0.8...1.2, step: 0.05)
                        .accentColor(.purple)
                    
                    HStack {
                        Text("Deeper")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Neutral")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Higher")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("SPEECH ADJUSTMENTS")
            } footer: {
                Text("Lower the speed to make the conversation easier to follow.")
            }
            
            Section {
                Button(action: {
                    viewModel.testCurrentVoice()
                }) {
                    HStack {
                        Image(systemName: viewModel.isTesting ? "stop.circle.fill" : "play.circle.fill")
                            .foregroundColor(.blue)
                        Text(viewModel.isTesting ? "Stop Test" : "Test Current Voice")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Voice Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    viewModel.saveSettings()
                    dismiss()
                }
            }
        }
    }
}

@MainActor
class VoiceSettingsViewModel: ObservableObject {
    @Published var preferredGender: VoiceGender = .female
    @Published var speechRate: Double = 0.53 // Default natural rate
    @Published var pitchMultiplier: Double = 1.0 // Default pitch
    @Published var isTesting = false
    
    private let synthesizer = AVSpeechSynthesizer()
    
    // Keys used by both VoiceSettingsView and VoiceAISupportView
    static let genderKey = "preferredVoiceGender"
    static let rateKey = "voiceSpeechRate"
    static let pitchKey = "voicePitchMultiplier"
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        if let genderString = UserDefaults.standard.string(forKey: Self.genderKey),
           let gender = VoiceGender(rawValue: genderString) {
            preferredGender = gender
        }
        
        let savedRate = UserDefaults.standard.double(forKey: Self.rateKey)
        speechRate = savedRate == 0 ? 0.53 : savedRate
        
        let savedPitch = UserDefaults.standard.double(forKey: Self.pitchKey)
        pitchMultiplier = savedPitch == 0 ? 1.0 : savedPitch
    }
    
    func saveSettings() {
        UserDefaults.standard.set(preferredGender.rawValue, forKey: Self.genderKey)
        UserDefaults.standard.set(speechRate, forKey: Self.rateKey)
        UserDefaults.standard.set(pitchMultiplier, forKey: Self.pitchKey)
        print("💾 Voice settings saved: Gender=\(preferredGender), Rate=\(speechRate), Pitch=\(pitchMultiplier)")
    }
    
    func testCurrentVoice() {
        if isTesting {
            synthesizer.stopSpeaking(at: .immediate)
            isTesting = false
            return
        }
        
        isTesting = true
        
        let testText = "Hello! I am your ShiftManager buddy. I hope you like my voice settings."
        let utterance = AVSpeechUtterance(string: testText)
        
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }
        let genderCode: AVSpeechSynthesisVoiceGender = (preferredGender == .female) ? .female : .male
        
        var voice: AVSpeechSynthesisVoice?
        if #available(iOS 16.0, *) {
            voice = voices.first { $0.gender == genderCode && ($0.quality == .premium || $0.quality == .enhanced) }
        } else {
            voice = voices.first { $0.gender == genderCode && $0.quality == .enhanced }
        }
        
        if voice == nil {
            voice = voices.first { $0.gender == genderCode }
        }
        
        utterance.voice = voice ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = Float(speechRate)
        utterance.pitchMultiplier = Float(pitchMultiplier)
        utterance.volume = 1.0
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.defaultToSpeaker])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        synthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.isTesting = false
        }
    }
}

enum VoiceGender: String, Codable, CaseIterable {
    case female = "female"
    case male = "male"
}
