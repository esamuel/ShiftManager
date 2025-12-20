import SwiftUI
import UniformTypeIdentifiers

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingTaxTooltip = false
    @State private var showingBaseHoursTooltip = false
    @State private var showingSpecialDayTooltip = false
    @State private var showingWorkWeekTooltip = false
    @State private var showingHelpSheet = false
    @State private var showingDeductionCalculator = false
    @State private var searchText = ""
    @State private var isSearching = false
    
    // Function to filter sections based on search
    private func filteredSections() -> [SettingsSection] {
        if searchText.isEmpty {
            return SettingsSection.allSections
        } else {
            return SettingsSection.allSections.map { section in
                var filtered = section
                filtered.isVisible = section.name.localizedCaseInsensitiveContains(searchText) ||
                    section.items.contains { $0.localizedCaseInsensitiveContains(searchText) }
                return filtered
            }
        }
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                if isSearching {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search settings".localized, text: $searchText)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                }
                
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
                                
                                Button(action: {
                                    // Scroll to personal information section
                                }) {
                                    Text("Complete Setup".localized)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.orange)
                                        .cornerRadius(8)
                                }
                                .padding(.top, 6)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Premium Section
                    if !purchaseManager.isPremium {
                        Section {
                            Button(action: {
                                purchaseManager.showPaywall = true
                            }) {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Upgrade to Premium".localized)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Unlock all features & unlimited shifts".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    } else {
                        Section {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Premium Active".localized)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("You have access to all features".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            
                            #if DEBUG
                            Button("Reset Purchases (Debug)") {
                                purchaseManager.resetPurchases()
                            }
                            .foregroundColor(.red)
                            #endif
                        }
                    }
                    
                    // Profile Section
                    if shouldShowSection("Profile".localized) {
                        Section {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 25)
                                Text("Username".localized)
                                Spacer()
                                TextField("Username", text: $viewModel.username)
                                    .multilineTextAlignment(.trailing)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        viewModel.saveSettings()
                                    }
                            }
                        } header: {
                            SectionHeaderView(title: "Profile".localized, iconName: "person.crop.circle")
                        }
                    }
                    
                    // Regional Settings
                    if shouldShowSection("Regional".localized) {
                        Section {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.purple)
                                    .frame(width: 25)
                                Picker("Work Country".localized, selection: $viewModel.selectedCountry) {
                                    ForEach(Country.allCases) { country in
                                        Text(country.displayName)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                            .tag(country)
                                    }
                                }
                                .onChange(of: viewModel.selectedCountry) { _ in viewModel.saveSettings() }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                            
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(.green)
                                    .frame(width: 25)
                                Text("Currency".localized)
                                Spacer()
                                Text(viewModel.selectedCountry.currencySymbol)
                                    .foregroundColor(.gray)
                            }
                        } header: {
                            SectionHeaderView(title: "Regional".localized, iconName: "globe")
                        }
                    }
                    
                    // Language Settings
                    if shouldShowSection("Language".localized) {
                        Section {
                            Button(action: {
                                viewModel.showingLanguagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("App Language".localized)
                                    Spacer()
                                    Text(viewModel.selectedLanguage.displayName)
                                        .foregroundColor(.gray)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 13))
                                }
                            }
                            .foregroundColor(.primary)
                            .help("App Language Description".localized)
                        } header: {
                            SectionHeaderView(title: "Language".localized, iconName: "character.bubble")
                        }
                    }
                    
                    // Appearance Section
                    if shouldShowSection("Appearance".localized) {
                        Section {
                            HStack {
                                Image(systemName: themeIcon(for: themeManager.currentTheme))
                                    .foregroundColor(themeColor(for: themeManager.currentTheme))
                                    .frame(width: 25)
                                Picker("Theme".localized, selection: $themeManager.currentTheme) {
                                    Text("System".localized).tag(Theme.system)
                                    Text("Light".localized).tag(Theme.light)
                                    Text("Dark".localized).tag(Theme.dark)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        } header: {
                            SectionHeaderView(title: "Appearance".localized, iconName: "paintbrush")
                        }
                    }
                    
                    // Wage Settings Section
                    if shouldShowSection("Wage Settings".localized) {
                        Section {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 25)
                                
                                Text("Hourly Wage".localized)
                                Spacer()
                                TextField("0.00", value: $viewModel.hourlyWage, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 120)
                            }
                            
                            HStack {
                                Image(systemName: "percent")
                                    .foregroundColor(.red)
                                    .frame(width: 25)
                                
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
                                    .frame(width: 100)
                                Text("%")
                            }
                            
                            // Tax calculation note with improved styling
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                    .frame(width: 25)
                                
                                Text("Note: Tax calculation is an estimate and may vary based on local regulations.".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)

                            
                            Button(action: { showingDeductionCalculator = true }) {
                                HStack {
                                    Image(systemName: "function")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("Deduction Calculator".localized)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 13))
                                }
                            }
                        } header: {
                            SectionHeaderView(title: "Wage Settings".localized, iconName: "dollarsign.square")
                        }
                    }
                    
                    // Hours Settings Section
                    if shouldShowSection("Hours Settings".localized) {
                        Section {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 25)
                                
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
                                    .frame(width: 60)
                            }
                            
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.purple)
                                    .frame(width: 25)
                                
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
                                    .frame(width: 60)
                            }

                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.orange)
                                    .frame(width: 25)
                                
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
                        } header: {
                            SectionHeaderView(title: "Hours Settings".localized, iconName: "clock")
                        }
                    }
                    
                    // Notifications Section
                    if shouldShowSection("Notifications".localized) {
                        Section {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 25)
                                Toggle(isOn: $viewModel.notificationsEnabled) {
                                    Text("Enable Notifications".localized)
                                }
                            }
                            if viewModel.notificationsEnabled {
                                HStack {
                                    Image(systemName: "timer")
                                        .foregroundColor(.orange)
                                        .frame(width: 25)
                                    Picker("Remind me before shift".localized, selection: $viewModel.notificationLeadTime) {
                                        ForEach(NotificationLeadTime.allCases) { leadTime in
                                            Text(leadTime.description).tag(leadTime)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                            }
                        } header: {
                            SectionHeaderView(title: "Notifications".localized, iconName: "bell")
                        }
                    }
                    

                    

                    
                    // Backup & Restore Section
                    if shouldShowSection("Backup & Restore".localized) {
                        Section {
                            VStack(alignment: .leading, spacing: 20) {
                                // Export
                                Text("Export Data to Computer".localized)
                                    .font(.headline)
                                    .bold()
                                Text("Save a backup file of your shifts to your computer. You can later restore your data by importing this file.".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button(action: {
                                    viewModel.prepareBackupDocument()
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(.blue)
                                        Text("Export Shifts Backup".localized)
                                    }
                                }
                                .padding(.vertical, 4)

                                Divider()

                                // Import
                                Text("Import Data from Computer".localized)
                                    .font(.headline)
                                    .bold()
                                Text("Upload a previously exported backup file from your computer to restore your shifts data.".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button(action: {
                                    viewModel.showingImporter = true
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                            .foregroundColor(.green)
                                        Text("Import Shifts Backup".localized)
                                    }
                                }
                                .padding(.vertical, 4)

                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                    .padding(.top, 2)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Important: Data Loss Warning".localized)
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    Text("Deleting this app will erase all your data unless you have synced to iCloud or exported a backup file.\n\nTo protect your data, use iCloud sync or export a backup before deleting the app.".localized)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        } header: {
                            SectionHeaderView(title: "Backup & Restore".localized, iconName: "externaldrive")
                        }
                    }
                    
                    // Help & FAQ Section
                    if shouldShowSection("Help & FAQ".localized) {
                        Section {
                            Button(action: { showingHelpSheet = true }) {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("Frequently Asked Questions".localized)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 13))
                                }
                            }
                            .foregroundColor(.primary)
                            
                            NavigationLink(destination: VideoTutorialsListView()) {
                                HStack {
                                    Image(systemName: "play.rectangle")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("Video Tutorials".localized)
                                }
                            }
                            
                            NavigationLink(destination: GuideView()) {
                                HStack {
                                    Image(systemName: "book")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("User Guide".localized)
                                }
                            }
                            
                            NavigationLink(destination: FeedbackView()) {
                                HStack {
                                    Image(systemName: "star")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("Send Feedback".localized)
                                }
                            }
                            
                            NavigationLink(destination: ContactSupportView()) {
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("Contact Support".localized)
                                }
                            }
                            
                            Button(action: {
                                viewModel.showingShareSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("Tell Friends".localized)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 13))
                                }
                            }
                            .foregroundColor(.primary)
                        } header: {
                            SectionHeaderView(title: "Help & FAQ".localized, iconName: "questionmark.circle")
                        }
                    }
                    
                    // About Section
                    if shouldShowSection("About".localized) {
                        Section {
                            NavigationLink(destination: AboutView()) {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("About Shift Manager".localized)
                                    Spacer()
                                    Text(viewModel.appVersion)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } header: {
                            SectionHeaderView(title: "About".localized, iconName: "info.circle")
                        }
                    }
                    
                    // Legal Section
                    if shouldShowSection("Legal".localized) {
                        Section {
                            NavigationLink(destination: PrivacyPolicyView()) {
                                HStack {
                                    Image(systemName: "lock.shield")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("Privacy Policy".localized)
                                }
                            }
                            NavigationLink(destination: TermsOfUseView()) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.blue)
                                        .frame(width: 25)
                                    Text("Terms of Use".localized)
                                }
                            }
                        } header: {
                            SectionHeaderView(title: "Legal".localized, iconName: "doc.text")
                        }
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSearching.toggle()
                        if !isSearching {
                            searchText = ""
                        }
                    }) {
                        Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: viewModel.saveSettings) {
                        Image(systemName: "checkmark")
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
            .sheet(isPresented: $purchaseManager.showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingDeductionCalculator) {
                DeductionCalculatorView(taxDeduction: $viewModel.taxDeduction)
            }
            .sheet(isPresented: $viewModel.showingShareSheet) {
                // Share sheet implementation would go here
                // For now we can use a simple ActivityViewController wrapper or similar
                Text("Share Sheet Placeholder")
            }
            .onChange(of: viewModel.hourlyWage) { _ in viewModel.saveSettings() }
            .onChange(of: viewModel.taxDeduction) { _ in viewModel.saveSettings() }
            .onChange(of: viewModel.baseHoursWeekday) { _ in viewModel.saveSettings() }
            .onChange(of: viewModel.baseHoursSpecialDay) { _ in viewModel.saveSettings() }
            // Username is saved on submit, not on change to prevent navigation issues
            .refreshOnLanguageChange()
            .id(themeManager.refreshID) // Force refresh when theme changes
        }
        .withAppTheme() // Apply the selected theme
        .onAppear {
            DispatchQueue.main.async {
                UINavigationBar.appearance().backItem?.backButtonTitle = ""
                UINavigationBar.appearance().topItem?.backButtonTitle = ""
            }
        }
        .fileExporter(
            isPresented: $viewModel.showingExporter,
            document: viewModel.backupDocument,
            contentType: .json,
            defaultFilename: "ShiftManager_Backup"
        ) { result in
            if case .failure(let error) = result {
                print("Export failed: \(error.localizedDescription)")
            }
        }
        .fileImporter(
            isPresented: $viewModel.showingImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.restoreBackup(from: url)
                }
            case .failure(let error):
                print("Import failed: \(error.localizedDescription)")
            }
        }
        .alert("Import Result".localized, isPresented: $viewModel.showingImportAlert) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            if let error = viewModel.importError {
                Text(String(format: "Error importing data: %@".localized, error.localizedDescription))
            } else {
                Text(viewModel.importMessage.localized)
            }
        }
    }
    
    private func shouldShowSection(_ sectionName: String) -> Bool {
        if searchText.isEmpty {
            return true
        }
        return filteredSections().contains { $0.name == sectionName && $0.isVisible }
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

// New component for section headers
struct SectionHeaderView: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .foregroundColor(.purple)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

// Settings section model for search filtering
struct SettingsSection: Identifiable {
    var id = UUID()
    var name: String
    var items: [String]
    var isVisible: Bool = true
    
    static var allSections: [SettingsSection] {
        [
            SettingsSection(name: "Profile".localized, items: ["Username".localized]),
            SettingsSection(name: "Regional".localized, items: ["Work Country".localized, "Currency".localized]),
            SettingsSection(name: "Language".localized, items: ["App Language".localized, "English".localized, "Hebrew".localized, "Russian".localized, "Spanish".localized, "French".localized, "German".localized]),
            SettingsSection(name: "Appearance".localized, items: ["Theme".localized]),
            SettingsSection(name: "Wage Settings".localized, items: ["Hourly Wage".localized, "Tax Deduction".localized, "Deduction Calculator".localized]),
            SettingsSection(name: "Hours Settings".localized, items: ["Base Hours (Weekday)".localized, "Base Hours (Special Day)".localized, "Start work on Sunday".localized, "Start work on Monday".localized]),
            SettingsSection(name: "Notifications".localized, items: ["Enable Notifications".localized, "Remind me before shift".localized]),
            SettingsSection(name: "Backup & Restore".localized, items: ["Export Data to Computer".localized, "Import Data from Computer".localized]),
            SettingsSection(name: "Help & FAQ".localized, items: ["Frequently Asked Questions".localized, "Video Tutorials".localized, "User Guide".localized, "Send Feedback".localized, "Contact Support".localized, "Tell Friends".localized]),
            SettingsSection(name: "About".localized, items: ["About Shift Manager".localized, "Version".localized]),
            SettingsSection(name: "Legal".localized, items: ["Privacy Policy".localized, "Terms of Use".localized])
        ]
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


