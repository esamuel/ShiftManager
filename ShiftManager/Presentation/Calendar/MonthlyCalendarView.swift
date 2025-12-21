import SwiftUI

public struct MonthlyCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var currentMonth: Date
    
    public init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        self._currentMonth = State(initialValue: Date())
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Month navigation header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthYearText)
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
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
                ForEach(daysInMonth, id: \.self) { date in
                    if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasShifts: viewModel.hasShifts(for: date)
                        )
                        .onTapGesture {
                            viewModel.selectedDate = date
                        }
                    } else {
                        // Days from previous/next month
                        DayCell(
                            date: date,
                            isSelected: false,
                            isToday: false,
                            hasShifts: false,
                            isOtherMonth: true
                        )
                        .onTapGesture {
                            // Switch to the tapped adjacent month and select the date
                            currentMonth = date
                            viewModel.selectedDate = date
                        }
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
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let firstWeekdayOfMonth = calendar.firstWeekday
        let daysToSubtract = (firstWeekday - firstWeekdayOfMonth + 7) % 7
        
        let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfMonth)!
        
        var dates: [Date] = []
        for i in 0..<42 { // 6 weeks * 7 days
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
        viewModel.selectedDate = currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        viewModel.selectedDate = currentMonth
    }
} 