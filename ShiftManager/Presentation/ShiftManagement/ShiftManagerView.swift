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
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        formatter.formattingContext = .standalone
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            Text("Add New Shift".localized)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Date Selection
            Button(action: { viewModel.showDatePicker = true }) {
                HStack {
                    Text(String(format: "Select Date: %@".localized, dateFormatter.string(from: viewModel.selectedDate)))
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
                        Text(String(format: "Start Time: %@".localized, timeFormatter.string(from: viewModel.startTime)))
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
                        Text(String(format: "End Time: %@".localized, timeFormatter.string(from: viewModel.endTime)))
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
                Text("Add Note".localized)
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
                Text("Add Shift".localized)
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
                    Text("Existing Shifts".localized)
                        .font(.title2)
                    Spacer()
                    Toggle(viewModel.showCurrentMonthOnly ? "Current Month".localized : "All Months".localized, isOn: $viewModel.showCurrentMonthOnly)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                }
                .padding(.horizontal)
                
                ScrollView {
                    if viewModel.filteredShifts.isEmpty {
                        EmptyStateView(
                            title: "No Shifts Found".localized,
                            message: "You don't have any shifts scheduled. Add your first shift using the form above.".localized
                        )
                        .padding(.top, 20)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.filteredShifts) { shift in
                                ShiftCard(shift: shift,
                                        onDelete: { viewModel.deleteShift(shift) },
                                        onEdit: { viewModel.startEditing(shift) },
                                        onToggleSpecial: { viewModel.toggleSpecialDay(shift) })
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Shift Manager".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showDatePicker) {
            DatePickerSheetView(selectedDate: $viewModel.selectedDate, isPresented: $viewModel.showDatePicker)
        }
        .sheet(isPresented: $viewModel.showStartTimePicker) {
            NavigationView {
                VStack(spacing: 24) {
                    Text("Select Time".localized)
                        .font(.headline)
                        .padding(.top)
                    TimePickerRepresentable(selectedTime: $viewModel.startTime, locale: Locale(identifier: LocalizationManager.shared.currentLanguage))
                        .frame(maxWidth: 350, maxHeight: 350)
                        .padding()
                    Spacer()
                }
                .navigationBarItems(trailing: Button("Done".localized) {
                    viewModel.showStartTimePicker = false
                })
                .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $viewModel.showEndTimePicker) {
            NavigationView {
                VStack(spacing: 24) {
                    Text("Select Time".localized)
                        .font(.headline)
                        .padding(.top)
                    TimePickerRepresentable(selectedTime: $viewModel.endTime, locale: Locale(identifier: LocalizationManager.shared.currentLanguage))
                        .frame(maxWidth: 350, maxHeight: 350)
                        .padding()
                    Spacer()
                }
                .navigationBarItems(trailing: Button("Done".localized) {
                    viewModel.showEndTimePicker = false
                })
                .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $viewModel.isEditing) {
            NavigationView {
                EditShiftView(shift: viewModel.shiftBeingEdited!,
                            onSave: { updatedShift in
                    Task {
                        viewModel.updateShift(updatedShift)
                        viewModel.isEditing = false
                    }
                })
                .navigationTitle("Edit Shift".localized)
                .navigationBarItems(trailing: Button("Cancel".localized) {
                    viewModel.isEditing = false
                })
            }
        }
        .alert("Shift Already Exists".localized, isPresented: $viewModel.showingDuplicateAlert) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text("A shift already exists for this date and time period.".localized)
        }
        .alert("Long Shift Warning".localized, isPresented: $viewModel.showingLongShiftAlert) {
            Button("Cancel".localized, role: .cancel) { }
            Button("Accept".localized) {
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
            Text("You are trying to add a shift longer than 12 hours. Are you sure you want to proceed?".localized)
        }
        .task {
            await viewModel.loadShifts()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done".localized) {
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
            let startTime = shift.startTime.formatted(date: .omitted, time: .shortened)
            let endTime = shift.endTime.formatted(date: .omitted, time: .shortened)
            Text(String(format: "Start Time: %@ - End Time: %@".localized, startTime, endTime))
            
            // Duration and Wages
            HStack {
                let formattedDuration = String(format: "%.2f", shift.duration / 3600)
                Text(String(format: "Total Hours: %@".localized, formattedDuration))
                    .foregroundColor(.primary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    // Use asCurrency extension for proper currency symbol display
                    Text("Gross Wage:".localized + " " + shift.grossWage.asCurrency)
                    Text("Net Wage:".localized + " " + shift.netWage.asCurrency)
                    
                    // Add tax calculation note
                    Text("Tax calculation is an estimate".localized)
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date".localized,
                      selection: $selectedDate,
                      displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    // Use a strong Hebrew locale when Hebrew is selected
                    .environment(\.locale, Locale(identifier: localizationManager.currentLanguage))
                    // Set calendar identifier based on current language
                    .environment(\.calendar, Calendar(identifier: .gregorian))
                    // Force direction based on language
                    .environment(\.layoutDirection, localizationManager.currentLanguage == "he" ? .rightToLeft : .leftToRight)
                
                // Add explicit weekday labels for Hebrew
                if localizationManager.currentLanguage == "he" {
                    HStack(spacing: 20) {
                        Text("א'").font(.caption).foregroundColor(.gray)
                        Text("ב'").font(.caption).foregroundColor(.gray)
                        Text("ג'").font(.caption).foregroundColor(.gray)
                        Text("ד'").font(.caption).foregroundColor(.gray)
                        Text("ה'").font(.caption).foregroundColor(.gray)
                        Text("ו'").font(.caption).foregroundColor(.gray)
                        Text("ש'").font(.caption).foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarItems(trailing: Button("Done".localized) {
                isPresented = false
            })
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
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        return formatter
    }()
    
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
            Section {

                DatePicker("Date".localized, selection: $editedDate, displayedComponents: .date)
                Button(action: { showStartTimePicker = true }) {
    HStack {
        Text("Start Time: ")
            .font(.headline)
        Text(timeFormatter.string(from: editedStartTime))
            .font(.title3)
            .foregroundColor(.accentColor)
        Spacer()
    }
}
.sheet(isPresented: $showStartTimePicker) {
    NavigationView {
        VStack(spacing: 24) {
            Text("Select Time".localized)
                .font(.headline)
                .padding(.top)
            TimePickerRepresentable(selectedTime: $editedStartTime, locale: Locale(identifier: LocalizationManager.shared.currentLanguage))
                .frame(maxWidth: 350, maxHeight: 350)
                .padding()
            Spacer()
        }
        .navigationBarItems(trailing: Button("Done".localized) {
            showStartTimePicker = false
        })
        .background(Color(.systemBackground))
    }
}
                Button(action: { showEndTimePicker = true }) {
    HStack {
        Text("End Time: ")
            .font(.headline)
        Text(timeFormatter.string(from: editedEndTime))
            .font(.title3)
            .foregroundColor(.accentColor)
        Spacer()
    }
}
.sheet(isPresented: $showEndTimePicker) {
    NavigationView {
        VStack(spacing: 24) {
            Text("Select Time".localized)
                .font(.headline)
                .padding(.top)
            TimePickerRepresentable(selectedTime: $editedEndTime, locale: Locale(identifier: LocalizationManager.shared.currentLanguage))
                .frame(maxWidth: 350, maxHeight: 350)
                .padding()
            Spacer()
        }
        .navigationBarItems(trailing: Button("Done".localized) {
            showEndTimePicker = false
        })
        .background(Color(.systemBackground))
    }
}
                Toggle("Special Day".localized, isOn: $isSpecialDay)
                TextField("Notes".localized, text: $editedNotes)
            }
            
            Section {
                Button("Save Changes".localized) {
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
                        category: shift.category,
                        startTime: updatedStartTime,
                        endTime: updatedEndTime,
                        notes: editedNotes,
                        isOvertime: shift.isOvertime,
                        isSpecialDay: isSpecialDay,
                        grossWage: shift.grossWage,
                        netWage: shift.netWage,
                        createdAt: shift.createdAt
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