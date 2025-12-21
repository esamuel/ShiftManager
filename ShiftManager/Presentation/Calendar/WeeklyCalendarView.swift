import SwiftUI

public struct WeeklyCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var currentWeekStart: Date
    
    public init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        let calendar = Calendar.current
        let today = Date()
        let firstWeekday = calendar.firstWeekday
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday - firstWeekday + 7) % 7
        self._currentWeekStart = State(initialValue: calendar.date(byAdding: .day, value: -daysToSubtract, to: today) ?? today)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Week navigation header
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(weekRangeText)
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .background(Color(.systemGray6))
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                ForEach(weekDays.indices, id: \.self) { index in
                    let date = calendar.date(byAdding: .day, value: index, to: currentWeekStart)!
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                        isToday: calendar.isDateInToday(date),
                        hasShifts: viewModel.hasShifts(for: date)
                    )
                    .onTapGesture {
                        viewModel.selectedDate = date
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .refreshOnLanguageChange()
    }
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = calendar.firstWeekday // Use system's first weekday
        return calendar
    }
    
    private var weekDays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        formatter.dateFormat = "EEE"
        
        var days = [String]()
        let firstWeekday = calendar.firstWeekday
        for i in 0..<7 {
            let weekday = (firstWeekday + i - 1) % 7 + 1
            let date = calendar.date(from: DateComponents(weekday: weekday))!
            days.append(formatter.string(from: date))
        }
        return days
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: currentWeekStart)!
        return "\(formatter.string(from: currentWeekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    private func previousWeek() {
        currentWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart)!
        viewModel.selectedDate = currentWeekStart
    }
    
    private func nextWeek() {
        currentWeekStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart)!
        viewModel.selectedDate = currentWeekStart
    }
} 