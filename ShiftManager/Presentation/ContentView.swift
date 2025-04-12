//
//  ContentView.swift
//  ShiftManager
//
//  Created by Samuel Eskenasy on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
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