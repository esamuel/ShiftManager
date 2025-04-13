import Foundation
import CoreData

class WageCalculationService {
    private let context: NSManagedObjectContext
    private let calendar: Calendar
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        
        // Configure calendar based on work week start
        var calendar = Calendar.current
        let startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        calendar.firstWeekday = startWorkOnSunday ? 1 : 2 // 1 for Sunday, 2 for Monday
        self.calendar = calendar
    }
    
    private func isSpecialWorkDay(_ date: Date) -> Bool {
        let startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        let weekday = calendar.component(.weekday, from: date)
        
        // If week starts on Sunday, Saturday (7) is special
        // If week starts on Monday, Sunday (1) is special
        let isSpecial = weekday == (startWorkOnSunday ? 7 : 1)
        print("Date: \(date), Weekday: \(weekday), StartWorkOnSunday: \(startWorkOnSunday), IsSpecial: \(isSpecial)")
        return isSpecial
    }
    
    func calculateWage(for shift: ShiftModel) async throws -> WageCalculation {
        let duration = shift.duration
        let hoursWorked = duration / 3600 // Convert seconds to hours
        
        // Get base settings
        let defaultHourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
        let taxDeduction = UserDefaults.standard.double(forKey: "taxDeduction") / 100
        let startWorkOnSunday = UserDefaults.standard.bool(forKey: "startWorkOnSunday")
        
        // Check if this is a patrol shift ("סייר")
        let hourlyWage = shift.notes.contains("סייר") ? 46.04 : defaultHourlyWage
        
        // Determine if it's a special day based on the work week start setting
        let weekday = calendar.component(.weekday, from: shift.startTime)
        let isSpecialDayByDate = weekday == (startWorkOnSunday ? 7 : 1) // Saturday (7) for Sunday start, Sunday (1) for Monday start
        
        // A day is special if either it's manually marked as special or it falls on the special day of the week
        let isSpecialDay = shift.isSpecialDay || isSpecialDayByDate
        
        var totalWage = 0.0
        var breakdowns: [WageBreakdown] = []
        var remainingHours = hoursWorked
        
        if isSpecialDay {
            // Special day calculation
            // Base hours (first 8 hours) at 150%
            let baseHours = min(remainingHours, 8.0)
            let baseWage = baseHours * hourlyWage * 1.5
            
            breakdowns.append(WageBreakdown(
                hours: baseHours,
                rate: 1.5,
                amount: baseWage,
                type: .special
            ))
            
            totalWage += baseWage
            remainingHours -= baseHours
            
            // First overtime tier (hours 9-10) at 175%
            if remainingHours > 0 {
                let overtime1Hours = min(remainingHours, 2.0)
                let overtime1Wage = overtime1Hours * hourlyWage * 1.75
                
                breakdowns.append(WageBreakdown(
                    hours: overtime1Hours,
                    rate: 1.75,
                    amount: overtime1Wage,
                    type: .overtime
                ))
                
                totalWage += overtime1Wage
                remainingHours -= overtime1Hours
            }
            
            // Second overtime tier (after 10 hours) at 200%
            if remainingHours > 0 {
                let overtime2Wage = remainingHours * hourlyWage * 2.0
                
                breakdowns.append(WageBreakdown(
                    hours: remainingHours,
                    rate: 2.0,
                    amount: overtime2Wage,
                    type: .overtime
                ))
                
                totalWage += overtime2Wage
            }
        } else {
            // Regular day calculation
            // Base hours (first 8 hours) at 100%
            let baseHours = min(remainingHours, 8.0)
            let baseWage = baseHours * hourlyWage
            
            breakdowns.append(WageBreakdown(
                hours: baseHours,
                rate: 1.0,
                amount: baseWage,
                type: .regular
            ))
            
            totalWage += baseWage
            remainingHours -= baseHours
            
            // First overtime tier (hours 9-10) at 125%
            if remainingHours > 0 {
                let overtime1Hours = min(remainingHours, 2.0)
                let overtime1Wage = overtime1Hours * hourlyWage * 1.25
                
                breakdowns.append(WageBreakdown(
                    hours: overtime1Hours,
                    rate: 1.25,
                    amount: overtime1Wage,
                    type: .overtime
                ))
                
                totalWage += overtime1Wage
                remainingHours -= overtime1Hours
            }
            
            // Second overtime tier (after 10 hours) at 150%
            if remainingHours > 0 {
                let overtime2Wage = remainingHours * hourlyWage * 1.5
                
                breakdowns.append(WageBreakdown(
                    hours: remainingHours,
                    rate: 1.5,
                    amount: overtime2Wage,
                    type: .overtime
                ))
                
                totalWage += overtime2Wage
            }
        }
        
        let taxAmount = totalWage * taxDeduction
        let netWage = totalWage - taxAmount
        
        return WageCalculation(
            totalHours: hoursWorked,
            grossWage: totalWage,
            taxDeduction: taxAmount,
            netWage: netWage,
            breakdowns: breakdowns,
            isSpecialDay: isSpecialDay,
            isFestiveDay: false
        )
    }
    
    private func isFestiveDay(_ date: Date) async -> Bool {
        // TODO: Implement festive day check based on country calendar
        // This could be fetched from a local database or an API
        return false
    }
    
    private func calculateWeeklyOvertime(for shift: ShiftModel) async throws -> WageBreakdown? {
        let weekStart = calendar.startOfWeek(for: shift.startTime)
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        // Fetch all shifts in the week
        let request = NSFetchRequest<Shift>(entityName: "Shift")
        request.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", weekStart as NSDate, weekEnd as NSDate)
        
        let weekShifts = try context.fetch(request)
        let totalWeeklyHours = weekShifts.reduce(0.0) { $0 + ($1.endTime!.timeIntervalSince($1.startTime!)) } / 3600
        
        // Check if exceeded weekly threshold
        let weeklyThreshold = 40.0 // This could be made configurable
        if totalWeeklyHours > weeklyThreshold {
            let overtimeHours = totalWeeklyHours - weeklyThreshold
            let hourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
            let overtimeRate = 1.5 // This could be made configurable
            let overtimeAmount = overtimeHours * hourlyWage * overtimeRate
            
            return WageBreakdown(
                hours: overtimeHours,
                rate: overtimeRate,
                amount: overtimeAmount,
                type: .weeklyOvertime
            )
        }
        
        return nil
    }
}

struct WageCalculation {
    let totalHours: Double
    let grossWage: Double
    let taxDeduction: Double
    let netWage: Double
    let breakdowns: [WageBreakdown]
    let isSpecialDay: Bool
    let isFestiveDay: Bool
}

struct WageBreakdown {
    let hours: Double
    let rate: Double
    let amount: Double
    let type: WageType
    
    enum WageType {
        case regular
        case special
        case overtime
        case weeklyOvertime
    }
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)!
    }
} 