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
            
            ReportView()
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