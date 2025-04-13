import SwiftUI

struct OvertimeRulesView: View {
    @StateObject private var viewModel = OvertimeRulesViewModel()
    @State private var showingAddRule = false
    @State private var ruleToEdit: OvertimeRuleModel?
    
    var body: some View {
        VStack(spacing: 0) {
            // Base Hours Section
            VStack(alignment: .leading, spacing: 16) {
                baseHoursSection
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Rules List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.overtimeRules) { rule in
                        OvertimeRuleCard(rule: rule, onEdit: {
                            ruleToEdit = rule
                        }, onDelete: {
                            viewModel.deleteRule(rule)
                        })
                    }
                }
                .padding()
            }
            
            // Add Rule Button
            Button(action: { showingAddRule = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.purple)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Overtime Rules".localized)
        .sheet(isPresented: $showingAddRule) {
            AddOvertimeRuleView(viewModel: AddOvertimeRuleViewModel(onSave: { rule in
                viewModel.addRule(rule)
                showingAddRule = false
            }))
        }
        .sheet(item: $ruleToEdit) { rule in
            AddOvertimeRuleView(viewModel: AddOvertimeRuleViewModel(
                rule: rule,
                onSave: { updatedRule in
                    viewModel.editRule(updatedRule)
                    ruleToEdit = nil
                }
            ))
        }
        .task {
            await viewModel.loadRules()
        }
    }
    
    private var baseHoursSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text("Base Hours (Weekday)".localized)
                    .font(.headline)
                HStack {
                    Text("\(viewModel.baseHoursWeekday) \("hours".localized)")
                        .font(.title2)
                    Spacer()
                    Button(action: { viewModel.editBaseHours(isWeekday: true) }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text("Base Hours (Special Day)".localized)
                    .font(.headline)
                HStack {
                    Text("\(viewModel.baseHoursSpecialDay) \("hours".localized)")
                        .font(.title2)
                    Spacer()
                    Button(action: { viewModel.editBaseHours(isWeekday: false) }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct OvertimeRuleCard: View {
    let rule: OvertimeRuleModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: "After %d hours at %.2fx rate @ %.2fx".localized, Int(rule.threshold), rule.multiplier, rule.multiplier))
                    .font(.headline)
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            Text(rule.isEnabled ? "Special Days".localized : "Weekdays".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
} 