import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingTaxTooltip = false
    @State private var showingBaseHoursTooltip = false
    @State private var showingSpecialDayTooltip = false
    @State private var showingWorkWeekTooltip = false
    @State private var showingHelpSheet = false
    
    public var body: some View {
        NavigationView {
            Form {
                // Setup Reminder (Only shows if needed)
                if viewModel.showSetupReminder {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.orange)
                                Text("Setup Recommended".localized)
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            
                            Text("Please complete your basic profile settings to get the most out of the app.".localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Personal Information Section
                Section(header: Text("Personal Information".localized)) {
                    HStack {
                        Text("Username".localized)
                        Spacer()
                        TextField("Username", text: $viewModel.username)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Appearance Section
                Section(header: Text("Appearance".localized)) {
                    Picker("Theme".localized, selection: $viewModel.selectedTheme) {
                        ForEach(Theme.allCases) { theme in
                            HStack {
                                Image(systemName: themeIcon(for: theme))
                                    .foregroundColor(themeColor(for: theme))
                                Text(theme.displayName)
                            }
                            .tag(theme)
                        }
                    }
                    .onChange(of: viewModel.selectedTheme) { oldTheme, newTheme in
                        themeManager.setTheme(newTheme)
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
                        HStack {
                            Text("Tax Deduction (%)".localized)
                            Button(action: { showingTaxTooltip.toggle() }) {
                                Image(systemName: "info.circle")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            .popover(isPresented: $showingTaxTooltip) {
                                TooltipView(text: "This percentage will be deducted from your total earnings to calculate your net income. The actual tax may vary based on local regulations.".localized)
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
                
                // Hours Settings Section
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
                                TooltipView(text: "Standard work hours for a regular weekday before overtime calculation begins.".localized)
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
                                TooltipView(text: "Standard work hours for special days (weekends, holidays) before overtime calculation begins.".localized)
                            }
                        }
                        Spacer()
                        TextField("8", value: $viewModel.baseHoursSpecialDay, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Work Week Settings
                Section {
                    HStack {
                        Toggle(viewModel.startWorkOnSunday ? "Start work on Sunday".localized : "Start work on Monday".localized, isOn: $viewModel.startWorkOnSunday)
                        Button(action: { showingWorkWeekTooltip.toggle() }) {
                            Image(systemName: "info.circle")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        .popover(isPresented: $showingWorkWeekTooltip) {
                            TooltipView(text: "Sets the first day of your work week for reporting and calculations. Different countries use different standards.".localized)
                        }
                    }
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
                
                // Help & FAQ Section
                Section(header: Text("Help & FAQ".localized)) {
                    Button(action: {
                        showingHelpSheet = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                            Text("Frequently Asked Questions".localized)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 13))
                        }
                    }
                    
                    NavigationLink(destination: GuideView()) {
                        HStack {
                            Image(systemName: "book")
                                .foregroundColor(.blue)
                            Text("User Guide".localized)
                        }
                    }
                    
                    NavigationLink(destination: FeedbackView()) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.blue)
                            Text("Send Feedback".localized)
                        }
                    }
                    
                    NavigationLink(destination: ContactSupportView()) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                            Text("Contact Support".localized)
                        }
                    }
                    
                    Button(action: {
                        viewModel.showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Tell Friends".localized)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 13))
                        }
                    }
                    .sheet(isPresented: $viewModel.showingShareSheet) {
                        AppShareSheet(activityItems: ["Check out ShiftManager app! It helps track work hours, calculate wages, and manage overtime. Download it now!"])
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
                
                // Legal Section
                Section(header: Text("Legal".localized)) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.blue)
                            Text("Privacy Policy".localized)
                        }
                    }
                    
                    NavigationLink(destination: TermsOfUseView()) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("Terms of Use".localized)
                        }
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
            .sheet(isPresented: $showingHelpSheet) {
                FAQView()
            }
            .refreshOnLanguageChange()
            .id(themeManager.refreshID) // Force refresh when theme changes
        }
        .withAppTheme() // Apply the selected theme
    }
    
    // Helper function to get icon for each theme
    private func themeIcon(for theme: Theme) -> String {
        switch theme {
        case .system:
            return "iphone"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
    
    // Helper function to get color for each theme icon
    private func themeColor(for theme: Theme) -> Color {
        switch theme {
        case .system:
            return .blue
        case .light:
            return .orange
        case .dark:
            return .purple
        }
    }
}

struct TooltipView: View {
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

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General Questions".localized)) {
                    FAQItem(question: "How do I add a new shift?".localized, 
                            answer: "Go to the Manager tab and tap the + button. You can set the date, start time, end time, and mark it as a special day if needed.".localized)
                    
                    FAQItem(question: "How is overtime calculated?".localized, 
                            answer: "Overtime is calculated based on your settings for base hours and overtime rules. Any hours worked beyond the base hours will follow the overtime rules you've set up.".localized)
                    
                    FAQItem(question: "Can I export my shift data?".localized, 
                            answer: "Yes, in the Reports tab you can view your shift data by different time periods and export it to PDF.".localized)
                }
                
                Section(header: Text("Settings".localized)) {
                    FAQItem(question: "What is the tax deduction setting?".localized, 
                            answer: "The tax deduction percentage is used to estimate your net income after taxes. This is only an estimate and may not reflect actual taxes in your location.".localized)
                    
                    FAQItem(question: "What are base hours?".localized, 
                            answer: "Base hours define how many hours you can work before overtime begins. You can set different values for regular weekdays and special days.".localized)
                    
                    FAQItem(question: "How do I change the app language?".localized, 
                            answer: "In Settings, tap on the Language option and select your preferred language from the list.".localized)
                    
                    FAQItem(question: "How do I change the app theme?".localized, 
                            answer: "In Settings, go to the Appearance section and select your preferred theme (System, Light, or Dark).".localized)
                }
                
                Section(header: Text("Troubleshooting".localized)) {
                    FAQItem(question: "My shifts aren't showing up correctly".localized, 
                            answer: "Make sure your shifts don't overlap and that you've saved them properly. Try restarting the app if issues persist.".localized)
                    
                    FAQItem(question: "The overtime calculations look wrong".localized, 
                            answer: "Check your overtime rules and base hours settings to ensure they match your expectations. Remember that special days may have different rules.".localized)
                }
            }
            .navigationTitle("Frequently Asked Questions".localized)
            .navigationBarItems(trailing: Button("Close".localized) {
                dismiss()
            })
            .id(themeManager.refreshID)
            .withAppTheme()
        }
        .withAppTheme()
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .foregroundColor(.primary)
                .padding(.vertical, 4)
            }
            
            if isExpanded {
                Text(answer)
                    .foregroundColor(.secondary)
                    .font(.body)
                    .padding(.bottom, 8)
                    .transition(.opacity)
            }
        }
    }
}

