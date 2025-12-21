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
    

    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Form Section
                VStack(spacing: 12) {
                    // Date Selection
                    Button(action: { viewModel.showDatePicker = true }) {
                        HStack {
                            Text(String(format: "Select Date: %@".localized, dateFormatter.string(from: viewModel.selectedDate)))
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        .background(Color.purple)
                        .cornerRadius(25)
                    }
                    
                    // Time Selection
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.purple)
                            Text("Start Time".localized)
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        .padding()
                        
                        Divider()
                            .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.purple)
                            Text("End Time".localized)
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        .padding()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add Note".localized)
                            .font(.headline)
                        
                        TextEditor(text: $viewModel.notes)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .font(.body)
                            .focused($isNotesFocused)
                    }
                    
                    // Add Shift Button
                    Button(action: { viewModel.addShift() }) {
                        Text("Add Shift".localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(viewModel.canAddShift ? Color.purple : Color.gray)
                            .cornerRadius(25)
                    }
                    .padding(.top, 8)
                    .disabled(!viewModel.canAddShift)
                }
                .padding(.horizontal)
                
                // Existing Shifts Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .lastTextBaseline) {
                        Text("Existing Shifts".localized)
                            .font(.title2)
                            .bold()
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Toggle(isOn: $viewModel.showCurrentMonthOnly) {
                                Text(viewModel.showCurrentMonthOnly ? "Current Month".localized : "All Months".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                            .labelsHidden()
                            
                            Text(viewModel.showCurrentMonthOnly ? "Current Month".localized : "All Months".localized)
                                .font(.caption2)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal)
                    
                    if viewModel.filteredShifts.isEmpty {
                        EmptyStateView(
                            title: "No Shifts Found".localized,
                            message: "You don't have any shifts scheduled. Add your first shift using the form above.".localized
                        )
                        .padding(.top, 20)
                    } else {
                        VStack(spacing: 12) {
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
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Shift Manager".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showDatePicker) {
            DatePickerSheetView(selectedDate: $viewModel.selectedDate, isPresented: $viewModel.showDatePicker)
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
            Text("Overlapping shifts are not allowed. Please choose a different time.".localized)
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
        .alert("Daily Hour Limit Exceeded".localized, isPresented: $viewModel.showingDailyLimitAlert) {
            Button("OK".localized, role: .cancel) { }
        } message: {
            Text("Total daily hours would exceed 12 hours. The maximum allowed is 12 hours per day.".localized)
        }
        .alert("Shift Limit Reached".localized, isPresented: $viewModel.showingShiftLimitAlert) {
            Button("Cancel".localized, role: .cancel) { }
            Button("Upgrade to Premium".localized) {
                PurchaseManager.shared.showPaywall = true
            }
        } message: {
            Text("You've reached the free limit of 50 shifts. Upgrade to Premium for unlimited shifts!".localized)
        }
        .sheet(isPresented: Binding(
            get: { PurchaseManager.shared.showPaywall },
            set: { PurchaseManager.shared.showPaywall = $0 }
        )) {
            PaywallView(triggerFeature: .unlimitedShifts)
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
        .refreshOnLanguageChange()
    }
}

struct ShiftCard: View {
    let shift: ShiftModel
    let onDelete: () async -> Void
    let onEdit: () -> Void
    let onToggleSpecial: () async -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and Actions
            HStack {
                Text(shift.startTime.formattedString())
                    .font(.headline)
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }
                
                Button {
                    showDeleteConfirmation = true
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
            let startTime = shift.startTime.timeString()
            let endTime = shift.endTime.timeString()
            Text(String(format: "Start Time: %@ - End Time: %@".localized, startTime, endTime))
            
            // Duration and Wages
            HStack {
                Text(String(format: "Total Hours: %@".localized, String(format: "%.2f", shift.duration / 3600)))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Gross Wage:".localized)
                    Text(shift.grossWage.asCurrency)
                        .bold()
                }
                
                HStack {
                    Text("Net Wage:".localized)
                    Text(shift.netWage.asCurrency)
                        .bold()
                        .foregroundColor(.green)
                }
                
                Text("Tax calculation is an estimate".localized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
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
        .alert("Delete Shift".localized, isPresented: $showDeleteConfirmation) {
            Button("Cancel".localized, role: .cancel) { }
            Button("Delete".localized, role: .destructive) {
                Task {
                    await onDelete()
                }
            }
        } message: {
            Text("Are you sure you want to delete this shift? This action cannot be undone.".localized)
        }
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
                DatePicker("Start Time".localized, selection: $editedStartTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time".localized, selection: $editedEndTime, displayedComponents: .hourAndMinute)
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