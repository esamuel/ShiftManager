import SwiftUI
import PDFKit

public struct MonthlyReportView: View {
    @StateObject private var viewModel = MonthlyReportViewModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showingPDFPreview = false
    @State private var pdfData: Data?
    @State private var showingShareSheet = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isGeneratingPDF = false
    @Environment(\.colorScheme) var colorScheme
    private let exportService = ExportService()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Month/Year Selector
                monthSelectorSection
                
                // Summary Card
                if !viewModel.shifts.isEmpty {
                    summaryCard
                    
                    // Export Button
                    exportButton
                } else if !viewModel.isLoading {
                    emptyStateView
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                }
            }
            .padding()
        }
        .navigationTitle("Monthly Report".localized)
        .alert("Error".localized, isPresented: $showingError) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $purchaseManager.showPaywall) {
            PaywallView(triggerFeature: .pdfExport)
        }
        .sheet(isPresented: $showingPDFPreview) {
            if let pdfData = pdfData {
                NavigationView {
                    PDFKitView(data: pdfData)
                        .navigationTitle("Monthly Report".localized)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close".localized) {
                                    showingPDFPreview = false
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showingShareSheet = true
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                        .sheet(isPresented: $showingShareSheet) {
                            if let url = savePDFToTemporaryDirectory(pdfData: pdfData) {
                                ShareSheet(activityItems: [url])
                            }
                        }
                }
            }
        }
    }
    
    private func savePDFToTemporaryDirectory(pdfData: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "MonthlyReport_\(Date().timeIntervalSince1970).pdf"
        let tempURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
    
    private var monthSelectorSection: some View {
        VStack(spacing: 16) {
            Text("Month & Year".localized)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                // Previous Month Button
                Button(action: {
                    viewModel.previousMonth()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                
                // Month/Year Display
                Text(viewModel.monthYearString)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(minWidth: 200)
                    .multilineTextAlignment(.center)
                
                // Next Month Button
                Button(action: {
                    viewModel.nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                .disabled(viewModel.selectedYear == Calendar.current.component(.year, from: Date()) && 
                         viewModel.selectedMonth >= Calendar.current.component(.month, from: Date()))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Report Summary".localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Divider()
            
            // Total Shifts
            summaryRow(title: "Total Shifts:".localized, value: "\(viewModel.totalShifts)", icon: "calendar")
            
            // Total Working Days
            summaryRow(title: "Total Working Days:".localized, value: "\(viewModel.totalWorkingDays)", icon: "calendar.badge.clock")
            
            Divider()
            
            // Total Hours
            summaryRow(title: "Total Hours:".localized, value: String(format: "%.2f", viewModel.totalHours), icon: "clock.fill")
            
            // Regular Hours
            summaryRow(title: "Regular Shift Hours:".localized, value: String(format: "%.2f", viewModel.regularHours), icon: "clock")
            
            // Overtime Hours
            summaryRow(title: "Overtime Hours:".localized, value: String(format: "%.2f", viewModel.overtimeHours), icon: "clock.arrow.circlepath")
            
            Divider()
            
            // Gross Wage
            summaryRow(
                title: "Gross Wage:".localized,
                value: LocalizationManager.shared.formatCurrency(viewModel.grossWage),
                icon: "banknote.fill",
                valueColor: .green
            )
            
            // Net Wage
            summaryRow(
                title: "Net Wage:".localized,
                value: LocalizationManager.shared.formatCurrency(viewModel.netWage),
                icon: "dollarsign.circle.fill",
                valueColor: .blue
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func summaryRow(title: String, value: String, icon: String, valueColor: Color = .primary) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
    
    private var exportButton: some View {
        Button(action: {
            generatePDF()
        }) {
            HStack {
                if isGeneratingPDF {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                }
                Text(isGeneratingPDF ? "Generating...".localized : "Export to PDF".localized)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.purple.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .disabled(isGeneratingPDF)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No data available for selected month".localized)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 50)
    }
    
    private func generatePDF() {
        // Check premium access first
        guard purchaseManager.hasAccess(to: .pdfExport) else {
            purchaseManager.showPaywall = true
            return
        }
        
        guard !viewModel.shifts.isEmpty else {
            errorMessage = "No data available to export".localized
            showingError = true
            return
        }
        
        isGeneratingPDF = true
        
        Task {
            do {
                let username = UserDefaults.standard.string(forKey: "userName") ?? "User"
                let summary = (
                    totalShifts: viewModel.totalShifts,
                    totalDays: viewModel.totalWorkingDays,
                    totalHours: viewModel.totalHours,
                    regularHours: viewModel.regularHours,
                    overtimeHours: viewModel.overtimeHours,
                    grossWage: viewModel.grossWage,
                    netWage: viewModel.netWage
                )
                
                pdfData = try await exportService.generateMonthlyReport(
                    shifts: viewModel.shifts,
                    month: viewModel.selectedMonth,
                    year: viewModel.selectedYear,
                    username: username,
                    summary: summary
                )
                
                await MainActor.run {
                    isGeneratingPDF = false
                    if pdfData != nil {
                        showingPDFPreview = true
                    } else {
                        errorMessage = "Failed to generate PDF: No data returned".localized
                        showingError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isGeneratingPDF = false
                    errorMessage = "Error generating PDF: \(error.localizedDescription)"
                    showingError = true
                }
                print("Error generating PDF: \(error)")
            }
        }
    }
}