struct ContactSupportView: View {
    @State private var subject = ""
    @State private var message = ""
    @State private var showingAlert = false
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("Contact Information".localized)) {
                Text("Email: support@shiftsmanager.com".localized)
            }
            
            Section(header: Text("Message".localized)) {
                TextField("Subject".localized, text: $subject)
                
                ZStack(alignment: .topLeading) {
                    if message.isEmpty {
                        Text("Describe your issue or question...".localized)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    
                    TextEditor(text: $message)
                        .frame(minHeight: 150)
                        .padding(.horizontal, -5)
                }
            }
            
            Section {
                Button(action: {
                    // In a real app, this would send the message
                    showingAlert = true
                }) {
                    Text("Send Message".localized)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Contact Support".localized)
        .alert("Message Sent".localized, isPresented: $showingAlert) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text("Thank you for your message. We'll get back to you soon.".localized)
        }
        .id(themeManager.refreshID)
        .withAppTheme()
    }
}

struct FeedbackView: View {
    @State private var rating: Int = 0
    @State private var feedback = ""
    @State private var selectedCategory = FeedbackCategory.general
    @State private var showingAlert = false
    @StateObject private var themeManager = ThemeManager.shared
    
    enum FeedbackCategory: String, CaseIterable, Identifiable {
        case general, usability, features, bugs, suggestions
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .general: return "General".localized
            case .usability: return "Usability".localized
            case .features: return "Features".localized
            case .bugs: return "Bug Report".localized
            case .suggestions: return "Suggestions".localized
            }
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Rate Your Experience".localized)) {
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(star <= rating ? .yellow : .gray)
                            .font(.title)
                            .onTapGesture {
                                rating = star
                            }
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Section(header: Text("Feedback Category".localized)) {
                Picker("Category".localized, selection: $selectedCategory) {
                    ForEach(FeedbackCategory.allCases) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Section(header: Text("Your Feedback".localized)) {
                ZStack(alignment: .topLeading) {
                    if feedback.isEmpty {
                        Text("Tell us what you think about the app...".localized)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    
                    TextEditor(text: $feedback)
                        .frame(minHeight: 150)
                        .padding(.horizontal, -5)
                }
                
                Text("\(feedback.count)/500")
                    .font(.caption)
                    .foregroundColor(feedback.count > 450 ? .orange : .gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Section {
                Button(action: {
                    submitFeedback()
                }) {
                    Text("Submit Feedback".localized)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                }
                .disabled(rating == 0 || feedback.isEmpty)
            }
        }
        .navigationTitle("App Feedback".localized)
        .alert("Feedback Sent".localized, isPresented: $showingAlert) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text("Thank you for your feedback! We'll use it to improve the app.".localized)
        }
        .id(themeManager.refreshID)
        .withAppTheme()
    }
    
    private func submitFeedback() {
        // In a real app, this would send the feedback to a server
        // For now, we'll just show a success message
        
        // Here you could implement an API call to submit feedback:
        // AppAnalytics.submitFeedback(rating: rating, category: selectedCategory.rawValue, comment: feedback)
        
        showingAlert = true
        
        // Reset the form after submission
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            rating = 0
            feedback = ""
            selectedCategory = .general
        }
    }
}

#Preview {
    SettingsView()
} 

public struct AppShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
} 


