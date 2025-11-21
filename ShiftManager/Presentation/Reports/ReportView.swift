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
        VStack(spacing: 0) {
            // View Type Selector
            viewTypeSelectorBar
            
            // Date Navigation
            HStack {
                Button(action: { viewModel.previousPeriod() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(viewModel.periodTitle)
                    .font(.title2)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: { viewModel.nextPeriod() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            Text(viewModel.periodRangeText)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)
            
            // Summary Section moved to top (non-scrolling)
            VStack(spacing: 8) {
                Group {
                    HStack {
                        Text("Total Working Days:".localized)
                        Spacer()
                        Text("\(viewModel.totalWorkingDays)")
                    }
                    
                    HStack {
                        Text("Total Hours:".localized)
                        Spacer()
                        let formattedHours = String(format: "%.2f", viewModel.totalHours)
                        Text(formattedHours)
                    }
                    
                    HStack {
                        Text("Gross Wage:".localized)
                        Spacer()
                        Text(viewModel.grossWage.asCurrency)
                    }
                    
                    HStack {
                        Text("Net Wage:".localized)
                        Spacer()
                        Text(viewModel.netWage.asCurrency)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 16) {
                    // Wage Breakdown Section moved up
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wage Breakdown".localized)
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Group {
                            // Regular day rates
                            if viewModel.regularHours > 0 {
                                HStack {
                                    Text("100%")
                                    Spacer()
                                    let formattedHours = String(format: "%.2f", viewModel.regularHours)
                                    Text(formattedHours)
                                }
                            }
                            
                            // First overtime (125%)
                            if viewModel.overtimeHours125 > 0 {
                                HStack {
                                    Text("125%")
                                    Spacer()
                                    let formattedHours = String(format: "%.2f", viewModel.overtimeHours125)
                                    Text(formattedHours)
                                }
                            }
                            
                            // Second overtime (150%)
                            if viewModel.overtimeHours150 > 0 {
                                HStack {
                                    Text("150%")
                                    Spacer()
                                    let formattedHours = String(format: "%.2f", viewModel.overtimeHours150)
                                    Text(formattedHours)
                                }
                            }
                            
                            // Special day overtime (175%)
                            if viewModel.overtimeHours175 > 0 {
                                HStack {
                                    Text("175%")
                                    Spacer()
                                    let formattedHours = String(format: "%.2f", viewModel.overtimeHours175)
                                    Text(formattedHours)
                                }
                            }
                            
                            // Special day extended overtime (200%)
                            if viewModel.overtimeHours200 > 0 {
                                HStack {
                                    Text("200%")
                                    Spacer()
                                    let formattedHours = String(format: "%.2f", viewModel.overtimeHours200)
                                    Text(formattedHours)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Visual Charts Section 
                    VStack(spacing: 12) {
                        Text("Visual Summary".localized)
                            .font(.title2)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 16)
                        
                        // Hours Breakdown Chart
                        HoursChartView(
                            regularHours: viewModel.regularHours,
                            overtimeHours125: viewModel.overtimeHours125,
                            overtimeHours150: viewModel.overtimeHours150,
                            overtimeHours175: viewModel.overtimeHours175,
                            overtimeHours200: viewModel.overtimeHours200
                        )
                        
                        // Wage Distribution Chart
                        WageChartView(
                            regularHours: viewModel.regularHours,
                            overtimeHours125: viewModel.overtimeHours125,
                            overtimeHours150: viewModel.overtimeHours150,
                            overtimeHours175: viewModel.overtimeHours175,
                            overtimeHours200: viewModel.overtimeHours200,
                            hourlyRate: UserDefaults.standard.double(forKey: "hourlyWage")
                        )
                    }
                    .padding(.horizontal)
                    
                    // List of shifts moved to bottom of scrollView
                    Text("Shifts".localized)
                        .font(.title2)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                    
                    ForEach(viewModel.shifts) { shift in
                        ShiftReportCard(shift: shift)
                    }
                    
                    // Add a note about tax calculation estimates
                    Text("Note: Tax calculation is an estimate and may vary based on local regulations.".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                }
                .padding()
            }
        }
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
                Section(header: Text("Report Options")) {
                    // Add print options here
                }
                
                Section {
                    Button("Generate Report") {
                        // Generate PDF and set pdfData
                        showingShareSheet = true
                        dismiss()
                    }
                }
            }
            .navigationTitle("Print Report")
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
                        Button("Share") {
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