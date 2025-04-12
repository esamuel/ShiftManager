import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
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
                
                Section(header: Text("Data Management")) {
                    NavigationLink("Import Data from Flutter") {
                        DataImportView()
                    }
                    
                    // Firebase User ID Display
                    VStack(alignment: .leading) {
                        Text("Your Firebase User ID")
                            .font(.headline)
                        Text("You can find your Firebase User ID in:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("1. Your Flutter app settings")
                        Text("2. Firebase Console > Authentication > Users")
                        Text("3. Your Flutter app's user profile")
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: viewModel.saveSettings) {
                        Text("Save Settings")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.purple)
                    }
                }
            }
            .navigationTitle("Shift Settings")
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

#Preview {
    SettingsView()
} 

