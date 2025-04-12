import SwiftUI

struct ShiftManagerView: View {
    @StateObject private var viewModel: ShiftManagerViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNotesFocused: Bool
    
    init(viewModel: ShiftManagerViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? ShiftManagerViewModel())
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            Text("Add New Shift")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Date Selection
            Button(action: { viewModel.showDatePicker = true }) {
                HStack {
                    Text("Select Date: \(dateFormatter.string(from: viewModel.selectedDate))")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.purple)
                .cornerRadius(25)
            }
            .padding(.horizontal)
            
            // Time Selection
            HStack(spacing: 12) {
                // Start Time
                Button(action: { viewModel.showStartTimePicker = true }) {
                    HStack {
                        Text("Start Time: \(timeFormatter.string(from: viewModel.startTime))")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color.purple)
                    .cornerRadius(25)
                }
                
                // End Time
                Button(action: { viewModel.showEndTimePicker = true }) {
                    HStack {
                        Text("End Time: \(timeFormatter.string(from: viewModel.endTime))")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color.purple)
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal)
            
            // Notes
            VStack(alignment: .leading, spacing: 4) {
                Text("Add Note")
                    .font(.headline)
                    .padding(.horizontal)
                
                TextEditor(text: $viewModel.notes)
                    .frame(height: 50)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .font(.body)
                    .focused($isNotesFocused)
            }
            .padding(.vertical, 4)
            
            // Add Shift Button
            Button(action: { viewModel.addShift() }) {
                Text("Add Shift")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.purple)
                    .cornerRadius(25)
            }
            .padding(.horizontal)
            .disabled(!viewModel.canAddShift)
            
            // Existing Shifts Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Existing Shifts")
                        .font(.title2)
                    Spacer()
                    Toggle("Current Month", isOn: $viewModel.showCurrentMonthOnly)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                }
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredShifts) { shift in
                            ShiftCard(shift: shift,
                                    onDelete: { await viewModel.deleteShift(shift) },
                                    onEdit: { viewModel.startEditing(shift) },
                                    onToggleSpecial: { await viewModel.toggleSpecialDay(shift) })
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Shift Manager")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showDatePicker) {
            DatePickerSheet(selectedDate: $viewModel.selectedDate,
                          isPresented: $viewModel.showDatePicker)
        }
        .sheet(isPresented: $viewModel.showStartTimePicker) {
            TimePickerSheet(selectedTime: $viewModel.startTime,
                          isPresented: $viewModel.showStartTimePicker)
        }
        .sheet(isPresented: $viewModel.showEndTimePicker) {
            TimePickerSheet(selectedTime: $viewModel.endTime,
                          isPresented: $viewModel.showEndTimePicker)
        }
        .sheet(isPresented: $viewModel.isEditing) {
            NavigationView {
                EditShiftView(shift: viewModel.shiftBeingEdited!,
                            onSave: { updatedShift in
                    Task {
                        await viewModel.updateShift(updatedShift)
                        viewModel.isEditing = false
                    }
                })
                .navigationTitle("Edit Shift")
                .navigationBarItems(trailing: Button("Cancel") {
                    viewModel.isEditing = false
                })
            }
        }
        .alert("Shift Already Exists", isPresented: $viewModel.showingDuplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("A shift already exists for this date and time period.")
        }
        .alert("Long Shift Warning", isPresented: $viewModel.showingLongShiftAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Accept") {
                // Create the shift despite the warning
                let calendar = Calendar.current
                let startComponents = calendar.dateComponents([.hour, .minute], from: viewModel.startTime)
                let endComponents = calendar.dateComponents([.hour, .minute], from: viewModel.endTime)
                
                let shiftStart = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                            minute: startComponents.minute ?? 0,
                                            second: 0,
                                            of: viewModel.selectedDate) ?? viewModel.selectedDate
                let shiftEnd = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                          minute: endComponents.minute ?? 0,
                                          second: 0,
                                          of: viewModel.selectedDate) ?? viewModel.selectedDate
                
                Task {
                    await viewModel.createShift(startTime: shiftStart, endTime: shiftEnd, notes: viewModel.notes)
                }
            }
        } message: {
            Text("You are trying to add a shift longer than 12 hours. Are you sure you want to proceed?")
        }
        .task {
            await viewModel.loadShifts()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isNotesFocused = false
                }
            }
        }
    }
}

