import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import UIKit

public struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    @State private var showingPDFPreview = false
    @State private var pdfData: Data?
    @State private var showingShareSheet = false
    @State private var selectedView: ReportViewType = .weekly
    @State private var showingSearchSheet = false
    @State private var showingPrintSheet = false
    
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
            
            // Shifts List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.shifts) { shift in
                        ShiftReportCard(shift: shift)
                    }
                }
                .padding()
            }
            
            // Summary Section
            VStack(spacing: 8) {
                Divider()
                
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
                
                Text("Wage Breakdown".localized)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
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
                .padding(.horizontal)
            }
            .padding(.vertical)
            
            // Add a note about tax calculation estimates
            Text("Note: Tax calculation is an estimate and may vary based on local regulations.".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
        }
        .navigationTitle("Reports".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingSearchSheet = true }) {
                    Image(systemName: "magnifyingglass")
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
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(shift.startTime, style: .date)
                .font(.headline)
            
            let startTime = shift.startTime.formatted(date: .omitted, time: .shortened)
            let endTime = shift.endTime.formatted(date: .omitted, time: .shortened)
            Text(String(format: "Start Time: %@ - End Time: %@".localized, startTime, endTime))
                .foregroundColor(.secondary)
            
            HStack {
                Spacer()
                Text(shift.grossWage.asCurrency)
                    .font(.headline)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

public struct SearchShiftView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ReportViewModel()
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showResults = false
    @State private var showingShareSheet = false
    @State private var pdfData: Data?
    
    private let exportService = ExportService()
    
    public init() {}
    
    private func exportToPDF() {
        Task {
            do {
                let username = UserDefaults.standard.string(forKey: "username") ?? "User"
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                let periodString = "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
                pdfData = try await exportService.generateSearchReport(
                    shifts: viewModel.shifts,
                    username: username,
                    periodString: periodString,
                    summary: (
                        totalDays: viewModel.totalWorkingDays,
                        totalHours: viewModel.totalHours,
                        grossWage: viewModel.grossWage,
                        netWage: viewModel.netWage
                    )
                )
                showingShareSheet = true
            } catch {
                print("Error generating PDF: \(error)")
            }
        }
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Date Selection
                Form {
                    Section(header: Text("Search Period".localized)) {
                        DatePicker("Start Date".localized,
                                 selection: $startDate,
                                 displayedComponents: [.date])
                        
                        DatePicker("End Date".localized,
                                 selection: $endDate,
                                 displayedComponents: [.date])
                    }
                    
                    Section {
                        Button("Search".localized) {
                            Task {
                                await viewModel.loadShiftsForDateRange(start: startDate, end: endDate)
                                showResults = true
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                    }
                }
                
                if showResults {
                    if viewModel.shifts.isEmpty {
                        Text("No shifts found for the selected period".localized)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        VStack {
                            // Export to PDF Button
                            Button(action: exportToPDF) {
                                HStack {
                                    Image(systemName: "doc.text")
                                    Text("Export to PDF".localized)
                                }
                                .foregroundColor(.blue)
                                .padding()
                            }
                            
                            // Results Section
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.shifts) { shift in
                                        ShiftReportCard(shift: shift)
                                    }
                                }
                                .padding()
                            }
                            
                            // Summary Section
                            VStack(spacing: 8) {
                                Divider()
                                
                                Group {
                                    HStack {
                                        Text("Total Working Days:".localized)
                                        Spacer()
                                        Text("\(viewModel.totalWorkingDays)")
                                    }
                                    
                                    HStack {
                                        Text("Total Hours:".localized)
                                        Spacer()
                                        Text(String(format: "%.2f", viewModel.totalHours))
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
                                
                                // Add a note about tax calculation estimates
                                Text("Note: Tax calculation is an estimate and may vary based on local regulations.".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.top, 2)
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Search".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel".localized) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet, content: {
                if let data = pdfData {
                    ShareSheet(activityItems: [data])
                }
            })
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
                    Button("Cancel") {
                        dismiss()
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
                        Button("Done") {
                            dismiss()
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