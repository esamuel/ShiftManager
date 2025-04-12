import SwiftUI

struct AddOvertimeRuleView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: AddOvertimeRuleViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Hours Threshold")
                        Spacer()
                        TextField("8", value: $viewModel.hoursThreshold, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Rate")
                        Spacer()
                        TextField("1.5", value: $viewModel.rate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section {
                    Toggle("Applies to Special Days", isOn: $viewModel.appliesSpecialDays)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Overtime Rule" : "Add Overtime Rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

class AddOvertimeRuleViewModel: ObservableObject {
    @Published var hoursThreshold: Int = 8
    @Published var rate: Double = 1.5
    @Published var appliesSpecialDays: Bool = false
    
    private let onSave: (OvertimeRuleModel) -> Void
    private let existingRule: OvertimeRuleModel?
    
    var isValid: Bool {
        hoursThreshold > 0 && rate > 0
    }
    
    var isEditing: Bool {
        existingRule != nil
    }
    
    init(rule: OvertimeRuleModel? = nil, onSave: @escaping (OvertimeRuleModel) -> Void) {
        self.existingRule = rule
        self.onSave = onSave
        
        if let rule = rule {
            self.hoursThreshold = Int(rule.threshold)
            self.rate = rule.multiplier
            self.appliesSpecialDays = rule.isEnabled
        }
    }
    
    func save() {
        let rule = OvertimeRuleModel(
            id: existingRule?.id ?? UUID(),
            name: "After \(hoursThreshold) hours at \(String(format: "%.2f", rate))x",
            threshold: Double(hoursThreshold),
            multiplier: rate,
            isEnabled: appliesSpecialDays
        )
        onSave(rule)
    }
} 