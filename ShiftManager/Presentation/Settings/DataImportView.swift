import SwiftUI

struct DataImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var notes = ""
    @State private var isSpecialDay = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Add Shift")) {
                DatePicker("Start Time", selection: $startDate)
                DatePicker("End Time", selection: $endDate)
                
                TextField("Notes", text: $notes)
                
                Toggle("Special Day", isOn: $isSpecialDay)
            }
            
            Section {
                Button("Add Shift") {
                    addShift()
                }
            }
        }
        .navigationTitle("Add Shift")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addShift() {
        let shift = Shift(context: viewContext)
        shift.id = UUID()
        shift.title = "Shift on \(startDate.formatted(date: .numeric, time: .omitted))"
        shift.startTime = startDate
        shift.endTime = endDate
        shift.notes = notes
        shift.createdAt = Date()
        shift.isOvertime = false
        shift.isSpecialDay = isSpecialDay
        shift.category = ""
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save shift: \(error.localizedDescription)"
            showingError = true
        }
    }
} 