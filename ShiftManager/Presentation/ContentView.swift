//
//  ContentView.swift
//  ShiftManager
//
//  Created by Samuel Eskenasy on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        MainTabView()
            .refreshOnLanguageChange()
            .id(themeManager.refreshID) // Force refresh on theme change
            .withAppTheme() // Apply theme
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