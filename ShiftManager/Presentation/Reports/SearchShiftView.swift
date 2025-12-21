import SwiftUI 

public struct SearchShiftView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ReportViewModel()
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showResults = false
    @State private var showingPDFPreview = false
    @State private var pdfData: Data?
    @State private var showingShareSheet = false
    
    private let exportService = ExportService()
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                // Date Selection
                Form {
                    Section(header: Text(NSLocalizedString("Search Period", comment: ""))) {
                        VStack(spacing: 0) {
                            // Start Date Selector
                            HStack {
                                Text(NSLocalizedString("Start Date", comment: ""))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 100, alignment: LocalizationManager.shared.currentLanguage == "he" ? .trailing : .leading)
                                
                                Button(action: {
                                    viewModel.showingStartDatePicker = true
                                }) {
                                    CustomDateView(date: startDate)
                                        .frame(height: 44)
                                        .frame(maxWidth: .infinity, alignment: LocalizationManager.shared.currentLanguage == "he" ? .trailing : .leading)
                                        .padding(.horizontal, 8)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 2)
                            
                            // End Date Selector
                            HStack {
                                Text(NSLocalizedString("End Date", comment: ""))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 100, alignment: LocalizationManager.shared.currentLanguage == "he" ? .trailing : .leading)
                                
                                Button(action: {
                                    viewModel.showingEndDatePicker = true
                                }) {
                                    CustomDateView(date: endDate)
                                        .frame(height: 44)
                                        .frame(maxWidth: .infinity, alignment: LocalizationManager.shared.currentLanguage == "he" ? .trailing : .leading)
                                        .padding(.horizontal, 8)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .frame(height: 140)
                
                // Search button
                Button {
                    Task {
                        await viewModel.searchShifts(from: startDate, to: endDate)
                        showResults = true
                    }
                } label: {
                    if LocalizationManager.shared.currentLanguage == "he" {
                        // Hebrew label with explicit layout
                        HStack {
                            Text("חיפוש")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .shadow(color: .purple.opacity(0.4), radius: 5, x: 0, y: 3)
                        .environment(\.layoutDirection, .rightToLeft)
                    } else {
                        Text("Search".localized)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.purple)
                            .cornerRadius(10)
                            .shadow(color: .purple.opacity(0.4), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                // Results Section
                if showResults {
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.shifts.isEmpty {
                                VStack(spacing: 20) {
                                    Image("NoShiftsIllustration")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                    
                                    Text("No shifts found in the selected period".localized)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Try selecting a different date range".localized)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 50)
                            } else {
                                ForEach(viewModel.shifts) { shift in
                                    ShiftReportCard(shift: shift)
                                        .padding(.horizontal)
                                }
                                
                                // Export to PDF Button
                                Button {
                                    Task {
                                        do {
                                            let summary = (
                                                totalDays: viewModel.totalWorkingDays,
                                                totalHours: viewModel.totalHours,
                                                grossWage: viewModel.grossWage,
                                                netWage: viewModel.netWage
                                            )
                                            let periodString = "\(startDate.formatted(date: .long, time: .omitted)) - \(endDate.formatted(date: .long, time: .omitted))"
                                            let username = UserDefaults.standard.string(forKey: "username") ?? "User"
                                            pdfData = try await exportService.generateSearchReport(
                                                shifts: viewModel.shifts,
                                                username: username,
                                                periodString: periodString,
                                                summary: summary
                                            )
                                            showingPDFPreview = true
                                        } catch {
                                            print("Error generating PDF: \(error)")
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "doc.text")
                                        Text("Export to PDF".localized)
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                
                Spacer()
            }
            .navigationTitle(LocalizationManager.shared.currentLanguage == "he" ? "חיפוש" : "Search".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingStartDatePicker) {
                DatePickerSheetView(selectedDate: $startDate, isPresented: $viewModel.showingStartDatePicker)
            }
            .sheet(isPresented: $viewModel.showingEndDatePicker) {
                DatePickerSheetView(selectedDate: $endDate, isPresented: $viewModel.showingEndDatePicker)
            }
            .sheet(isPresented: $showingPDFPreview) {
                if let data = pdfData {
                    PDFPreviewView(data: data) {
                        showingShareSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let data = pdfData {
                    ShareSheet(activityItems: [data])
                }
            }
        }
        .padding()
        .onAppear {
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            endDate = Date()
        }
    }
}