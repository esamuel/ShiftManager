import Foundation

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
            // Get start work preference
            let startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
            
            // Calculate date range
            let calendar = Calendar.current
            var startDate: Date
            
            if startWorkOnSunday {
                // If starting on Sunday, find the most recent Sunday
                let weekday = calendar.component(.weekday, from: Date())
                let daysToSubtract = weekday - 1 // Sunday is 1 in iOS
                startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: Date()) ?? Date()
            } else {
                // If starting on Monday, find the most recent Monday
                let weekday = calendar.component(.weekday, from: Date())
                let daysToSubtract = weekday - 2 // Monday is 2 in iOS
                startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: Date()) ?? Date()
            }
            
            // Set end date to 7 days from start
            let endDate = calendar.date(byAdding: .day, value: 7, to: startDate) ?? Date()
            
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
        let calendar = Calendar.current
        
        // Get the localized day name
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let dayName = dayFormatter.string(from: date)
        
        // Get the localized month name
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let monthName = monthFormatter.string(from: date)
        
        // Get the day number
        let dayNumber = calendar.component(.day, from: date)
        
        // Format the date in the localized pattern: "Weekday, Month Day"
        return "\(dayName), \(monthName) \(dayNumber)"
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 