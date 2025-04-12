import CoreData

public struct PersistenceController {
    public static let shared = PersistenceController()
    
    public let container: NSPersistentContainer
    
    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ShiftManager")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    public static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create example data for preview
        let context = controller.container.viewContext
        
        // Add default settings
        let settings = Settings(context: context)
        settings.id = UUID()
        settings.username = "Demo User"
        settings.defaultShiftDuration = 28800.0 // 8 hours in seconds
        settings.theme = "system"
        settings.language = "en"
        
        // Add example overtime rules
        let standardRule = OvertimeRule(context: context)
        standardRule.id = UUID()
        standardRule.name = "Standard Overtime"
        standardRule.dailyThreshold = 8.0
        standardRule.weeklyThreshold = 40.0
        standardRule.isActive = true
        standardRule.multiplier = 1.5
        
        let doubleTimeRule = OvertimeRule(context: context)
        doubleTimeRule.id = UUID()
        doubleTimeRule.name = "Double Time"
        doubleTimeRule.dailyThreshold = 12.0
        doubleTimeRule.weeklyThreshold = 60.0
        doubleTimeRule.isActive = true
        doubleTimeRule.multiplier = 2.0
        
        // Add example shifts
        for i in 0..<10 {
            let shift = Shift(context: context)
            shift.id = UUID()
            shift.title = "Shift \(i + 1)"
            shift.startTime = Date()
            shift.endTime = Date().addingTimeInterval(3600 * 8) // 8 hours
            shift.notes = "Example shift notes"
            shift.isOvertime = i % 3 == 0 // Every third shift is overtime
            shift.category = ["Morning", "Afternoon", "Night"][i % 3]
            shift.createdAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    public func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
} 