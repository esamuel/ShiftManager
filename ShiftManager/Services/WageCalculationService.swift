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
        
        if startWorkOnSunday {
            // If week starts on Sunday, Saturday is special
            return weekday == 7 // 7 is Saturday
        } else {
            // If week starts on Monday, Sunday is special
            return weekday == 1 // 1 is Sunday
        }
    }
    
    func calculateWage(for shift: ShiftModel) async throws -> WageCalculation {
        let duration = shift.duration
        let hoursWorked = duration / 3600 // Convert seconds to hours
        
        // Get base settings
        let baseHoursWeekday = Double(UserDefaults.standard.integer(forKey: "baseHoursWeekday"))
        let baseHoursSpecialDay = Double(UserDefaults.standard.integer(forKey: "baseHoursSpecialDay"))
        let hourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
        let taxDeduction = UserDefaults.standard.double(forKey: "taxDeduction") / 100
        
        // Determine day type for both start and end times
        let isStartSpecial = isSpecialWorkDay(shift.startTime)
        let isEndSpecial = isSpecialWorkDay(shift.endTime)
        let isStartFestive = await isFestiveDay(shift.startTime)
        let isEndFestive = await isFestiveDay(shift.endTime)
        
        // If either start or end time is on a special day, treat the whole shift as special
        let isSpecialDay = isStartSpecial || isEndSpecial || isStartFestive || isEndFestive || shift.isSpecialDay
        
        // Get applicable overtime rules
        let request = NSFetchRequest<OvertimeRule>(entityName: "OvertimeRule")
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \OvertimeRule.dailyThreshold, ascending: true)]
        
        let rules = try context.fetch(request)
        
        // Calculate wages based on rules
        var remainingHours = hoursWorked
        var totalWage = 0.0
        var breakdowns: [WageBreakdown] = []
        
        let baseHours = isSpecialDay ? baseHoursSpecialDay : baseHoursWeekday
        
        // First calculate base rate
        if remainingHours > 0 {
            let baseRateHours = min(remainingHours, baseHours)
            let baseRate = isSpecialDay ? 1.5 : 1.0
            let baseWage = baseRateHours * hourlyWage * baseRate
            
            breakdowns.append(WageBreakdown(
                hours: baseRateHours,
                rate: baseRate,
                amount: baseWage,
                type: isSpecialDay ? .special : .regular
            ))
            
            totalWage += baseWage
            remainingHours -= baseRateHours
        }
        
        // Apply overtime rules in order
        for rule in rules where remainingHours > 0 {
            let threshold = rule.dailyThreshold
            let multiplier = rule.multiplier
            
            if hoursWorked > threshold {
                let overtimeHours = min(remainingHours, hoursWorked - threshold)
                let overtimeWage = overtimeHours * hourlyWage * multiplier
                
                breakdowns.append(WageBreakdown(
                    hours: overtimeHours,
                    rate: multiplier,
                    amount: overtimeWage,
                    type: .overtime
                ))
                
                totalWage += overtimeWage
                remainingHours -= overtimeHours
            }
        }
        
        // Calculate weekly overtime if applicable
        if let weeklyOvertime = try await calculateWeeklyOvertime(for: shift) {
            totalWage += weeklyOvertime.amount
            breakdowns.append(weeklyOvertime)
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
            isFestiveDay: isStartFestive || isEndFestive
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