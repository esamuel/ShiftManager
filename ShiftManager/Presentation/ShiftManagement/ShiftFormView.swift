import SwiftUI

struct ShiftFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ShiftFormViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Shift Details".localized)) {
                    TextField("Title".localized, text: $viewModel.title)
                    
                    DatePicker("Start Time".localized, selection: $viewModel.startTime, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Time".localized, selection: $viewModel.endTime, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Overtime".localized, isOn: $viewModel.isOvertime)
                    
                    TextField("Notes".localized, text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Calculations".localized)) {
                    HStack {
                        Text("Duration".localized)
                        Spacer()
                        Text(viewModel.formattedDuration)
                            .foregroundColor(.secondary)
                    }
                    
                    if viewModel.isOvertime {
                        HStack {
                            Text("Overtime Hours".localized)
                            Spacer()
                            Text(viewModel.formattedOvertimeHours)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Shift".localized : "New Shift".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel".localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save".localized) {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Error".localized, isPresented: .constant(viewModel.error != nil)) {
                Button("OK".localized) { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }
}

class ShiftFormViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var isOvertime: Bool = false
    @Published var notes: String = ""
    @Published var error: Error?
    
    private let repository: ShiftRepositoryProtocol
    private let shift: ShiftModel?
    let isEditing: Bool
    
    var isValid: Bool {
        !title.isEmpty && endTime > startTime
    }
    
    var formattedDuration: String {
        let duration = endTime.timeIntervalSince(startTime)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }
    
    var formattedOvertimeHours: String {
        let duration = endTime.timeIntervalSince(startTime)
        let hours = duration / 3600
        return String(format: "%.1f", hours)
    }
    
    init(repository: ShiftRepositoryProtocol = ShiftRepository(), shift: ShiftModel? = nil) {
        self.repository = repository
        self.shift = shift
        self.isEditing = shift != nil
        
        if let shift = shift {
            self.title = shift.title
            self.startTime = shift.startTime
            self.endTime = shift.endTime
            self.isOvertime = shift.isOvertime
            self.notes = shift.notes
        }
    }
    
    @MainActor
    func save() async {
        do {
            let shiftModel = ShiftModel(
                id: shift?.id ?? UUID(),
                title: title,
                startTime: startTime,
                endTime: endTime,
                notes: notes,
                isOvertime: isOvertime,
                isSpecialDay: false,
                category: "",
                createdAt: shift?.createdAt ?? Date()
            )
            
            if isEditing {
                try await repository.updateShift(shiftModel)
            } else {
                try await repository.createShift(shiftModel)
            }
        } catch {
            self.error = error
        }
    }
}

#Preview {
    ShiftFormView(viewModel: ShiftFormViewModel())
} 