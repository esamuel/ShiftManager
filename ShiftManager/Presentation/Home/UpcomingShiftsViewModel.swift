import Foundation
import Combine
import SwiftUI

public class UpcomingShiftsViewModel: ObservableObject {
    @Published var upcomingShifts: [Date: [ShiftModel]] = [:]
    @Published var isLoading = true
    private let repository: ShiftRepositoryProtocol
    
    // Cache formatters to improve performance
    private let dayFormatter: DateFormatter
    private let monthFormatter: DateFormatter
    private let timeFormatter: DateFormatter
    
    public init(repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.repository = repository
        
        // Initialize formatters once
        self.dayFormatter = DateFormatter()
        self.dayFormatter.dateFormat = "EEEE"
        
        self.monthFormatter = DateFormatter()
        self.monthFormatter.dateFormat = "MMM"
        
        self.timeFormatter = DateFormatter()
        self.timeFormatter.timeStyle = .short
        
        // Listen for locale changes to update formatters
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localeDidChange),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
        
        updateFormattersLocale()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func localeDidChange() {
        updateFormattersLocale()
        // Force UI update if needed, though Views usually handle this.
        // Re-formatting displayed strings might be needed if they are cached, 
        // but here we format on demand in the View, so just updating formatters is enough.
        objectWillChange.send() 
    }
    
    private func updateFormattersLocale() {
        let locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        dayFormatter.locale = locale
        monthFormatter.locale = locale
        timeFormatter.locale = locale
    }
    
    @MainActor
    func loadUpcomingShifts() async {
        isLoading = true
        
        do {
            // Calculate date range
            let calendar = Calendar.current
            let currentDate = Date()
            
            // Start from the beginning of current day
            let startDate = calendar.startOfDay(for: currentDate)
            
            // End date is 7 days after start (inclusive)
            let endDate = calendar.date(byAdding: .day, value: 8, to: startDate)!
            
            // Fetch shifts
            let shifts = try await repository.fetchShiftsInDateRange(from: startDate, to: endDate)
            
            // Group and sort shifts by day in one pass
            var groupedShifts: [Date: [ShiftModel]] = [:]
            
            for shift in shifts {
                let dayStart = calendar.startOfDay(for: shift.startTime)
                groupedShifts[dayStart, default: []].append(shift)
            }
            
            // Sort shifts within each day by start time
            for (day, dayShifts) in groupedShifts {
                groupedShifts[day] = dayShifts.sorted { $0.startTime < $1.startTime }
            }
            
            // Update UI - already on MainActor, no need for MainActor.run
            self.upcomingShifts = groupedShifts
            self.isLoading = false
        } catch {
            print("Error loading upcoming shifts: \(error)")
            self.isLoading = false
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let dayName = dayFormatter.string(from: date)
        let monthName = monthFormatter.string(from: date)
        
        // Get the day number
        let calendar = Calendar.current
        let dayNumber = calendar.component(.day, from: date)
        
        // Format the date in the localized pattern: "Weekday, Month Day"
        return "\(dayName), \(monthName) \(dayNumber)"
    }
    
    func formatTime(_ date: Date) -> String {
        return timeFormatter.string(from: date)
    }
    
    func calculateTotalHours(startTime: Date, endTime: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: startTime, to: endTime)
        
        let totalHours = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60.0
        return String(format: "%.1f hours", totalHours)
    }
} 