struct ShiftCard: View {
    let shift: ShiftModel
    let onDelete: () async -> Void
    let onEdit: () -> Void
    let onToggleSpecial: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and Actions
            HStack {
                Text(shift.startTime, style: .date)
                    .font(.headline)
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }
                
                Button {
                    Task {
                        await onDelete()
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                
                Button {
                    Task {
                        await onToggleSpecial()
                    }
                } label: {
                    Image(systemName: shift.isSpecialDay ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
            
            // Times
            Text("Start Time: \(shift.startTime, format: .dateTime.hour().minute()) - End Time: \(shift.endTime, format: .dateTime.hour().minute())")
            
            // Duration and Wages
            HStack {
                Text("Total Hours: \(shift.duration / 3600, specifier: "%.2f")")
                    .foregroundColor(.primary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Gross Wage: ₪\(shift.grossWage, specifier: "%.2f")")
                    Text("Net Wage: ₪\(shift.netWage, specifier: "%.2f")")
                }
            }
            
            if !shift.notes.isEmpty {
                Text(shift.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            DatePicker("Select Date",
                      selection: $selectedDate,
                      displayedComponents: .date)
                .datePickerStyle(.graphical)
                .navigationBarItems(trailing: Button("Done") {
                    isPresented = false
                })
                .padding()
        }
    }
}

struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            DatePicker("Select Time",
                      selection: $selectedTime,
                      displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .navigationBarItems(trailing: Button("Done") {
                    isPresented = false
                })
                .padding()
        }
    }
}

struct EditShiftView: View {
    let shift: ShiftModel
    let onSave: (ShiftModel) -> Void
    
    @State private var editedDate: Date
    @State private var editedStartTime: Date
    @State private var editedEndTime: Date
    @State private var editedNotes: String
    @State private var isSpecialDay: Bool
    
    init(shift: ShiftModel, onSave: @escaping (ShiftModel) -> Void) {
        self.shift = shift
        self.onSave = onSave
        _editedDate = State(initialValue: shift.startTime)
        _editedStartTime = State(initialValue: shift.startTime)
        _editedEndTime = State(initialValue: shift.endTime)
        _editedNotes = State(initialValue: shift.notes)
        _isSpecialDay = State(initialValue: shift.isSpecialDay)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Shift Details")) {
                DatePicker("Date", selection: $editedDate, displayedComponents: .date)
                DatePicker("Start Time", selection: $editedStartTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: $editedEndTime, displayedComponents: .hourAndMinute)
                Toggle("Special Day", isOn: $isSpecialDay)
                TextField("Notes", text: $editedNotes)
            }
            
            Section {
                Button("Save Changes") {
                    let calendar = Calendar.current
                    
                    // Combine date and time
                    let startComponents = calendar.dateComponents([.hour, .minute], from: editedStartTime)
                    let endComponents = calendar.dateComponents([.hour, .minute], from: editedEndTime)
                    
                    let updatedStartTime = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                                       minute: startComponents.minute ?? 0,
                                                       second: 0,
                                                       of: editedDate) ?? editedDate
                    
                    let updatedEndTime = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                                     minute: endComponents.minute ?? 0,
                                                     second: 0,
                                                     of: editedDate) ?? editedDate
                    
                    let updatedShift = ShiftModel(
                        id: shift.id,
                        title: shift.title,
                        startTime: updatedStartTime,
                        endTime: updatedEndTime,
                        notes: editedNotes,
                        isOvertime: shift.isOvertime,
                        isSpecialDay: isSpecialDay,
                        category: shift.category,
                        createdAt: shift.createdAt,
                        grossWage: shift.grossWage,
                        netWage: shift.netWage
                    )
                    
                    onSave(updatedShift)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ShiftManagerPreviewContainer: View {
    var body: some View {
        NavigationView {
            ShiftManagerView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

#Preview {
    ShiftManagerPreviewContainer()
} 