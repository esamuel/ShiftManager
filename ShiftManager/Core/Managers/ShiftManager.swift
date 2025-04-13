import Foundation
import Combine

class ShiftManager: ObservableObject {
    static let shared = ShiftManager()
    
    @Published var shifts: [WorkShift] = []
    @Published var currentShift: WorkShift?
    
    private init() {
        // Initialize with empty shifts
        self.shifts = []
        self.currentShift = nil
    }
    
    func startShift() {
        let newShift = WorkShift(
            id: UUID().uuidString,
            startTime: Date(),
            endTime: nil,
            breaks: []
        )
        DispatchQueue.main.async {
            self.currentShift = newShift
            self.shifts.append(newShift)
        }
    }
    
    func endShift() {
        guard var currentShift = currentShift else { return }
        currentShift.endTime = Date()
        DispatchQueue.main.async {
            self.currentShift = nil
            if let index = self.shifts.firstIndex(where: { $0.id == currentShift.id }) {
                self.shifts[index] = currentShift
            }
        }
    }
}

struct WorkShift: Identifiable {
    let id: String
    let startTime: Date
    var endTime: Date?
    var breaks: [WorkBreak]
}

struct WorkBreak: Identifiable {
    let id = UUID().uuidString
    let startTime: Date
    var endTime: Date?
} 