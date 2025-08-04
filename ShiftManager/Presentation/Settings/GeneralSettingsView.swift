import SwiftUI

public struct GeneralSettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showingAlert = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance".localized)) {
                    Picker("Theme".localized, selection: $themeManager.currentTheme) {
                        Text("System".localized).tag(Theme.system)
                        Text("Light".localized).tag(Theme.light)
                        Text("Dark".localized).tag(Theme.dark)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Notifications".localized)) {
                    Toggle(isOn: $settingsManager.notificationsEnabled) {
                        Text("Enable Notifications".localized)
                    }
                    if settingsManager.notificationsEnabled {
                        Picker("Remind me before shift".localized, selection: $settingsViewModel.notificationLeadTime) {
                            ForEach(NotificationLeadTime.allCases) { leadTime in
                                Text(leadTime.description).tag(leadTime)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                Section(header: Text("Backup & Restore".localized)) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Export
                        Text("Export Data to Computer".localized)
                            .font(.headline)
                            .bold()
                        Text("Save a backup file of your shifts to your computer. You can later restore your data by importing this file.".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button(action: {
                            settingsViewModel.exportShifts()
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
                            settingsViewModel.importShifts()
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
                }
                Section(header: Text("Help & FAQ".localized)) {
                    NavigationLink(destination: FAQView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            Text("Frequently Asked Questions".localized)
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
                        showingAlert = true // for share sheet or similar action
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            Text("Tell Friends".localized)
                        }
                    }
                }
                Section(header: Text("Legal".localized)) {
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
                }
                Section(header: Text("Other".localized)) {
                    NavigationLink(destination: AboutView()) {
                        Text("About".localized)
                    }
                }
            }
        }
        .navigationTitle("General Settings".localized)
        .id(localizationManager.refreshID)
    }
}

#Preview {
    GeneralSettingsView()
}
