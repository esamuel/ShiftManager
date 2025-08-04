import SwiftUI

public struct DatePickerSheetView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    private var isHebrew: Bool {
        LocalizationManager.shared.currentLanguage == "he"
    }
    
    private var locale: Locale {
        isHebrew ? Locale(identifier: "he_IL") : .current
    }
    
    private var calendar: Calendar {
        var cal = Calendar.current
        if isHebrew {
            cal.locale = Locale(identifier: "he_IL")
        }
        return cal
    }

    @State private var tempDate: Date = Date()
    @State private var displayedMonth: Date = Date()

    public var body: some View {
        VStack(spacing: 0) {
            // Top buttons
            HStack {
                Button(action: { isPresented = false }) {
                    Text(isHebrew ? "ביטול" : "Cancel")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                }
                
                Spacer()
                
                Button(action: {
                    selectedDate = tempDate
                    isPresented = false
                }) {
                    Text(isHebrew ? "שמור" : "Save")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                }
            }
            .padding([.horizontal, .top])
            .background(Color(.systemBackground))
            
            // Month and Year Header with navigation
            HStack {
                Button(action: { 
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth 
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(monthYearText)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { 
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth 
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Weekday Headers
            HStack(spacing: 0) {
                let weekdaySymbols = isHebrew ? ["א", "ב", "ג", "ד", "ה", "ו", "ש"] : calendar.shortWeekdaySymbols
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Calendar grid for displayedMonth
            let days = daysInMonth(for: displayedMonth)
            let calendarInstance = calendar
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(days, id: \.self) { date in
                    let isSelected = calendarInstance.isDate(date, inSameDayAs: tempDate)
                    let isCurrentMonth = calendarInstance.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                    Text("\(calendarInstance.component(.day, from: date))")
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                        .clipShape(Circle())
                        .foregroundColor(isCurrentMonth ? .primary : .gray)
                        .onTapGesture {
                            if isCurrentMonth {
                                tempDate = date
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()
        }
        .onAppear {
            tempDate = selectedDate
            displayedMonth = selectedDate
        }
    }

    var monthYearText: String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth)
    }

    func daysInMonth(for month: Date) -> [Date] {
        let calendarInstance = calendar
        let startOfMonth = calendarInstance.date(from: calendarInstance.dateComponents([.year, .month], from: month))!
        let firstWeekday = calendarInstance.component(.weekday, from: startOfMonth)
        let firstWeekdayOfMonth = calendarInstance.firstWeekday
        let daysToSubtract = (firstWeekday - firstWeekdayOfMonth + 7) % 7
        let startDate = calendarInstance.date(byAdding: .day, value: -daysToSubtract, to: startOfMonth)!
        var dates: [Date] = []
        for i in 0..<42 { // 6 weeks * 7 days
            if let date = calendarInstance.date(byAdding: .day, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
}
