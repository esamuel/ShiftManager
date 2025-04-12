import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            ShiftManagerView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Manager")
                }
                .tag(1)
            
            ReportView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Reports")
                }
                .tag(2)
            
            AppSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.purple) // This will tint the selected tab with purple color
    }
}

#Preview {
    MainTabView()
} 