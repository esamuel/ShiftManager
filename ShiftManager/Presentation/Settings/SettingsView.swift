import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            Form {
                // Personal Information Section
                Section(header: Text("Personal Information".localized)) {
                    HStack {
                        Text("Username".localized)
                        Spacer()
                        TextField("Username", text: $viewModel.username)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Wage Settings Section
                Section(header: Text("Wage Settings".localized)) {
                    HStack {
                        Text("Hourly Wage".localized)
                        Spacer()
                        TextField("0.00", value: $viewModel.hourlyWage, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Tax Deduction (%)".localized)
                        Spacer()
                        TextField("0.00", value: $viewModel.taxDeduction, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                    }
                }
                
                // Hours Settings Section
                Section(header: Text("Hours Settings".localized)) {
                    HStack {
                        Text("Base Hours (Weekday)".localized)
                        Spacer()
                        TextField("8", value: $viewModel.baseHoursWeekday, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Base Hours (Special Day)".localized)
                        Spacer()
                        TextField("8", value: $viewModel.baseHoursSpecialDay, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Work Week Settings
                Section {
                    Toggle(viewModel.startWorkOnSunday ? "Start work on Sunday".localized : "Start work on Monday".localized, isOn: $viewModel.startWorkOnSunday)
                }
                
                // Language Settings
                Section(header: Text("Language".localized)) {
                    Button(action: {
                        viewModel.showingLanguagePicker = true
                    }) {
                        HStack {
                            Text("Language".localized)
                            Spacer()
                            Text(viewModel.selectedLanguage.displayName)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 13))
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Country Settings
                Section(header: Text("Currency".localized)) {
                    Picker("Country".localized, selection: $viewModel.selectedCountry) {
                        ForEach(Country.allCases) { country in
                            Text(country.displayName)
                                .tag(country)
                        }
                    }
                }
                
                // About Section with App Version
                Section(header: Text("About".localized)) {
                    HStack {
                        Text("Version".localized)
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.gray)
                    }
                }
                
                // Save Button
                Section {
                    Button(action: viewModel.saveSettings) {
                        Text("Save Settings".localized)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.purple)
                    }
                }
            }
            .navigationTitle("Settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .alert("Settings Saved".localized, isPresented: $viewModel.showingSaveConfirmation) {
                Button("OK".localized, role: .cancel) { }
            }
            .sheet(isPresented: $viewModel.showingLanguagePicker) {
                LanguagePickerView(selectedLanguage: $viewModel.selectedLanguage, isPresented: $viewModel.showingLanguagePicker, onLanguageSelected: { language in
                    viewModel.applyLanguageChange(language)
                })
            }
            .refreshOnLanguageChange()
        }
    }
}

struct LanguagePickerView: View {
    @Binding var selectedLanguage: Language
    @Binding var isPresented: Bool
    var onLanguageSelected: (Language) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Language.allCases) { language in
                    Button(action: {
                        selectedLanguage = language
                        onLanguageSelected(language)
                        isPresented = false
                    }) {
                        HStack {
                            Text(language.displayName)
                            Spacer()
                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Language".localized)
            .navigationBarItems(trailing: Button("Done".localized) {
                isPresented = false
            })
            .refreshOnLanguageChange()
        }
    }
}

#Preview {
    SettingsView()
} 


