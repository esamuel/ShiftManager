//
//  ContentView.swift
//  ShiftManager
//
//  Created by Samuel Eskenasy on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var shiftManagerViewModel = ShiftManagerViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ShiftManagerView(viewModel: shiftManagerViewModel)
                .tabItem {
                    Label("Shifts", systemImage: "calendar")
                }
            
            Text("Reports")
                .tabItem {
                    Label("Reports", systemImage: "chart.bar")
                }
            
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
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