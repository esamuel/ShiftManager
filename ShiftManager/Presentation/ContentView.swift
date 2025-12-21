//
//  ContentView.swift
//  ShiftManager
//
//  Created by Samuel Eskenasy on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    // Use EnvironmentObject instead of StateObject to avoid duplicate initialization
    // These objects are already created in ShiftManagerApp
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        // Use LazyView to defer creation of MainTabView until needed
        LazyView {
            MainTabView()
                .refreshOnLanguageChange()
                .id(themeManager.refreshID) // Force refresh on theme change
                .withAppTheme() // Apply theme
        }
    }
}

// LazyView wrapper to defer view creation
struct LazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

struct ContentViewPreviewContainer: View {
    var body: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#Preview {
    ContentViewPreviewContainer()
} 