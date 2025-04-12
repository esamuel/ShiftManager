import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Hourly Wage")
                        Spacer()
                        TextField("0.00", value: $viewModel.hourlyWage, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Tax Deduction (%)")
                        Spacer()
                        TextField("0.00", value: $viewModel.taxDeduction, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                    }
                }
                
                Section {
                    HStack {
                        Text("Base Hours (Weekday)")
                        Spacer()
                        TextField("8", value: $viewModel.baseHoursWeekday, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Base Hours (Special Day)")
                        Spacer()
                        TextField("8", value: $viewModel.baseHoursSpecialDay, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section {
                    Toggle("Start work on Sunday", isOn: $viewModel.startWorkOnSunday)
                    Toggle("Dark Mode", isOn: $viewModel.darkMode)
                }
                
                Section {
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        ForEach(Language.allCases) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    }
                    
                    Picker("Country", selection: $viewModel.selectedCountry) {
                        ForEach(Country.allCases) { country in
                            Text(country.displayName)
                                .tag(country)
                        }
                    }
                }
                
                Section {
                    Button(action: viewModel.saveSettings) {
                        Text("Save Settings")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.purple)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .alert("Settings Saved", isPresented: $viewModel.showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

// MARK: - Supporting Types
enum Language: String, CaseIterable, Identifiable {
    case english
    case hebrew
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .hebrew: return "Hebrew"
        }
    }
}

enum Country: String, CaseIterable, Identifiable {
    case israel
    case usa
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .israel: return "Israel (ILS)"
        case .usa: return "USA (USD)"
        }
    }
}

#Preview {
    SettingsView()
} 