import Foundation
import Combine
import SwiftUI

public class UpcomingShiftsViewModel: ObservableObject {
    @Published var upcomingShifts: [Date: [ShiftModel]] = [:]
    @Published var isLoading = false
    private let repository: ShiftRepositoryProtocol
    
    public init(repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.repository = repository
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
            
            // Group shifts by day
            var groupedShifts: [Date: [ShiftModel]] = [:]
            
            // Create entries for all 7 days, even if no shifts
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                    let dayStart = calendar.startOfDay(for: date)
                    groupedShifts[dayStart] = []
                }
            }
            
            // Add shifts to their respective days
            for shift in shifts {
                let dayStart = calendar.startOfDay(for: shift.startTime)
                groupedShifts[dayStart, default: []].append(shift)
            }
            
            // Sort shifts within each day by start time
            for (day, dayShifts) in groupedShifts {
                groupedShifts[day] = dayShifts.sorted { $0.startTime < $1.startTime }
            }
            
            await MainActor.run {
                self.upcomingShifts = groupedShifts
                self.isLoading = false
            }
        } catch {
            print("Error loading upcoming shifts: \(error)")
            self.isLoading = false
        }
    }
    
    func formatDate(_ date: Date) -> String {
        // Get current language locale
        let locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        
        // Get the localized day name
        let dayFormatter = DateFormatter()
        dayFormatter.locale = locale
        dayFormatter.dateFormat = "EEEE"
        let dayName = dayFormatter.string(from: date)
        
        // Get the localized month name
        let monthFormatter = DateFormatter()
        monthFormatter.locale = locale
        monthFormatter.dateFormat = "MMM"
        let monthName = monthFormatter.string(from: date)
        
        // Get the day number
        let calendar = Calendar.current
        let dayNumber = calendar.component(.day, from: date)
        
        // Format the date in the localized pattern: "Weekday, Month Day"
        return "\(dayName), \(monthName) \(dayNumber)"
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func calculateTotalHours(startTime: Date, endTime: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: startTime, to: endTime)
        
        let totalHours = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60.0
        return String(format: "%.1f hours", totalHours)
    }
} 