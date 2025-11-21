import XCTest
@testable import ShiftManager

import CoreData

final class WageCalculationTests: XCTestCase {
    var wageCalculationService: WageCalculationService!
    var context: NSManagedObjectContext!
    let calendar = Calendar.current
    
    override func setUpWithError() throws {
        context = PersistenceController.shared.container.viewContext
        wageCalculationService = WageCalculationService(context: context)
        
        // Set up test settings
        UserDefaults.standard.set(40.04, forKey: "hourlyWage")
        UserDefaults.standard.set(11.78, forKey: "taxDeduction")
        UserDefaults.standard.set(8, forKey: "baseHoursWeekday")
        UserDefaults.standard.set(8, forKey: "baseHoursSpecialDay")
        UserDefaults.standard.set(false, forKey: "startWorkOnSunday")
    }
    
    func testWeekday12HourShift() async throws {
        // Create a shift from 09:00 to 21:00 on a weekday
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 20 // Wednesday
        components.hour = 9
        components.minute = 0
        
        let startTime = calendar.date(from: components)!
        components.hour = 21
        let endTime = calendar.date(from: components)!
        
        let shift = ShiftModel(
            id: UUID(),
            title: "Test Shift",
            category: "",
            startTime: startTime,
            endTime: endTime,
            notes: "",
            isOvertime: false,
            isSpecialDay: false,
            createdAt: Date()
        )
        
        let calculation = try await wageCalculationService.calculateWage(for: shift)
        
        // Verify total hours
        XCTAssertEqual(calculation.totalHours, 12.0)
        
        // Verify breakdown
        // Verify breakdown
        let regularBreakdown = calculation.breakdowns.first { $0.type == WageBreakdown.WageType.regular }
        XCTAssertNotNil(regularBreakdown)
        XCTAssertEqual(regularBreakdown?.hours, 8.0)
        XCTAssertEqual(regularBreakdown?.rate, 1.0)
        XCTAssertEqual(regularBreakdown?.amount, 8.0 * 40.04)
        
        // Verify overtime breakdowns
        // Verify overtime breakdowns
        let overtimeBreakdowns = calculation.breakdowns.filter { $0.type == WageBreakdown.WageType.overtime }
        XCTAssertEqual(overtimeBreakdowns.count, 2)
        
        // First overtime tier (hours 9-10)
        let overtime1 = overtimeBreakdowns[0]
        XCTAssertEqual(overtime1.hours, 2.0)
        XCTAssertEqual(overtime1.rate, 1.25)
        XCTAssertEqual(overtime1.amount, 2.0 * 40.04 * 1.25)
        
        // Second overtime tier (hours 11-12)
        let overtime2 = overtimeBreakdowns[1]
        XCTAssertEqual(overtime2.hours, 2.0)
        XCTAssertEqual(overtime2.rate, 1.5)
        XCTAssertEqual(overtime2.amount, 2.0 * 40.04 * 1.5)
        
        // Verify total gross wage
        // Verify total gross wage
        let baseAmount = 8.0 * 40.04
        let ot1Amount = 2.0 * 40.04 * 1.25
        let ot2Amount = 2.0 * 40.04 * 1.5
        let expectedGrossWage = baseAmount + ot1Amount + ot2Amount
        XCTAssertEqual(calculation.grossWage, expectedGrossWage)
        
        // Verify tax calculation
        let expectedTax = expectedGrossWage * (11.78 / 100)
        XCTAssertEqual(calculation.taxDeduction, expectedTax)
        
        // Verify net wage
        let expectedNetWage = expectedGrossWage - expectedTax
        XCTAssertEqual(calculation.netWage, expectedNetWage)
    }
    
