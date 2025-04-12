import SwiftUI

@main
struct ShiftManagerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
} 