import SwiftUI

/// A text view that automatically updates when the app language changes
struct LocalizableText: View {
    private let key: String
    @StateObject private var localizationManager = LocalizationManager.shared
    
    init(_ key: String) {
        self.key = key
    }
    
    var body: some View {
        Text(key.localized)
    }
} 