    func testMarch32025Shift() async throws {
        // Create a shift for March 3, 2025 (Monday) from 09:00 to 21:00
        var components = DateComponents()
        components.year = 2025
        components.month = 3
        components.day = 3
        components.hour = 9
        components.minute = 0
        
        let startTime = calendar.date(from: components)!
        components.hour = 21
        let endTime = calendar.date(from: components)!
        
        // Verify it's a Monday (should not be a special day)
        XCTAssertEqual(calendar.component(.weekday, from: startTime), 2) // 2 is Monday
        
        let shift = ShiftModel(
            id: UUID(),
            title: "Test Shift",
            category: "",
            startTime: startTime,
            endTime: endTime,
            notes: "",
            isOvertime: false,
            isSpecialDay: false,
            createdAt: Date()
        )
        
        // Check if it's being treated as a special day
        let isSpecial = wageCalculationService.isSpecialWorkDay(startTime)
        XCTAssertFalse(isSpecial, "March 3, 2025 should not be treated as a special day")
        
        let calculation = try await wageCalculationService.calculateWage(for: shift)
        
        // Expected breakdown for a 12-hour regular weekday shift:
        // - First 8 hours at regular rate (1.0x)
        // - Next 2 hours at 1.25x
        // - Final 2 hours at 1.5x
        
        let hourlyWage = 40.04
        let expectedBaseWage = 8.0 * hourlyWage // First 8 hours
        let expectedOvertime1 = 2.0 * hourlyWage * 1.25 // Hours 9-10
        let expectedOvertime2 = 2.0 * hourlyWage * 1.5 // Hours 11-12
        let expectedGrossWage = expectedBaseWage + expectedOvertime1 + expectedOvertime2
        
        XCTAssertEqual(calculation.grossWage, expectedGrossWage, accuracy: 0.01)
        XCTAssertEqual(calculation.netWage, expectedGrossWage * (1 - 11.78/100), accuracy: 0.01)
        
        // Verify the breakdowns
        // Verify the breakdowns
        let regularHours = calculation.breakdowns.first { $0.type == WageBreakdown.WageType.regular }
        XCTAssertEqual(regularHours?.hours, 8.0)
        XCTAssertEqual(regularHours?.rate, 1.0)
        
        let overtimeBreakdowns = calculation.breakdowns.filter { $0.type == WageBreakdown.WageType.overtime }
        XCTAssertEqual(overtimeBreakdowns.count, 2)
        
        let overtime1 = overtimeBreakdowns[0]
        XCTAssertEqual(overtime1.hours, 2.0)
        XCTAssertEqual(overtime1.rate, 1.25)
        
        let overtime2 = overtimeBreakdowns[1]
        XCTAssertEqual(overtime2.hours, 2.0)
        XCTAssertEqual(overtime2.rate, 1.5)
    }
    
