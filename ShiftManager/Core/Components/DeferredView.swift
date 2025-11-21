import SwiftUI

/// A lightweight wrapper that defers building heavy SwiftUI views until
/// they first appear on screen. This prevents expensive initialization work
/// (Core Data stacks, complex view models, etc.) from running during app launch.
struct DeferredView<Content: View>: View {
    @State private var isReady: Bool
    private let build: () -> Content
    
    init(preload: Bool = false, @ViewBuilder _ build: @escaping () -> Content) {
        _isReady = State(initialValue: preload)
        self.build = build
    }
    
    var body: some View {
        Group {
            if isReady {
                build()
            } else {
                Color.clear
                    .onAppear {
                        isReady = true
                    }
            }
        }
    }
}

