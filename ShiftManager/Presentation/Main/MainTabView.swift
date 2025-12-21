import SwiftUI

public struct MainTabView: View {
    public init() {}
    
    public var body: some View {
        TabView {
            DeferredView(preload: true) {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home".localized)
            }
            
            DeferredView {
                ShiftManagerView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Manager".localized)
            }
            
            DeferredView {
                NavigationView {
                    ReportView()
                }
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Reports".localized)
            }
            

        }
        .refreshOnLanguageChange()
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 