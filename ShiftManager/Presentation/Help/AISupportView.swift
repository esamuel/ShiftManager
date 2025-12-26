import SwiftUI

struct AISupportView: View {
    @Environment(\.dismiss) var dismiss
    
    // For local testing, we might need to host the built React app or point to a remote URL.
    // Assuming we might host it on the website eventually.
    // For now, let's use a placeholder URL or a local file path if possible.
    // Since we've built it, we could try to bundle it, but static assets in iOS are tricky with relative paths.
    // I'll point it to the website URL once it's deployed, but for now I'll use a local file path or a clear message.
    
    var supportURL: URL {
        // Look for index.html anywhere in the bundle (root or subfolders)
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            return url
        }
        // Fallback to website if local bundle not found
        return URL(string: "https://shiftsmanager.com/ai-support/index.html")!
    }

    var body: some View {
        NavigationView {
            VStack {
                WebView(url: supportURL, isLocal: supportURL.isFileURL)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("AI Support Agent".localized)
            .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close".localized) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    AISupportView()
}
