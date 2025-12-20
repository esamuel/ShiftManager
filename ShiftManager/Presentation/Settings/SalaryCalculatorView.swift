import SwiftUI

struct DeductionCalculatorView: View {
    enum CalculationMode: String, CaseIterable, Identifiable {
        case combinedTotals = "Combined Totals"
        case individualPayslips = "Individual Payslips"
        
        var id: String { rawValue }
        var localizedName: String {
            switch self {
            case .combinedTotals: return "Combined Totals".localized
            case .individualPayslips: return "Individual Payslips".localized
            }
        }
        
        var helperText: String {
            switch self {
            case .combinedTotals:
                return "Enter the summed deductions and gross (brutto) wages from the last three months.".localized
            case .individualPayslips:
                return "Add each monthly payslip separately so the calculator can sum the values for you.".localized
            }
        }
    }
    
    @Binding var taxDeduction: Double
    @State private var totalDeductions: Double = 0.0
    @State private var totalGrossWage: Double = 0.0
    @State private var calculationMode: CalculationMode = .combinedTotals
    @State private var payPeriods: [PayPeriod] = PayPeriod.defaultSet
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    private var deductionPercentage: Double? {
        let gross = currentGross
        guard gross > 0 else { return nil }
        let percentage = (currentDeductions / gross) * 100
        guard percentage.isFinite else { return nil }
        return max(0, percentage)
    }
    
    private var formattedPercentage: String {
        guard let percentage = deductionPercentage else { return "--" }
        return String(format: "%.2f%%", percentage)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How this works".localized)) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Calculation Method".localized, selection: $calculationMode) {
                            ForEach(CalculationMode.allCases) { mode in
                                Text(mode.localizedName).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text(calculationMode.helperText)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                
                if calculationMode == .combinedTotals {
                    CombinedTotalsSection(
                        totalDeductions: $totalDeductions,
                        totalGrossWage: $totalGrossWage,
                        currencySymbol: localizationManager.currencySymbol
                    )
                } else {
                    PayslipEntrySection(
                        payPeriods: $payPeriods,
                        currencySymbol: localizationManager.currencySymbol,
                        onDelete: removePayPeriod,
                        onAdd: addPayPeriod
                    )
                }
                
                Section(header: Text("Result".localized)) {
                    HStack {
                        Text("Deduction percentage".localized)
                        Spacer()
                        Text(formattedPercentage)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(deductionPercentage == nil ? .secondary : .purple)
                    }
                    
                    if let percentage = deductionPercentage {
                        Text(String(format: "Equals %.2f%% of your gross wages for that period.".localized, percentage))
                            .font(.callout)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Enter both totals to calculate the deduction percentage.".localized)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button {
                        guard let percentage = deductionPercentage else { return }
                        let rounded = (percentage * 100).rounded() / 100
                        taxDeduction = rounded
                        dismiss()
                    } label: {
                        Label("Use this percentage in Settings".localized, systemImage: "arrow.down.circle.fill")
                    }
                    .disabled(deductionPercentage == nil)
                    
                    Button(role: .destructive) {
                        resetInputs()
                    } label: {
                        Text("Clear".localized)
                    }
                }
            }
            .navigationTitle("Deduction Calculator".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var currentGross: Double {
        switch calculationMode {
        case .combinedTotals:
            return totalGrossWage
        case .individualPayslips:
            return payPeriods.reduce(0) { $0 + $1.totalGross }
        }
    }
    
    private var currentDeductions: Double {
        switch calculationMode {
        case .combinedTotals:
            return totalDeductions
        case .individualPayslips:
            return payPeriods.reduce(0) { $0 + $1.totalDeductions }
        }
    }
    
    private func resetInputs() {
        totalDeductions = 0
        totalGrossWage = 0
        payPeriods = PayPeriod.defaultSet
    }
    
    private func removePayPeriod(_ id: UUID) {
        guard payPeriods.count > 1 else { return }
        payPeriods.removeAll { $0.id == id }
    }
    
    private func addPayPeriod() {
        payPeriods.append(PayPeriod(label: String(format: "Payslip %d".localized, payPeriods.count + 1)))
    }
}

private struct DeductionInputRow: View {
    let title: String
    @Binding var value: Double
    let currencySymbol: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack(spacing: 6) {
                Text(currencySymbol)
                    .foregroundColor(.secondary)
                TextField("0.00", value: $value, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
        }
    }
}

// MARK: - Combined totals section
private struct CombinedTotalsSection: View {
    @Binding var totalDeductions: Double
    @Binding var totalGrossWage: Double
    let currencySymbol: String
    
    var body: some View {
        Section(header: Text("Totals from the last 3 months".localized)) {
            DeductionInputRow(
                title: "Total deductions".localized,
                value: $totalDeductions,
                currencySymbol: currencySymbol
            )
            
            DeductionInputRow(
                title: "Total gross wage".localized,
                value: $totalGrossWage,
                currencySymbol: currencySymbol
            )
            
            Text("Tip: add up every deduction and gross value from the three most recent payslips before entering the totals.".localized)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
}

// MARK: - Payslip list section
private struct PayslipEntrySection: View {
    @Binding var payPeriods: [PayPeriod]
    let currencySymbol: String
    let onDelete: (UUID) -> Void
    let onAdd: () -> Void
    
    var body: some View {
        Section(header: Text("Enter each payslip".localized),
                footer: footerText) {
            ForEach($payPeriods) { $period in
                PayPeriodInputRow(
                    period: $period,
                    currencySymbol: currencySymbol,
                    allowDelete: payPeriods.count > 1,
                    onDelete: { onDelete(period.id) }
                )
            }
            
            Button(action: onAdd) {
                Label("Add another payslip".localized, systemImage: "plus.circle")
            }
        }
    }
    
    private var footerText: some View {
        Text("Copy the gross and total deduction values directly from each payslip (for example, base tax, social security, pension, advances, etc.). The calculator sums everything automatically.".localized)
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

private struct PayPeriodInputRow: View {
    @Binding var period: PayPeriod
    let currencySymbol: String
    let allowDelete: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Payslip name".localized, text: $period.label)
                    .textInputAutocapitalization(.words)
                if allowDelete {
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            DeductionInputRow(
                title: "Gross wage".localized,
                value: $period.totalGross,
                currencySymbol: currencySymbol
            )
            
            DeductionInputRow(
                title: "Total deductions".localized,
                value: $period.totalDeductions,
                currencySymbol: currencySymbol
            )
        }
        .padding(.vertical, 4)
    }
}

// MARK: - PayPeriod model
private struct PayPeriod: Identifiable {
    let id: UUID = UUID()
    var label: String
    var totalGross: Double
    var totalDeductions: Double
    
    init(label: String, totalGross: Double = 0, totalDeductions: Double = 0) {
        self.label = label
        self.totalGross = totalGross
        self.totalDeductions = totalDeductions
    }
    
    static var defaultSet: [PayPeriod] {
        [
            PayPeriod(label: String(format: "Payslip %d".localized, 1)),
            PayPeriod(label: String(format: "Payslip %d".localized, 2)),
            PayPeriod(label: String(format: "Payslip %d".localized, 3))
        ]
    }
}
