import SwiftUI
import CoreData

@MainActor
class OvertimeRulesViewModel: ObservableObject {
    @Published var overtimeRules: [OvertimeRuleModel] = []
    @Published var baseHoursWeekday: Int = UserDefaults.standard.integer(forKey: "baseHoursWeekday")
    @Published var baseHoursSpecialDay: Int = UserDefaults.standard.integer(forKey: "baseHoursSpecialDay")
    @Published var error: Error?
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func loadRules() async {
        do {
            let request = NSFetchRequest<OvertimeRule>(entityName: "OvertimeRule")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \OvertimeRule.dailyThreshold, ascending: true)]
            
            let rules = try context.fetch(request)
            overtimeRules = rules.map { entity in
                OvertimeRuleModel(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    threshold: entity.dailyThreshold,
                    multiplier: entity.multiplier,
                    isEnabled: entity.isActive
                )
            }
        } catch {
            self.error = error
        }
    }
    
    func addRule(_ rule: OvertimeRuleModel) {
        let entity = OvertimeRule(context: context)
        updateEntity(entity, with: rule)
        
        do {
            try context.save()
            Task {
                await loadRules()
            }
        } catch {
            self.error = error
        }
    }
    
    func editRule(_ rule: OvertimeRuleModel) {
        let request = NSFetchRequest<OvertimeRule>(entityName: "OvertimeRule")
        request.predicate = NSPredicate(format: "id == %@", rule.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                updateEntity(entity, with: rule)
                try context.save()
                Task {
                    await loadRules()
                }
            }
        } catch {
            self.error = error
        }
    }
    
    func deleteRule(_ rule: OvertimeRuleModel) {
        let request = NSFetchRequest<OvertimeRule>(entityName: "OvertimeRule")
        request.predicate = NSPredicate(format: "id == %@", rule.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                context.delete(entity)
                try context.save()
                Task {
                    await loadRules()
                }
            }
        } catch {
            self.error = error
        }
    }
    
    func editBaseHours(isWeekday: Bool) {
        let hours = isWeekday ? baseHoursWeekday : baseHoursSpecialDay
        let key = isWeekday ? "baseHoursWeekday" : "baseHoursSpecialDay"
        
        // In a real app, you might want to show a dialog or sheet to edit these values
        // For now, we'll just toggle between some preset values
        let newHours = hours == 8 ? 9 : 8
        
        if isWeekday {
            baseHoursWeekday = newHours
        } else {
            baseHoursSpecialDay = newHours
        }
        
        UserDefaults.standard.set(newHours, forKey: key)
    }
    
    private func updateEntity(_ entity: OvertimeRule, with model: OvertimeRuleModel) {
        entity.id = model.id
        entity.name = model.name
        entity.dailyThreshold = model.threshold
        entity.multiplier = model.multiplier
        entity.isActive = model.isEnabled
    }
} 