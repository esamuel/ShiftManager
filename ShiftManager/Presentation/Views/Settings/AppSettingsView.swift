import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var baseHoursWeekday: Double = 8
    @State private var baseHoursSpecialDay: Double = 8
    @State private var startWorkOnSunday: Bool = true
    @State private var showingCountryPicker = false
    @State private var selectedCountry = "Israel (ILS)"
    
    init() {
        // Load saved values or use defaults
        let savedBaseHoursWeekday = UserDefaults.standard.double(forKey: "baseHoursWeekday")
        _baseHoursWeekday = State(initialValue: savedBaseHoursWeekday > 0 ? savedBaseHoursWeekday : 8)
        
        let savedBaseHoursSpecialDay = UserDefaults.standard.double(forKey: "baseHoursSpecialDay")
        _baseHoursSpecialDay = State(initialValue: savedBaseHoursSpecialDay > 0 ? savedBaseHoursSpecialDay : 8)
        
        _startWorkOnSunday = State(initialValue: UserDefaults.standard.bool(forKey: "startWorkOnSunday"))
        
        let savedCountry = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Israel (ILS)"
        _selectedCountry = State(initialValue: savedCountry)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Base Hours\n(Weekday)".localized)
                        Spacer()
                        Text("\(Int(baseHoursWeekday))")
                    }
                    
                    HStack {
                        Text("Base Hours\n(Special Day)".localized)
                        Spacer()
                        Text("\(Int(baseHoursSpecialDay))")
                    }
                }
                
                Section {
                    Toggle("Start work on Sunday".localized, isOn: $startWorkOnSunday)
                }
                
                Section(header: Text("Country".localized)) {
                    Button(action: {
                        showingCountryPicker = true
                    }) {
                        HStack {
                            Text("Country".localized)
                            Spacer()
                            Text(selectedCountry)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 13))
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                Button(action: {
                    // Save all settings
                    UserDefaults.standard.set(baseHoursWeekday, forKey: "baseHoursWeekday")
                    UserDefaults.standard.set(baseHoursSpecialDay, forKey: "baseHoursSpecialDay")
                    UserDefaults.standard.set(startWorkOnSunday, forKey: "startWorkOnSunday")
                    UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
                    UserDefaults.standard.synchronize()
                }) {
                    Text("Save Settings".localized)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.purple)
                }
            }
            .navigationTitle("App Settings".localized)
            .sheet(isPresented: $showingCountryPicker) {
                CountryPickerView(selectedCountry: $selectedCountry, isPresented: $showingCountryPicker)
            }
        }
    }
}

struct CountryPickerView: View {
    @Binding var selectedCountry: String
    @Binding var isPresented: Bool
    
    let countries = [
        "Israel (ILS)",
        "USA (USD)"
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(countries, id: \.self) { country in
                    Button(action: {
                        selectedCountry = country
                        isPresented = false
                    }) {
                        HStack {
                            Text(country)
                            Spacer()
                            if selectedCountry == country {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Country".localized)
            .navigationBarItems(trailing: Button("Done".localized) {
                isPresented = false
            })
        }
    }
} 