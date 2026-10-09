import SwiftUI
import WebKit

/// Demo integration page is isolated from the production order controller bridge.
struct IntegrationHubView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            IntegrationHubWebView(url: URL(string: AppSettings.productionServerAddress + "/integrations/")!)
                .navigationTitle("Integrations")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

private struct IntegrationHubWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
