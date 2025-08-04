import CoreData

public class PersistenceController {
    public static let shared = PersistenceController()
    
    public let container: NSPersistentCloudKitContainer
    
    public init(inMemory: Bool = false) {
        // Use regular container for faster startup, configure CloudKit later if needed
        container = NSPersistentCloudKitContainer(name: "ShiftManager")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure basic store settings for fast startup
        if let description = container.persistentStoreDescriptions.first {
            // Set a timeout to ensure we don't block the main thread for too long
            description.setOption(2.0 as NSNumber, forKey: NSPersistentStoreTimeoutOption)
            
            // Defer CloudKit setup to after initial load
            // This will be configured asynchronously after the store is loaded
        }
        
        // Configure view context before loading stores
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Load stores synchronously but with a shorter timeout
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                print("Core Data loading error: \(error.localizedDescription)")
                // Don't crash the app, just log the error
            }
            
            // Configure CloudKit asynchronously after stores are loaded
            DispatchQueue.global(qos: .utility).async { [weak self] in
                self?.configureCloudKit()
            }
        }
    }
    
    // Separate method to configure CloudKit after initial load
    private func configureCloudKit() {
        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.samueleskenasy.shiftmanager")
        }
    }
    // Next steps:
    // 1. Enable iCloud and CloudKit capability in Xcode (Signing & Capabilities tab).
    // 2. Create a CloudKit container in the Apple Developer portal (if not already done).
    // 3. Replace the containerIdentifier above with your actual iCloud container ID (e.g., "iCloud.com.yourcompany.ShiftManager").
    // 4. Test on a real device with iCloud enabled.

    
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