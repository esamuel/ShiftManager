import SwiftUI
import Charts

struct WageCategory: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let color: Color
}

struct WageChartView: View {
    let regularWage: Double
    let overtimeWage125: Double
    let overtimeWage150: Double
    let overtimeWage175: Double
    let overtimeWage200: Double
    let hourlyRate: Double
    
    init(
        regularHours: Double,
        overtimeHours125: Double,
        overtimeHours150: Double,
        overtimeHours175: Double,
        overtimeHours200: Double,
        hourlyRate: Double
    ) {
        self.hourlyRate = hourlyRate
        self.regularWage = regularHours * hourlyRate
        self.overtimeWage125 = overtimeHours125 * hourlyRate * 1.25
        self.overtimeWage150 = overtimeHours150 * hourlyRate * 1.5
        self.overtimeWage175 = overtimeHours175 * hourlyRate * 1.75
        self.overtimeWage200 = overtimeHours200 * hourlyRate * 2.0
    }
    
    private var chartData: [WageCategory] {
        var data: [WageCategory] = []
        
        if regularWage > 0 {
            data.append(WageCategory(category: "Regular (100%)".localized, amount: regularWage, color: .blue))
        }
        
        if overtimeWage125 > 0 {
            data.append(WageCategory(category: "Overtime (125%)".localized, amount: overtimeWage125, color: .green))
        }
        
        if overtimeWage150 > 0 {
            data.append(WageCategory(category: "Overtime (150%)".localized, amount: overtimeWage150, color: .orange))
        }
        
        if overtimeWage175 > 0 {
            data.append(WageCategory(category: "Overtime (175%)".localized, amount: overtimeWage175, color: .red))
        }
        
        if overtimeWage200 > 0 {
            data.append(WageCategory(category: "Overtime (200%)".localized, amount: overtimeWage200, color: .purple))
        }
        
        return data
    }
    
    private var totalWage: Double {
        regularWage + overtimeWage125 + overtimeWage150 + overtimeWage175 + overtimeWage200
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Wage Distribution".localized)
                .font(.headline)
                .padding(.bottom, 8)
            
            if totalWage > 0 {
                if #available(iOS 17.0, *) {
                    Chart {
                        ForEach(chartData) { item in
                            SectorMark(
                                angle: .value("Wage", item.amount),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            )
                            .foregroundStyle(item.color)
                            .annotation(position: .overlay) {
                                Text(String(format: "%.1f%%", (item.amount / totalWage) * 100))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(.vertical)
                } else {
                    // Fallback for iOS 15-16 - Simple bars
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(chartData) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.category)
                                        .font(.caption)
                                    Spacer()
                                    Text(String(format: "%.1f%%", (item.amount / totalWage) * 100))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Rectangle()
                                    .fill(item.color)
                                    .frame(width: CGFloat((item.amount / totalWage)) * 300, height: 20)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                // Amount breakdown
                VStack(spacing: 8) {
                    ForEach(chartData) { item in
                        HStack {
                            Circle()
                                .fill(item.color)
                                .frame(width: 10, height: 10)
                            Text(item.category)
                                .font(.subheadline)
                            Spacer()
                            Text(LocalizationManager.shared.formatCurrency(item.amount))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.top, 8)
            } else {
                Text("No wage data available for the selected period".localized)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    WageChartView(
        regularHours: 32.0,
        overtimeHours125: 4.0,
        overtimeHours150: 2.0,
        overtimeHours175: 0.0,
        overtimeHours200: 0.0,
        hourlyRate: 40.0
    )
    .padding()
    .background(Color(.systemGroupedBackground))
} 