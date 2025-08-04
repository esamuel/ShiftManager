import SwiftUI

public struct MainTabView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home".localized)
                }
            
            ShiftManagerView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Manager".localized)
                }
            
            NavigationView {
                ReportView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Reports".localized)
            }
            NavigationView {
                GeneralSettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.2")
                Text("General".localized)
            }
        }
        .refreshOnLanguageChange()
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 