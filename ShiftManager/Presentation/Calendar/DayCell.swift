import SwiftUI

public struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasShifts: Bool
    let isOtherMonth: Bool
    
    private let calendar = Calendar.current
    
    public init(date: Date, isSelected: Bool, isToday: Bool, hasShifts: Bool, isOtherMonth: Bool = false) {
        self.date = date
        self.isSelected = isSelected
        self.isToday = isToday
        self.hasShifts = hasShifts
        self.isOtherMonth = isOtherMonth
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor)
                .frame(width: 32, height: 32)
                .background(background)
                .clipShape(Circle())
            
            if hasShifts {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 50)
        .opacity(isOtherMonth ? 0.3 : 1.0)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
    
    private var background: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return Color.blue.opacity(0.1)
        } else {
            return .clear
        }
    }
} 