    func testPatrolShiftRate() async throws {
        // Create a patrol shift from 09:00 to 21:00 on a weekday
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 20 // Wednesday
        components.hour = 9
        components.minute = 0
        
        let startTime = calendar.date(from: components)!
        components.hour = 21
        let endTime = calendar.date(from: components)!
        
        let shift = ShiftModel(
            id: UUID(),
            title: "Test Shift",
            category: "",
            startTime: startTime,
            endTime: endTime,
            notes: "סייר משמרת בוקר", // Patrol morning shift
            isOvertime: false,
            isSpecialDay: false,
            createdAt: Date()
        )
        
        let calculation = try await wageCalculationService.calculateWage(for: shift)
        
        // Verify total hours
        XCTAssertEqual(calculation.totalHours, 12.0)
        
        let hourlyWage = 46.04 // Special patrol rate
        
        // Verify breakdown
        // Verify breakdown
        let regularBreakdown = calculation.breakdowns.first { $0.type == WageBreakdown.WageType.regular }
        XCTAssertNotNil(regularBreakdown)
        XCTAssertEqual(regularBreakdown?.hours, 8.0)
        XCTAssertEqual(regularBreakdown?.rate, 1.0)
        XCTAssertEqual(regularBreakdown?.amount, 8.0 * hourlyWage)
        
        // Verify overtime breakdowns
        // Verify overtime breakdowns
        let overtimeBreakdowns = calculation.breakdowns.filter { $0.type == WageBreakdown.WageType.overtime }
        XCTAssertEqual(overtimeBreakdowns.count, 2)
        
        // First overtime tier (hours 9-10)
        let overtime1 = overtimeBreakdowns[0]
        XCTAssertEqual(overtime1.hours, 2.0)
        XCTAssertEqual(overtime1.rate, 1.25)
        XCTAssertEqual(overtime1.amount, 2.0 * hourlyWage * 1.25)
        
        // Second overtime tier (hours 11-12)
        let overtime2 = overtimeBreakdowns[1]
        XCTAssertEqual(overtime2.hours, 2.0)
        XCTAssertEqual(overtime2.rate, 1.5)
        XCTAssertEqual(overtime2.amount, 2.0 * hourlyWage * 1.5)
        
        // Verify total gross wage
        let expectedGrossWage = (8.0 * hourlyWage) + (2.0 * hourlyWage * 1.25) + (2.0 * hourlyWage * 1.5)
        XCTAssertEqual(calculation.grossWage, expectedGrossWage, accuracy: 0.01)
        
        // Verify tax calculation
        let expectedTax = expectedGrossWage * (11.78 / 100)
        XCTAssertEqual(calculation.taxDeduction, expectedTax, accuracy: 0.01)
        
        // Verify net wage
        let expectedNetWage = expectedGrossWage - expectedTax
        XCTAssertEqual(calculation.netWage, expectedNetWage, accuracy: 0.01)
        
        // Compare with non-patrol shift
        let regularShift = ShiftModel(
            id: UUID(),
            title: "Test Shift",
            category: "",
            startTime: startTime,
            endTime: endTime,
            notes: "Regular shift",
            isOvertime: false,
            isSpecialDay: false,
            createdAt: Date()
        )
        
        let regularCalculation = try await wageCalculationService.calculateWage(for: regularShift)
        XCTAssertTrue(calculation.grossWage > regularCalculation.grossWage, "Patrol shift should have higher wage")
    }
    
    func testFebruary62025RegularShift() async throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 2
        components.day = 6
        components.hour = 9
        components.minute = 0
        
        let startTime = calendar.date(from: components)!
        components.hour = 21
        let endTime = calendar.date(from: components)!
        
        let shift = ShiftModel(
            id: UUID(),
            title: "Test Shift",
            category: "",
            startTime: startTime,
            endTime: endTime,
            notes: "",
            isOvertime: false,
            isSpecialDay: false,
            createdAt: Date()
        )
        
        let calculation = try await wageCalculationService.calculateWage(for: shift)
        
        // Expected values for 12-hour regular day shift
        let hourlyWage = 40.04
        let expectedBaseWage = 8.0 * hourlyWage // First 8 hours at 100%
        let expectedOvertime1 = 2.0 * hourlyWage * 1.25 // Hours 9-10 at 125%
        let expectedOvertime2 = 2.0 * hourlyWage * 1.5 // Hours 11-12 at 150%
        let expectedGrossWage = expectedBaseWage + expectedOvertime1 + expectedOvertime2 // Should be 540.54
        
