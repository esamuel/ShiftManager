import SwiftUI

public struct MainTabView: View {
    public init() {}
    
    public var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Upcoming Shifts")
                }
            
            ShiftManagerView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Manager")
                }
            
            ReportView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Reports")
                }
            
            AppSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 