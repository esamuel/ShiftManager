import SwiftUI

public struct AppSettingsView: View {
    @StateObject private var viewModel = AppSettingsViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Username", text: $viewModel.username)
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $viewModel.theme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }
                
                Section(header: Text("Language")) {
                    Picker("Language", selection: $viewModel.language) {
                        Text("English").tag("en")
                        Text("Hebrew").tag("he")
                    }
                }
                
                Section(header: Text("Shift Settings")) {
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gearshape.2")
                            Text("Shift Settings")
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    AppSettingsView()
} 