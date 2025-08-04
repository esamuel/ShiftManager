import Foundation
import CoreData

private func mapShiftToEntity(_ shift: ShiftModel, _ entity: NSManagedObject) {
    entity.setValue(shift.id, forKey: "id")
    entity.setValue(shift.title, forKey: "title")
    entity.setValue(shift.category, forKey: "category")
    entity.setValue(shift.startTime, forKey: "startTime")
    entity.setValue(shift.endTime, forKey: "endTime")
    entity.setValue(shift.notes, forKey: "notes")
    entity.setValue(shift.isOvertime, forKey: "isOvertime")
    entity.setValue(shift.isSpecialDay, forKey: "isSpecialDay")
    entity.setValue(shift.grossWage, forKey: "grossWage")
    entity.setValue(shift.netWage, forKey: "netWage")
    entity.setValue(shift.createdAt, forKey: "createdAt")
    entity.setValue(shift.username, forKey: "username")
}

private func mapEntityToShift(_ entity: NSManagedObject) -> ShiftModel {
    return ShiftModel(
        id: entity.value(forKey: "id") as? UUID ?? UUID(),
        title: entity.value(forKey: "title") as? String ?? "",
        category: entity.value(forKey: "category") as? String ?? "",
        startTime: entity.value(forKey: "startTime") as? Date ?? Date(),
        endTime: entity.value(forKey: "endTime") as? Date ?? Date(),
        notes: entity.value(forKey: "notes") as? String ?? "",
        isOvertime: entity.value(forKey: "isOvertime") as? Bool ?? false,
        isSpecialDay: entity.value(forKey: "isSpecialDay") as? Bool ?? false,
        grossWage: entity.value(forKey: "grossWage") as? Double ?? 0.0,
        netWage: entity.value(forKey: "netWage") as? Double ?? 0.0,
        createdAt: entity.value(forKey: "createdAt") as? Date ?? Date(),
        username: entity.value(forKey: "username") as? String ?? ""
    )
} 