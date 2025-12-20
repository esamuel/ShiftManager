import Foundation
import SwiftUI
import CoreData

public enum Theme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    public var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System".localized
        case .light: return "Light".localized
        case .dark: return "Dark".localized
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

public enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case hebrew = "he"
    case russian = "ru"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    
    public var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .hebrew: return "עברית"
        case .russian: return "Русский"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
}

public enum Country: String, CaseIterable, Identifiable {
    case usa
    case uk
    case eu
    case israel
    case russia
    
    public var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .usa: return "United States (USD)".localized
        case .uk: return "United Kingdom (GBP)".localized
        case .eu: return "European Union (EUR)".localized
        case .israel: return "Israel (ILS)".localized
        case .russia: return "Russia (RUB)".localized
        }
    }
    
    var currencyCode: String {
        switch self {
        case .usa: return "USD"
        case .uk: return "GBP"
        case .eu: return "EUR"
        case .israel: return "ILS"
        case .russia: return "RUB"
        }
    }
    
    var currencySymbol: String {
        switch self {
        case .usa: return "$"
        case .uk: return "£"
        case .eu: return "€"
        case .israel: return "₪"
        case .russia: return "₽"
        }
    }
}

public enum NotificationLeadTime: Int, CaseIterable, Identifiable {
    case min15 = 15
    case min30 = 30
    case min45 = 45
    case hour1 = 60
    
    public var id: Int { rawValue }
    public var description: String {
        switch self {
        case .min15: return NSLocalizedString("15 minutes", comment: "")
        case .min30: return NSLocalizedString("30 minutes", comment: "")
        case .min45: return NSLocalizedString("45 minutes", comment: "")
        case .hour1: return NSLocalizedString("1 hour", comment: "")
        }
    }
}

public class SettingsViewModel: ObservableObject {
    @Published var username: String
    @Published var hourlyWage: Double
    @Published var taxDeduction: Double
    @Published var baseHoursWeekday: Int
    @Published var baseHoursSpecialDay: Int
    @Published var startWorkOnSunday: Bool {
        didSet {
            saveSettings()
        }
    }
    @Published var selectedLanguage: Language
    @Published var selectedCountry: Country
    @Published var selectedTheme: Theme
    @Published var showingSaveConfirmation = false
    @Published var showingLanguagePicker = false
    @Published var showSetupReminder = false
    @Published var showingShareSheet = false
    @Published var notificationLeadTime: NotificationLeadTime = {
        let raw = UserDefaults.standard.integer(forKey: "notificationLeadTime")
        return NotificationLeadTime(rawValue: raw) ?? .min15
    }()
    
    // File Export/Import State
    @Published var showingExporter = false
    @Published var showingImporter = false
    @Published var backupDocument: ShiftBackupDocument?
    @Published var importError: Error?
    @Published var showingImportAlert = false
    @Published var importMessage = ""
    
