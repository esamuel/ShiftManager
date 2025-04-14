import SwiftUI

struct AddOvertimeRuleView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: AddOvertimeRuleViewModel
    @State private var showingThresholdTooltip = false
    @State private var showingRateTooltip = false
    @State private var showingSpecialDaysTooltip = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        HStack {
                            Text("Hours Threshold".localized)
                            Button(action: { showingThresholdTooltip.toggle() }) {
                                Image(systemName: "info.circle")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            .popover(isPresented: $showingThresholdTooltip) {
                                OvertimeTooltipView(text: "The number of hours after which this overtime rate starts to apply.".localized)
                            }
                        }
                        Spacer()
                        TextField("8", value: $viewModel.hoursThreshold, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        HStack {
                            Text("Rate".localized)
                            Button(action: { showingRateTooltip.toggle() }) {
                                Image(systemName: "info.circle")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            .popover(isPresented: $showingRateTooltip) {
                                OvertimeTooltipView(text: "The multiplier applied to your hourly wage (e.g., 1.5 for time-and-a-half, 2.0 for double time).".localized)
                            }
                        }
                        Spacer()
                        TextField("1.5", value: $viewModel.rate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section {
                    HStack {
                        Toggle("Applies to Special Days".localized, isOn: $viewModel.appliesSpecialDays)
                        Button(action: { showingSpecialDaysTooltip.toggle() }) {
                            Image(systemName: "info.circle")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        .popover(isPresented: $showingSpecialDaysTooltip) {
                            OvertimeTooltipView(text: "If enabled, this rule will apply to weekends and holidays. If disabled, it applies to regular weekdays.".localized)
                        }
                    }
                }
                
                Section {
                    Text("Example".localized)
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This rule means:".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "After working %d hours, additional hours will be paid at %.2f times your regular rate.".localized, viewModel.hoursThreshold, viewModel.rate))
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Overtime Rule".localized : "Add Overtime Rule".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save".localized) {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

struct OvertimeTooltipView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Help".localized)
                .font(.headline)
                .foregroundColor(.purple)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(width: 280)
        .background(Color(.systemBackground))
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
            name: String(format: "After %d hours at %.2fx rate @ %.2fx".localized, hoursThreshold, rate, rate),
            threshold: Double(hoursThreshold),
            multiplier: rate,
            isEnabled: appliesSpecialDays
        )
        onSave(rule)
    }
} 