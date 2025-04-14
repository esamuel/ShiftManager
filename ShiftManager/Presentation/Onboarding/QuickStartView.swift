import SwiftUI

struct QuickStartView: View {
    @StateObject private var viewModel = QuickStartViewModel()
    @Binding var isShowingQuickStart: Bool
    @State private var showingSavedAlert = false
    @State private var showingTaxTooltip = false
    @State private var showingBaseHoursTooltip = false
    @State private var showingSpecialDayTooltip = false
    @State private var showingWorkWeekTooltip = false
    
    var body: some View {
        NavigationView {
            Form {
                // Header section with welcome message
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to ShiftManager!".localized)
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("Let's set up a few basics to get you started. You can always change these later in Settings.".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                // Basic Information
                Section(header: Text("Basic Information".localized)) {
                    TextField("Your Name".localized, text: $viewModel.username)
                        .disableAutocorrection(true)
                }
                
                // Wage Information
                Section(header: Text("Wage Settings".localized)) {
                    HStack {
                        Text("Hourly Wage".localized)
                        Spacer()
                        TextField("0.00", value: $viewModel.hourlyWage, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        HStack {
                            Text("Tax Deduction (%)".localized)
                            Button(action: { showingTaxTooltip.toggle() }) {
                                Image(systemName: "info.circle")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            .popover(isPresented: $showingTaxTooltip) {
                                QuickStartTooltipView(text: "This percentage will be deducted from your total earnings to calculate your net income. The actual tax may vary based on local regulations.".localized)
                            }
                        }
                        Spacer()
                        TextField("0.00", value: $viewModel.taxDeduction, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                    }
                    
                    // Add a note about tax calculation
                    Text("Note: Tax calculation is an estimate and may vary based on local regulations.".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                // Work Hours
                Section(header: Text("Hours Settings".localized)) {
                    HStack {
                        HStack {
                            Text("Base Hours (Weekday)".localized)
                            Button(action: { showingBaseHoursTooltip.toggle() }) {
                                Image(systemName: "info.circle")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            .popover(isPresented: $showingBaseHoursTooltip) {
                                QuickStartTooltipView(text: "Standard work hours for a regular weekday before overtime calculation begins.".localized)
                            }
                        }
                        Spacer()
                        TextField("8", value: $viewModel.baseHoursWeekday, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        HStack {
                            Text("Base Hours (Special Day)".localized)
                            Button(action: { showingSpecialDayTooltip.toggle() }) {
                                Image(systemName: "info.circle")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            .popover(isPresented: $showingSpecialDayTooltip) {
                                QuickStartTooltipView(text: "Standard work hours for special days (weekends, holidays) before overtime calculation begins.".localized)
                            }
                        }
                        Spacer()
                        TextField("8", value: $viewModel.baseHoursSpecialDay, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Toggle(viewModel.startWorkOnSunday ? "Start work on Sunday".localized : "Start work on Monday".localized, isOn: $viewModel.startWorkOnSunday)
                        Button(action: { showingWorkWeekTooltip.toggle() }) {
                            Image(systemName: "info.circle")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        .popover(isPresented: $showingWorkWeekTooltip) {
                            QuickStartTooltipView(text: "Sets the first day of your work week for reporting and calculations. Different countries use different standards.".localized)
                        }
                    }
                }
                
                // Language Selection
                Section(header: Text("Language".localized)) {
                    Picker("Language".localized, selection: $viewModel.selectedLanguage) {
                        ForEach(Language.allCases) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    }
                }
                
                // Country/Currency Selection
                Section(header: Text("Currency".localized)) {
                    Picker("Country".localized, selection: $viewModel.selectedCountry) {
                        ForEach(Country.allCases) { country in
                            Text(country.displayName)
                                .tag(country)
                        }
                    }
                }
                
                // Enhanced save button
                Section {
                    Button(action: {
                        viewModel.saveSettings()
                        showingSavedAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save & Continue".localized)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Quick Setup".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip".localized) {
                        isShowingQuickStart = false
                    }
                    .foregroundColor(.secondary)
                }
            }
            .alert("Settings Saved".localized, isPresented: $showingSavedAlert) {
                Button("Continue".localized, role: .cancel) {
                    isShowingQuickStart = false
                }
            } message: {
                Text("Your settings have been saved. You can change these anytime in the Settings menu.".localized)
            }
        }
    }
}

struct QuickStartTooltipView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Help".localized)
                .font(.headline)
                .foregroundColor(.purple)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(width: 280)
        .background(Color(.systemBackground))
    }
}

class QuickStartViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var hourlyWage: Double = 40.04
    @Published var taxDeduction: Double = 11.78
    @Published var baseHoursWeekday: Int = 8
    @Published var baseHoursSpecialDay: Int = 8
    @Published var startWorkOnSunday: Bool = true
    @Published var selectedLanguage: Language = .english
    @Published var selectedCountry: Country = .israel
    
    init() {
        // Try to get the current language from LocalizationManager
        if let language = Language(rawValue: LocalizationManager.shared.currentLanguage) {
            selectedLanguage = language
        }
    }
    
    func saveSettings() {
        // Save user settings to UserDefaults
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(hourlyWage, forKey: "hourlyWage")
        UserDefaults.standard.set(taxDeduction, forKey: "taxDeduction")
        UserDefaults.standard.set(baseHoursWeekday, forKey: "baseHoursWeekday")
        UserDefaults.standard.set(baseHoursSpecialDay, forKey: "baseHoursSpecialDay")
        UserDefaults.standard.set(startWorkOnSunday, forKey: "startWorkOnSunday")
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        UserDefaults.standard.set(selectedCountry.rawValue, forKey: "country")
        
        // Mark that setup has been completed
        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        
        // Update LocalizationManager
        LocalizationManager.shared.setLanguage(selectedLanguage.rawValue)
        LocalizationManager.shared.setCountry(selectedCountry)
    }
}

#Preview {
    QuickStartView(isShowingQuickStart: .constant(true))
} 