import SwiftUI

struct OvertimeRulesView: View {
    @StateObject private var viewModel = OvertimeRulesViewModel()
    @State private var showingAddRule = false
    @State private var ruleToEdit: OvertimeRuleModel?
    @State private var showingWeekdayTooltip = false
    @State private var showingSpecialDayTooltip = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Base Hours Section
            VStack(alignment: .leading, spacing: 16) {
                baseHoursSection
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Rules List
            List {
                if viewModel.overtimeRules.isEmpty {
                    VStack(alignment: .center, spacing: 8) {
                        Text("No Overtime Rules".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Tap the + button to add your first overtime rule.".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.overtimeRules) { rule in
                        OvertimeRuleCard(rule: rule, onEdit: {
                            ruleToEdit = rule
                        }, onDelete: {
                            viewModel.deleteRule(rule)
                        })
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
            }
            .listStyle(PlainListStyle())
            
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
        .refreshOnLanguageChange()
    }
    
    private var baseHoursSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base Work Hours".localized)
                .font(.title3)
                .bold()
                .padding(.bottom, 4)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Base Hours (Weekday)".localized)
                        .font(.headline)
                    Button(action: { showingWeekdayTooltip.toggle() }) {
                        Image(systemName: "info.circle")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .popover(isPresented: $showingWeekdayTooltip) {
                        OvertimeTooltipView(text: "Standard work hours for a regular weekday before overtime calculation begins.".localized)
                    }
                }
                
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
                HStack {
                    Text("Base Hours (Special Day)".localized)
                        .font(.headline)
                    Button(action: { showingSpecialDayTooltip.toggle() }) {
                        Image(systemName: "info.circle")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .popover(isPresented: $showingSpecialDayTooltip) {
                        OvertimeTooltipView(text: "Standard work hours for special days (weekends, holidays) before overtime calculation begins.".localized)
                    }
                }
                
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