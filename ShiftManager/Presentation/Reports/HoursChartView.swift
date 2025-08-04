import SwiftUI
import Charts

struct HoursCategory: Identifiable {
    let id = UUID()
    let category: String
    let hours: Double
    let color: Color
}

struct HoursChartView: View {
    let regularHours: Double
    let overtimeHours125: Double
    let overtimeHours150: Double
    let overtimeHours175: Double
    let overtimeHours200: Double
    
    private var chartData: [HoursCategory] {
        var data: [HoursCategory] = []
        
        if regularHours > 0 {
            data.append(HoursCategory(category: "Regular (100%)", hours: regularHours, color: .blue))
        }
        
        if overtimeHours125 > 0 {
            data.append(HoursCategory(category: "Overtime (125%)", hours: overtimeHours125, color: .green))
        }
        
        if overtimeHours150 > 0 {
            data.append(HoursCategory(category: "Overtime (150%)", hours: overtimeHours150, color: .orange))
        }
        
        if overtimeHours175 > 0 {
            data.append(HoursCategory(category: "Overtime (175%)", hours: overtimeHours175, color: .red))
        }
        
        if overtimeHours200 > 0 {
            data.append(HoursCategory(category: "Overtime (200%)", hours: overtimeHours200, color: .purple))
        }
        
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hours Breakdown".localized)
                .font(.headline)
                .padding(.bottom, 8)
            
            Chart {
                ForEach(chartData) { item in
                    BarMark(
                        x: .value("Hours", item.hours),
                        y: .value("Category", item.category)
                    )
                    .foregroundStyle(item.color)
                    .annotation(position: .trailing) {
                        Text(String(format: "%.1f", item.hours))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: CGFloat(chartData.count * 40))
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            
            // Legend
            VStack(alignment: .leading, spacing: 4) {
                ForEach(chartData) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.category)
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HoursChartView(
        regularHours: 32.0,
        overtimeHours125: 4.0,
        overtimeHours150: 2.0,
        overtimeHours175: 0.0,
        overtimeHours200: 0.0
    )
    .padding()
    .background(Color(.systemGroupedBackground))
} 