import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    @State private var showingPDFPreview = false
    @State private var pdfData: Data?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Report Type")) {
                    Picker("Report Type", selection: $viewModel.selectedReportType) {
                        ForEach(ReportType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Date Range")) {
                    DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: [.date])
                    DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: [.date])
                }
                
                Section {
                    Button("Generate Report") {
                        Task {
                            await viewModel.generateReport()
                            if let pdf = viewModel.pdfData {
                                pdfData = pdf
                                showingPDFPreview = true
                            }
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
                
                Section(header: Text("Backup & Restore")) {
                    Button("Export All Data") {
                        Task {
                            await viewModel.exportData()
                        }
                    }
                    
                    Button("Import Data") {
                        viewModel.showingFilePicker = true
                    }
                }
            }
            .navigationTitle("Reports")
            .sheet(isPresented: $showingPDFPreview) {
                if let pdfData = pdfData {
                    PDFPreviewView(data: pdfData, onShare: {
                        showingShareSheet = true
                    })
                }
            }
            .sheet(isPresented: $viewModel.showingFilePicker) {
                DocumentPicker(types: [.json]) { url in
                    Task {
                        await viewModel.importData(from: url)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = pdfData {
                    ShareSheet(items: [pdfData])
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }
}

struct PDFPreviewView: View {
    let data: Data
    let onShare: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            PDFKitView(data: data)
                .navigationTitle("Report Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Share") {
                            onShare()
                        }
                    }
                }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DocumentPicker: UIViewControllerRepresentable {
    let types: [UTType]
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        
        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

enum ReportType: String, CaseIterable, Identifiable {
    case weekly = "Weekly Summary"
    case monthly = "Monthly Summary"
    case custom = "Custom Range"
    
    var id: String { rawValue }
}

class ReportViewModel: ObservableObject {
    @Published var selectedReportType: ReportType = .weekly
    @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var endDate: Date = Date()
    @Published var pdfData: Data?
    @Published var error: Error?
    @Published var showingFilePicker = false
    
    private let repository: ShiftRepositoryProtocol
    private let exportService: ExportServiceProtocol
    
    var isValid: Bool {
        endDate >= startDate
    }
    
    init(repository: ShiftRepositoryProtocol = ShiftRepository(),
         exportService: ExportServiceProtocol = ExportService()) {
        self.repository = repository
        self.exportService = exportService
    }
    
    @MainActor
    func generateReport() async {
        do {
            let shifts = try await repository.fetchShiftsInDateRange(from: startDate, to: endDate)
            pdfData = try await exportService.generatePDFReport(shifts: shifts, startDate: startDate, endDate: endDate)
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func exportData() async {
        do {
            let data = try await exportService.exportDataToJSON()
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("shifts_backup.json")
            try data.write(to: url)
            showingFilePicker = true
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func importData(from url: URL) async {
        do {
            let data = try Data(contentsOf: url)
            try await exportService.importDataFromJSON(data)
        } catch {
            self.error = error
        }
    }
}

#Preview {
    ReportView()
} 