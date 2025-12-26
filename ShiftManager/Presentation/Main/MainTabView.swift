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
            .tag(0)
            
            DeferredView(preload: false) {
                NavigationView {
                    ShiftManagerView()
                }
            }
            .tabItem {
                Image(systemName: "briefcase.fill")
                Text("Manager".localized)
            }
            .tag(1)
            
            DeferredView {
                NavigationView {
                    ReportView()
                }
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Reports".localized)
            }
            .tag(2)
        }
        .refreshOnLanguageChange()
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 