    @Published var notificationsEnabled: Bool {
        didSet {
            SettingsManager.shared.notificationsEnabled = notificationsEnabled
        }
    }
    // App version property
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "1.0"
    }
    
    public init() {
        let raw = UserDefaults.standard.integer(forKey: "notificationLeadTime")
        self.notificationLeadTime = NotificationLeadTime(rawValue: raw) ?? .min15
        self.notificationsEnabled = SettingsManager.shared.notificationsEnabled
        // Load saved values or use defaults
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.hourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
        self.taxDeduction = UserDefaults.standard.double(forKey: "taxDeduction")
        self.baseHoursWeekday = UserDefaults.standard.integer(forKey: "baseHoursWeekday")
        self.baseHoursSpecialDay = UserDefaults.standard.integer(forKey: "baseHoursSpecialDay")
        self.startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        
        // Initialize language from LocalizationManager
        let savedLanguage = LocalizationManager.shared.currentLanguage
        self.selectedLanguage = Language(rawValue: savedLanguage) ?? .english
        
        self.selectedCountry = Country(rawValue: UserDefaults.standard.string(forKey: "country") ?? "israel") ?? .israel
        
        // Initialize theme
        let savedTheme = UserDefaults.standard.string(forKey: "theme") ?? "system"
        self.selectedTheme = Theme(rawValue: savedTheme) ?? .system
        
        // Set default values if not already set
        if self.hourlyWage == 0 {
            self.hourlyWage = 40.04
            self.taxDeduction = 11.78
            self.baseHoursWeekday = 8
            self.baseHoursSpecialDay = 8
            self.startWorkOnSunday = true
            saveSettings()
        }
        
        // Check if we should show the setup reminder
        checkSetupStatus()
    }
    
    // Check if basic setup is complete
    func checkSetupStatus() {
        let hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        // Only show reminder if the app has been launched before (onboarding completed)
        // but user hasn't saved settings at least once
        if hasLaunchedBefore && !hasCompletedSetup && username.isEmpty {
            showSetupReminder = true
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(notificationLeadTime.rawValue, forKey: "notificationLeadTime")
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(hourlyWage, forKey: "hourlyWage")
        UserDefaults.standard.set(taxDeduction, forKey: "taxDeduction")
        UserDefaults.standard.set(baseHoursWeekday, forKey: "baseHoursWeekday")
        UserDefaults.standard.set(baseHoursSpecialDay, forKey: "baseHoursSpecialDay")
        UserDefaults.standard.set(startWorkOnSunday, forKey: "startWorkOnSunday")
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        UserDefaults.standard.set(selectedCountry.rawValue, forKey: "country")
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "theme")
        
        // Mark that setup has been completed
        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        
        // Only update LocalizationManager if language or country changed
        // This prevents unnecessary root view reloads which reset navigation
        if LocalizationManager.shared.currentLanguage != selectedLanguage.rawValue {
            LocalizationManager.shared.setLanguage(selectedLanguage.rawValue)
        }
        
        if LocalizationManager.shared.currentCountry != selectedCountry {
            LocalizationManager.shared.setCountry(selectedCountry)
        }
        
        showingSaveConfirmation = true
    }
    
    // Method to apply language change immediately
    func applyLanguageChange(_ language: Language) {
        selectedLanguage = language
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        LocalizationManager.shared.setLanguage(selectedLanguage.rawValue)
    }
    
    // Reset settings to default values
    func resetToDefaults() {
        self.username = ""
        self.hourlyWage = 40.04
        self.taxDeduction = 11.78
        self.baseHoursWeekday = 8
        self.baseHoursSpecialDay = 8
        self.startWorkOnSunday = true
        
        // Keep the language as is since it's a user preference
        // But reset other settings
        self.selectedCountry = .israel
        self.selectedTheme = .system
        
        // Apply the changes
        ThemeManager.shared.setTheme(.system)
        LocalizationManager.shared.setCountry(selectedCountry)
        
        // Save the defaults
        saveSettings()
    }
    
    func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return String(format: "%dh %dm", hours, minutes)
    }
    // MARK: - Export/Import Shifts
    
    func prepareBackupDocument() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shift")
        do {
            let shifts = try context.fetch(fetchRequest)
            let shiftModels = shifts.map { mapEntityToShift($0) }
            self.backupDocument = ShiftBackupDocument(shifts: shiftModels)
            self.showingExporter = true
        } catch {
            print("Error preparing backup: \(error)")
        }
    }
    
    func restoreBackup(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            self.importError = NSError(domain: "ShiftManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied"])
            self.showingImportAlert = true
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let shiftModels = try decoder.decode([ShiftModel].self, from: data)
            
            let context = PersistenceController.shared.container.viewContext
            
            // Fetch existing IDs to prevent duplicates
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shift")
            let existingShifts = try context.fetch(fetchRequest)
            let existingIDs = Set(existingShifts.compactMap { $0.value(forKey: "id") as? UUID })
            
            var importedCount = 0
            var skippedCount = 0
            
            for model in shiftModels {
                if !existingIDs.contains(model.id) {
                    let entity = NSEntityDescription.insertNewObject(forEntityName: "Shift", into: context)
                    mapShiftToEntity(model, entity)
                    importedCount += 1
                } else {
                    skippedCount += 1
                }
            }
            
            if context.hasChanges {
                try context.save()
                // Notify that data has changed to reload shifts
                NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
            }
            
            self.importMessage = String(format: "Imported %d shifts. Skipped %d duplicates.".localized, importedCount, skippedCount)
            self.showingImportAlert = true
            
        } catch {
            print("Error importing shifts: \(error)")
            self.importError = error
            self.showingImportAlert = true
        }
    }
    
    // MARK: - Mapping helpers (copied from CoreDataManager)
    func mapShiftToEntity(_ shift: ShiftModel, _ entity: NSManagedObject) {
        entity.setValue(shift.id, forKey: "id")
        entity.setValue(shift.title, forKey: "title")
        entity.setValue(shift.category, forKey: "category")
        entity.setValue(shift.startTime, forKey: "startTime")
        entity.setValue(shift.endTime, forKey: "endTime")
        entity.setValue(shift.notes, forKey: "notes")
        entity.setValue(shift.isOvertime, forKey: "isOvertime")
        entity.setValue(shift.isSpecialDay, forKey: "isSpecialDay")
        entity.setValue(shift.grossWage, forKey: "grossWage")
        entity.setValue(shift.netWage, forKey: "netWage")
        entity.setValue(shift.createdAt, forKey: "createdAt")
        entity.setValue(shift.username, forKey: "username")
    }
    
    func mapEntityToShift(_ entity: NSManagedObject) -> ShiftModel {
        return ShiftModel(
            id: entity.value(forKey: "id") as? UUID ?? UUID(),
            title: entity.value(forKey: "title") as? String ?? "",
            category: entity.value(forKey: "category") as? String ?? "",
            startTime: entity.value(forKey: "startTime") as? Date ?? Date(),
            endTime: entity.value(forKey: "endTime") as? Date ?? Date(),
            notes: entity.value(forKey: "notes") as? String ?? "",
            isOvertime: entity.value(forKey: "isOvertime") as? Bool ?? false,
            isSpecialDay: entity.value(forKey: "isSpecialDay") as? Bool ?? false,
            grossWage: entity.value(forKey: "grossWage") as? Double ?? 0.0,
            netWage: entity.value(forKey: "netWage") as? Double ?? 0.0,
            createdAt: entity.value(forKey: "createdAt") as? Date ?? Date(),
            username: entity.value(forKey: "username") as? String ?? ""
        )
    }
}