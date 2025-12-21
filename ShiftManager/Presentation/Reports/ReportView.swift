import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import UIKit
import Charts

public struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    @State private var showingPDFPreview = false
    @State private var pdfData: Data?
    @State private var showingShareSheet = false
    @State private var selectedView: ReportViewType = .weekly
    @State private var showingSearchSheet = false
    @State private var showingPrintSheet = false
    @State private var showingMonthlyReport = false
    
    public init() {}
    
    // Create separate view components to simplify the main body
    private var weeklyViewButton: some View {
        Button(action: {
            selectedView = .weekly
            viewModel.selectedView = .weekly
            viewModel.switchView(to: .weekly)
        }) {
            Text("Weekly View".localized)
                .font(.headline)
                .foregroundColor(selectedView == .weekly ? .purple : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(
            VStack {
                Spacer()
                Rectangle()
                    .fill(selectedView == .weekly ? Color.purple : Color.clear)
                    .frame(height: 2)
            }
        )
    }
    
    private var monthlyViewButton: some View {
        Button(action: {
            selectedView = .monthly
            viewModel.selectedView = .monthly
            viewModel.switchView(to: .monthly)
        }) {
            Text("Monthly View".localized)
                .font(.headline)
                .foregroundColor(selectedView == .monthly ? .purple : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(
            VStack {
                Spacer()
                Rectangle()
                    .fill(selectedView == .monthly ? Color.purple : Color.clear)
                    .frame(height: 2)
            }
        )
    }
    
    private var viewTypeSelectorBar: some View {
        HStack(spacing: 0) {
            weeklyViewButton
            monthlyViewButton
        }
        .padding(.horizontal)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
    
    public var body: some View {
        let isRTL = LocalizationManager.shared.currentLanguage == "he" || LocalizationManager.shared.currentLanguage == "ar"
        
        VStack(spacing: 0) {
            // View Type Selector
            viewTypeSelectorBar
                .padding(.top, 8)
            
            // Date Navigation
            VStack(spacing: 4) {
                HStack {
                    Button(action: { 
                        if isRTL { viewModel.nextPeriod() } else { viewModel.previousPeriod() }
                    }) {
                        Image(systemName: isRTL ? "chevron.right" : "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.periodTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { 
                        if isRTL { viewModel.previousPeriod() } else { viewModel.nextPeriod() }
                    }) {
                        Image(systemName: isRTL ? "chevron.left" : "chevron.right")
                            .font(.title3.bold())
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal)
                
                Text(viewModel.periodRangeText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical)
            
            // Summary Section
            VStack(spacing: 12) {
                SummaryRow(label: "Total Working Days:".localized, value: "\(viewModel.totalWorkingDays)")
                SummaryRow(label: "Total Hours:".localized, value: String(format: "%.2f", viewModel.totalHours))
                SummaryRow(label: "Gross Wage:".localized, value: viewModel.grossWage.asCurrency, valueColor: .primary)
                SummaryRow(label: "Net Wage:".localized, value: viewModel.netWage.asCurrency, valueColor: .green)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 20) {
                    // Breakdown Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Wage Breakdown".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            if viewModel.regularHours > 0 {
                                BreakdownRow(label: "100%", value: String(format: "%.2f", viewModel.regularHours))
                            }
                            if viewModel.overtimeHours125 > 0 {
                                BreakdownRow(label: "125%", value: String(format: "%.2f", viewModel.overtimeHours125))
                            }
                            if viewModel.overtimeHours150 > 0 {
                                BreakdownRow(label: "150%", value: String(format: "%.2f", viewModel.overtimeHours150))
                            }
                            if viewModel.overtimeHours175 > 0 {
                                BreakdownRow(label: "175%", value: String(format: "%.2f", viewModel.overtimeHours175))
                            }
                            if viewModel.overtimeHours200 > 0 {
                                BreakdownRow(label: "200%", value: String(format: "%.2f", viewModel.overtimeHours200))
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Visual Charts Section 
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Visual Summary".localized)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        HoursChartView(
                            regularHours: viewModel.regularHours,
                            overtimeHours125: viewModel.overtimeHours125,
                            overtimeHours150: viewModel.overtimeHours150,
                            overtimeHours175: viewModel.overtimeHours175,
                            overtimeHours200: viewModel.overtimeHours200
                        )
                        .frame(height: 200)
                        
                        WageChartView(
                            regularHours: viewModel.regularHours,
                            overtimeHours125: viewModel.overtimeHours125,
                            overtimeHours150: viewModel.overtimeHours150,
                            overtimeHours175: viewModel.overtimeHours175,
                            overtimeHours200: viewModel.overtimeHours200,
                            hourlyRate: UserDefaults.standard.double(forKey: "hourlyWage")
                        )
                        .frame(height: 200)
                    }
                    
                    // List of shifts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Shifts".localized)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.shifts) { shift in
                            ShiftReportCard(shift: shift)
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Note: Tax calculation is an estimate and may vary based on local regulations.".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemGroupedBackground))
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        .navigationTitle("Reports".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingSearchSheet = true }) {
                    Image(systemName: "magnifyingglass")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: MonthlyReportView()) {
                    Image(systemName: "calendar")
                }
            }
        }
        .sheet(isPresented: $showingSearchSheet) {
            SearchShiftView()
        }
        .refreshOnLanguageChange()
    }
}

public struct ShiftReportCard: View {
    let shift: ShiftModel
    
    public init(shift: ShiftModel) {
        self.shift = shift
    }
    
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMMM d, yyyy"
        dateFormatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        return dateFormatter.string(from: shift.startTime)
    }
    
    private var timeRange: String {
        let startTime = shift.startTime.formatted(date: .omitted, time: .shortened)
        let endTime = shift.endTime.formatted(date: .omitted, time: .shortened)
        return String(format: "%@ - %@".localized, startTime, endTime)
    }
    
    private var formattedDuration: String {
        return String(format: "%.2f", shift.duration / 3600)
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(timeRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .center, spacing: 4) {
                Text("\(formattedDuration)h")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if shift.isSpecialDay {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Text(shift.grossWage.asCurrency)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

public struct CustomDateView: View {
    let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    public var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.formattingContext = .standalone
        
        // For Hebrew, use a specific date format that shows day and month name explicitly
        if LocalizationManager.shared.currentLanguage == "he" {
            let hebrewFormatter = DateFormatter()
            hebrewFormatter.locale = Locale(identifier: "he")
            hebrewFormatter.calendar = Calendar(identifier: .gregorian)
            
            // Get components
            let calendar = Calendar(identifier: .gregorian)
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date) - 1 // 0-based index
            let year = calendar.component(.year, from: date)
            
            // Hebrew month names
            let hebrewMonths = ["ינואר", "פברואר", "מרץ", "אפריל", "מאי", "יוני", 
                               "יולי", "אוגוסט", "ספטמבר", "אוקטובר", "נובמבר", "דצמבר"]
            
            return Text("\(day) \(hebrewMonths[month]) \(year)")
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        } else {
            return Text(dateFormatter.string(from: date))
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(LocalizationManager.shared.currentLanguage == "ar" ? .trailing : .leading)
        }
    }
}

public struct PrintOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var pdfData: Data?
    @Binding var showingShareSheet: Bool
    
    public init(pdfData: Binding<Data?>, showingShareSheet: Binding<Bool>) {
        self._pdfData = pdfData
        self._showingShareSheet = showingShareSheet
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Report Options".localized)) {
                    // Add print options here
                }
                
                Section {
                    Button("Generate Report".localized) {
                        // Generate PDF and set pdfData
                        showingShareSheet = true
                        dismiss()
                    }
                }
            }
            .navigationTitle("Print Report".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

public struct PDFPreviewView: View {
    let data: Data
    let onShare: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(data: Data, onShare: @escaping () -> Void) {
        self.data = data
        self.onShare = onShare
    }
    
    public var body: some View {
        NavigationView {
            PDFKitView(data: data)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Share".localized) {
                            onShare()
                        }
                    }
                }
        }
    }
}

#if os(iOS)
public struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

public struct DocumentPicker: UIViewControllerRepresentable {
    let types: [UTType]
    let onPick: (URL) -> Void
    
    public init(types: [UTType], onPick: @escaping (URL) -> Void) {
        self.types = types
        self.onPick = onPick
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        
        public init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}
#endif

public struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }
    
    public func updateUIView(_ uiView: PDFView, context: Context) {}
}

#Preview {
    NavigationView {
        ReportView()
    }
} 
// Helper components for consistency
struct SummaryRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body.bold())
                .foregroundColor(valueColor)
        }
    }
}

struct BreakdownRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
    }
}
