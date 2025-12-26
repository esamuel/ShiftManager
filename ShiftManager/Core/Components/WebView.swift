import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let isLocal: Bool
    
    init(url: URL, isLocal: Bool = false) {
        self.url = url
        self.isLocal = isLocal
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if isLocal {
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
