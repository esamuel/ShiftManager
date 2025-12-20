
import Foundation
import CoreData

// Simplified WageCalculationService logic for testing
class WageCalculator {
    func calculateWage(for shift: ShiftModel) -> String {
        let duration = shift.endTime.timeIntervalSince(shift.startTime)
        let hoursWorked = duration / 3600
        let hourlyWage = 50.0 // Example wage
        
        var output = "Shift Duration: \(hoursWorked) hours\n"
        output += "Is Special Day: \(shift.isSpecialDay)\n"
        output += "Hourly Wage: \(hourlyWage)\n"
        output += "Breakdown:\n"
        
        var totalWage = 0.0
        var remainingHours = hoursWorked
        
        if shift.isSpecialDay {
            // Special Day Logic
            // 0-8h @ 150%
            let baseHours = min(remainingHours, 8.0)
            let baseWage = baseHours * hourlyWage * 1.5
            output += "- Base (0-8h): \(baseHours)h @ 150% = \(baseWage)\n"
            totalWage += baseWage
            remainingHours -= baseHours
            
            // 8-10h @ 175%
            if remainingHours > 0 {
                let ot1Hours = min(remainingHours, 2.0)
                let ot1Wage = ot1Hours * hourlyWage * 1.75
                output += "- OT1 (8-10h): \(ot1Hours)h @ 175% = \(ot1Wage)\n"
                totalWage += ot1Wage
                remainingHours -= ot1Hours
            }
            
            // 10+h @ 200%
            if remainingHours > 0 {
                let ot2Wage = remainingHours * hourlyWage * 2.0
                output += "- OT2 (10+h): \(remainingHours)h @ 200% = \(ot2Wage)\n"
                totalWage += ot2Wage
            }
        } else {
            // Regular Day Logic
            // 0-8h @ 100%
            let baseHours = min(remainingHours, 8.0)
            let baseWage = baseHours * hourlyWage
            output += "- Base (0-8h): \(baseHours)h @ 100% = \(baseWage)\n"
            totalWage += baseWage
            remainingHours -= baseHours
            
            // 8-10h @ 125%
            if remainingHours > 0 {
                let ot1Hours = min(remainingHours, 2.0)
                let ot1Wage = ot1Hours * hourlyWage * 1.25
                output += "- OT1 (8-10h): \(ot1Hours)h @ 125% = \(ot1Wage)\n"
                totalWage += ot1Wage
                remainingHours -= ot1Hours
            }
            
            // 10+h @ 150%
            if remainingHours > 0 {
                let ot2Wage = remainingHours * hourlyWage * 1.5
                output += "- OT2 (10+h): \(remainingHours)h @ 150% = \(ot2Wage)\n"
                totalWage += ot2Wage
            }
        }
        
        output += "Total Wage: \(totalWage)\n"
        return output
    }
}

// Test function - call this manually to run tests
func runWageVerificationTests() {
    let calculator = WageCalculator()
    
    // 12 Hour Shift - Regular Day
    let regularShift = ShiftModel(
        id: UUID(),
        title: "Test Shift",
        category: "Regular",
        startTime: Date(),
        endTime: Date().addingTimeInterval(12 * 3600),
        notes: "",
        isOvertime: false,
        isSpecialDay: false,
        grossWage: 0,
        netWage: 0,
        createdAt: Date(),
        username: "Test"
    )
    
    // 12 Hour Shift - Special Day
    let specialShift = ShiftModel(
        id: UUID(),
        title: "Test Shift",
        category: "Special",
        startTime: Date(),
        endTime: Date().addingTimeInterval(12 * 3600),
        notes: "",
        isOvertime: false,
        isSpecialDay: true,
        grossWage: 0,
        netWage: 0,
        createdAt: Date(),
        username: "Test"
    )
    
    print("--- Regular Day Test ---")
    print(calculator.calculateWage(for: regularShift))
    
    print("\n--- Special Day Test ---")
    print(calculator.calculateWage(for: specialShift))
}
