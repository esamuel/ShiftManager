import Foundation
import CoreData

class DataImportService {
    private let context: NSManagedObjectContext
    private let wageCalculationService: WageCalculationService
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.wageCalculationService = WageCalculationService(context: context)
    }
    
    func importShifts(from jsonData: Data) async throws {
        // Parse JSON data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        struct FlutterShift: Codable {
            let id: String
            let title: String
            let startTime: Date
            let endTime: Date
            let notes: String
            let isOvertime: Bool
            let isSpecialDay: Bool
            let category: String
            let createdAt: Date
            let grossWage: Double
            let netWage: Double
        }
        
        let flutterShifts = try decoder.decode([FlutterShift].self, from: jsonData)
        
        // Import each shift
        for flutterShift in flutterShifts {
            let entity = Shift(context: context)
            entity.id = UUID(uuidString: flutterShift.id) ?? UUID()
            entity.title = flutterShift.title
            entity.startTime = flutterShift.startTime
            entity.endTime = flutterShift.endTime
            entity.notes = flutterShift.notes
            entity.isOvertime = flutterShift.isOvertime
            entity.isSpecialDay = flutterShift.isSpecialDay
            entity.category = flutterShift.category
            entity.createdAt = flutterShift.createdAt
            entity.grossWage = flutterShift.grossWage
            entity.netWage = flutterShift.netWage
        }
        
        // Save changes
        try context.save()
    }
} 