        XCTAssertEqual(calculation.grossWage, 540.54, accuracy: 0.01)
        XCTAssertEqual(calculation.netWage, 476.86, accuracy: 0.01)
    }
    
    func testFebruary62025SpecialDayShift() async throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 2
        components.day = 6
        components.hour = 9
        components.minute = 0
        
        let startTime = calendar.date(from: components)!
        components.hour = 20 // 11 hours shift
        let endTime = calendar.date(from: components)!
        
        let shift = ShiftModel(
            id: UUID(),
            title: "Test Shift",
            category: "",
            startTime: startTime,
            endTime: endTime,
            notes: "",
            isOvertime: false,
            isSpecialDay: true, // Mark as special day
            createdAt: Date()
        )
        
        let calculation = try await wageCalculationService.calculateWage(for: shift)
        
        // Expected values for 11-hour special day shift
        let hourlyWage = 40.04
        let expectedBaseWage = 8.0 * hourlyWage * 1.5 // First 8 hours at 150%
        let expectedOvertime1 = 2.0 * hourlyWage * 1.75 // Hours 9-10 at 175%
        let expectedOvertime2 = 1.0 * hourlyWage * 2.0 // Hour 11 at 200%
        let expectedGrossWage = expectedBaseWage + expectedOvertime1 + expectedOvertime2 // Should be 700.70
        
        XCTAssertEqual(calculation.grossWage, 700.70, accuracy: 0.01)
        XCTAssertEqual(calculation.netWage, expectedGrossWage * (1 - 11.78/100), accuracy: 0.01)
        
        // Verify breakdowns
        // Verify breakdowns
        let specialBreakdown = calculation.breakdowns.first { $0.type == WageBreakdown.WageType.special }
        XCTAssertEqual(specialBreakdown?.hours, 8.0)
        XCTAssertEqual(specialBreakdown?.rate, 1.5)
        
        let overtimeBreakdowns = calculation.breakdowns.filter { $0.type == WageBreakdown.WageType.overtime }
        XCTAssertEqual(overtimeBreakdowns.count, 2)
        
        let overtime1 = overtimeBreakdowns[0]
        XCTAssertEqual(overtime1.hours, 2.0)
        XCTAssertEqual(overtime1.rate, 1.75)
        
        let overtime2 = overtimeBreakdowns[1]
        XCTAssertEqual(overtime2.hours, 1.0)
        XCTAssertEqual(overtime2.rate, 2.0)
    }
    
    func testFebruary152024Shift() async throws {
        // Create a shift for February 15, 2024 (Saturday) from 09:00 to 20:00 (11 hours)
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 15
        components.hour = 9
        components.minute = 0
        
        let startTime = calendar.date(from: components)!
        components.hour = 20
        let endTime = calendar.date(from: components)!
        
        // Verify it's a Saturday (weekday 7)
        XCTAssertEqual(calendar.component(.weekday, from: startTime), 7)
        
        let shift = ShiftModel(
            id: UUID(),
            title: "Test Shift",
            category: "",
            startTime: startTime,
            endTime: endTime,
            notes: "",
            isOvertime: false,
            isSpecialDay: false,
            createdAt: Date()
        )
        
        // Check if it's being treated as a special day
        let isSpecial = wageCalculationService.isSpecialWorkDay(startTime)
        XCTAssertTrue(isSpecial, "February 15, 2024 should be treated as a special day (Saturday)")
        
        let calculation = try await wageCalculationService.calculateWage(for: shift)
        
        // Expected breakdown for an 11-hour special day shift:
        // - First 8 hours at 150%
        // - Next 2 hours at 175%
        // - Final 1 hour at 200%
        
        let hourlyWage = 40.04
        let expectedBaseWage = 8.0 * hourlyWage * 1.5 // First 8 hours at 150%
        let expectedOvertime1 = 2.0 * hourlyWage * 1.75 // Hours 9-10 at 175%
        let expectedOvertime2 = 1.0 * hourlyWage * 2.0 // Hour 11 at 200%
        let expectedGrossWage = expectedBaseWage + expectedOvertime1 + expectedOvertime2 // Should be 700.70
        
        XCTAssertEqual(calculation.grossWage, 700.70, accuracy: 0.01)
        XCTAssertEqual(calculation.netWage, expectedGrossWage * (1 - 11.78/100), accuracy: 0.01)
        
        // Verify the breakdowns
        // Verify the breakdowns
        let specialBreakdown = calculation.breakdowns.first { $0.type == WageBreakdown.WageType.special }
        XCTAssertEqual(specialBreakdown?.hours, 8.0)
        XCTAssertEqual(specialBreakdown?.rate, 1.5)
        
        let overtimeBreakdowns = calculation.breakdowns.filter { $0.type == WageBreakdown.WageType.overtime }
        XCTAssertEqual(overtimeBreakdowns.count, 2)
        
        let overtime1 = overtimeBreakdowns[0]
        XCTAssertEqual(overtime1.hours, 2.0)
        XCTAssertEqual(overtime1.rate, 1.75)
        
        let overtime2 = overtimeBreakdowns[1]
        XCTAssertEqual(overtime2.hours, 1.0)
        XCTAssertEqual(overtime2.rate, 2.0)
    }
} 