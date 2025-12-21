import Foundation
@preconcurrency import CoreData

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
    
    // MARK: - Special Day Detection
    /// Returns the user's selected work country, or device locale if not set
    private func workCountry() -> Country {
        if let raw = UserDefaults.standard.string(forKey: "country"),
           let country = Country(rawValue: raw) {
            return country
        }
        return .israel // fallback, or use device locale mapping if preferred
    }

    /// Returns a calendar configured for the work country
    private func workCalendar() -> Calendar {
        switch workCountry() {
        case .israel:
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "he_IL")
            cal.firstWeekday = 1 // Sunday
            return cal
        case .usa:
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "en_US")
            cal.firstWeekday = 2 // Monday
            return cal
        case .uk:
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "en_GB")
            cal.firstWeekday = 2 // Monday
            return cal
        case .eu:
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "en_IE")
            cal.firstWeekday = 2 // Monday
            return cal
        case .russia:
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "ru_RU")
            cal.firstWeekday = 2 // Monday
            return cal
        }
    }

    /// Returns true if the date is a weekend (according to work country)
    private func isWeekend(_ date: Date) -> Bool {
        let cal = workCalendar()
        return cal.isDateInWeekend(date)
    }

    /// Returns true if the date is a Jewish holiday (only for Israel)
    private func isJewishHoliday(_ date: Date) -> Bool {
        if workCountry() != .israel { return false }
        let hebrewCalendar = Calendar(identifier: .hebrew)
        let components = hebrewCalendar.dateComponents([.month, .day], from: date)
        let holidays: [(month: Int, day: Int)] = [
            (1, 15),   // Passover
            (7, 1),    // Rosh Hashanah
            (7, 10),   // Yom Kippur
            (7, 15)    // Sukkot
        ]
        return holidays.contains { $0.month == components.month && $0.day == components.day }
    }

    /// Returns true if the date is a global public holiday (placeholder for API integration)
    private func isGlobalHoliday(_ date: Date) -> Bool {
        // TODO: Integrate with a public holiday API or local DB, use workCountry()
        return false
    }

    /// Returns true if the date is a special work day (weekend or holiday)
    func isSpecialWorkDay(_ date: Date) -> Bool {
        if isWeekend(date) { return true }
        if isJewishHoliday(date) { return true }
        if isGlobalHoliday(date) { return true }
        return false
    }
    
    func calculateWage(for shift: ShiftModel) async throws -> WageCalculation {
        let duration = shift.duration
        let hoursWorked = duration / 3600 // Convert seconds to hours
        
        // Get base settings
        let defaultHourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
        let taxDeduction = UserDefaults.standard.double(forKey: "taxDeduction") / 100
        
        // Check if this is a patrol shift ("סייר")
        let hourlyWage = shift.notes.contains("סייר") ? 46.04 : defaultHourlyWage
        
        // Dynamic detection of special days (weekend, Jewish/Israeli holiday, or global holiday)
        let isSpecialDayDynamic = isSpecialWorkDay(shift.startTime)
        // A day is special if either it's manually marked as special or detected as special
        let isSpecialDay = shift.isSpecialDay || isSpecialDayDynamic
        
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
    
    // MARK: - Daily Combined Wage Calculation
    /// Calculates wages for all shifts on the same day, properly accounting for daily overtime
    func calculateDailyWagesForShifts(_ shifts: [ShiftModel]) async throws -> [UUID: WageCalculation] {
        guard !shifts.isEmpty else { return [:] }
        
        // Sort shifts by start time
        let sortedShifts = shifts.sorted { $0.startTime < $1.startTime }
        
        // Calculate total daily hours
        let totalDailyHours = sortedShifts.reduce(0.0) { $0 + ($1.duration / 3600) }
        
        // Get settings
        let defaultHourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
        let taxDeduction = UserDefaults.standard.double(forKey: "taxDeduction") / 100
        
        // Determine if this is a special day (use first shift's date)
        let isSpecialDay = sortedShifts.first.map { isSpecialWorkDay($0.startTime) || $0.isSpecialDay } ?? false
        
        // Calculate cumulative wage based on total daily hours
        var cumulativeWage = 0.0
        var remainingHours = totalDailyHours
        
        if isSpecialDay {
            // Special day: 0-8h @ 150%, 8-10h @ 175%, 10+h @ 200%
            let baseHours = min(remainingHours, 8.0)
            cumulativeWage += baseHours * defaultHourlyWage * 1.5
            remainingHours -= baseHours
            
            if remainingHours > 0 {
                let overtime1Hours = min(remainingHours, 2.0)
                cumulativeWage += overtime1Hours * defaultHourlyWage * 1.75
                remainingHours -= overtime1Hours
            }
            
            if remainingHours > 0 {
                cumulativeWage += remainingHours * defaultHourlyWage * 2.0
            }
        } else {
            // Regular day: 0-8h @ 100%, 8-10h @ 125%, 10+h @ 150%
            let baseHours = min(remainingHours, 8.0)
            cumulativeWage += baseHours * defaultHourlyWage
            remainingHours -= baseHours
            
            if remainingHours > 0 {
                let overtime1Hours = min(remainingHours, 2.0)
                cumulativeWage += overtime1Hours * defaultHourlyWage * 1.25
                remainingHours -= overtime1Hours
            }
            
            if remainingHours > 0 {
                cumulativeWage += remainingHours * defaultHourlyWage * 1.5
            }
        }
        
        // Distribute wage proportionally to each shift based on its duration
        var results: [UUID: WageCalculation] = [:]
        
        for shift in sortedShifts {
            let shiftHours = shift.duration / 3600
            let shiftProportion = shiftHours / totalDailyHours
            let shiftGrossWage = cumulativeWage * shiftProportion
            
            // Check for patrol shift adjustment ("סייר")
            let hourlyWage = shift.notes.contains("סייר") ? 46.04 : defaultHourlyWage
            let wageAdjustment = (hourlyWage / defaultHourlyWage)
            let adjustedGrossWage = shiftGrossWage * wageAdjustment
            
            let taxAmount = adjustedGrossWage * taxDeduction
            let netWage = adjustedGrossWage - taxAmount
            
            // Create breakdown for this shift
            var breakdowns: [WageBreakdown] = []
            var shiftRemainingHours = shiftHours
            var cumulativeHoursBefore = sortedShifts.filter { $0.startTime < shift.startTime }
                .reduce(0.0) { $0 + ($1.duration / 3600) }
            
            // Calculate which tier(s) this shift falls into
            if isSpecialDay {
                if cumulativeHoursBefore < 8.0 {
                    let hoursInBaseTier = min(shiftRemainingHours, 8.0 - cumulativeHoursBefore)
                    breakdowns.append(WageBreakdown(
                        hours: hoursInBaseTier,
                        rate: 1.5,
                        amount: hoursInBaseTier * hourlyWage * 1.5,
                        type: .special
                    ))
                    shiftRemainingHours -= hoursInBaseTier
                    cumulativeHoursBefore += hoursInBaseTier
                }
                
                if shiftRemainingHours > 0 && cumulativeHoursBefore < 10.0 {
                    let hoursInOT1Tier = min(shiftRemainingHours, 10.0 - cumulativeHoursBefore)
                    breakdowns.append(WageBreakdown(
                        hours: hoursInOT1Tier,
                        rate: 1.75,
                        amount: hoursInOT1Tier * hourlyWage * 1.75,
                        type: .overtime
                    ))
                    shiftRemainingHours -= hoursInOT1Tier
                    cumulativeHoursBefore += hoursInOT1Tier
                }
                
                if shiftRemainingHours > 0 {
                    breakdowns.append(WageBreakdown(
                        hours: shiftRemainingHours,
                        rate: 2.0,
                        amount: shiftRemainingHours * hourlyWage * 2.0,
                        type: .overtime
                    ))
                }
            } else {
                if cumulativeHoursBefore < 8.0 {
                    let hoursInBaseTier = min(shiftRemainingHours, 8.0 - cumulativeHoursBefore)
                    breakdowns.append(WageBreakdown(
                        hours: hoursInBaseTier,
                        rate: 1.0,
                        amount: hoursInBaseTier * hourlyWage,
                        type: .regular
                    ))
                    shiftRemainingHours -= hoursInBaseTier
                    cumulativeHoursBefore += hoursInBaseTier
                }
                
                if shiftRemainingHours > 0 && cumulativeHoursBefore < 10.0 {
                    let hoursInOT1Tier = min(shiftRemainingHours, 10.0 - cumulativeHoursBefore)
                    breakdowns.append(WageBreakdown(
                        hours: hoursInOT1Tier,
                        rate: 1.25,
                        amount: hoursInOT1Tier * hourlyWage * 1.25,
                        type: .overtime
                    ))
                    shiftRemainingHours -= hoursInOT1Tier
                    cumulativeHoursBefore += hoursInOT1Tier
                }
                
                if shiftRemainingHours > 0 {
                    breakdowns.append(WageBreakdown(
                        hours: shiftRemainingHours,
                        rate: 1.5,
                        amount: shiftRemainingHours * hourlyWage * 1.5,
                        type: .overtime
                    ))
                }
            }
            
            results[shift.id] = WageCalculation(
                totalHours: shiftHours,
                grossWage: adjustedGrossWage,
                taxDeduction: taxAmount,
                netWage: netWage,
                breakdowns: breakdowns,
                isSpecialDay: isSpecialDay,
                isFestiveDay: false
            )
        }
        
        return results
    }
    
    /// Fetches all shifts on the same day as the given date
    func fetchShiftsOnSameDay(as date: Date) async throws -> [ShiftModel] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        let shifts = try await context.perform {
            let request = NSFetchRequest<Shift>(entityName: "Shift")
            request.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", dayStart as NSDate, dayEnd as NSDate)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Shift.startTime, ascending: true)]
            let results = try self.context.fetch(request)
            
            return results.map { shift in
                ShiftModel(
                    id: shift.id ?? UUID(),
                    title: shift.title ?? "",
                    category: shift.category ?? "",
                    startTime: shift.startTime ?? Date(),
                    endTime: shift.endTime ?? Date(),
                    notes: shift.notes ?? "",
                    isOvertime: shift.isOvertime,
                    isSpecialDay: shift.isSpecialDay,
                    grossWage: shift.grossWage,
                    netWage: shift.netWage,
                    createdAt: shift.createdAt ?? Date()
                )
            }
        }
        
        return shifts
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