import SwiftUI
import WebKit

struct ControllerWebView: UIViewRepresentable {
    let url: URL
    @Binding var loadFailed: Bool
    @ObservedObject var purchases: PurchaseManager
    @ObservedObject var consent: ConsentManager
    @ObservedObject var controllerBridge: ControllerBridge

    func makeCoordinator() -> Coordinator {
        Coordinator(loadFailed: $loadFailed, purchases: purchases, consent: consent, controllerBridge: controllerBridge)
    }

    func makeUIView(context: Context) -> WKWebView {
        let content = WKUserContentController()
        for name in Coordinator.bridgeNames {
            content.add(context.coordinator, name: name)
        }

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = content
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.keyboardDismissMode = .interactive
        webView.allowsBackForwardNavigationGestures = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 8/255, green: 19/255, blue: 29/255, alpha: 1)

        context.coordinator.webView = webView
        controllerBridge.attach(webView)
        context.coordinator.loadedURL = url
        webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.loadedURL != url {
            context.coordinator.loadedURL = url
            webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
        }
        context.coordinator.pushMonetizationState()
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        for name in Coordinator.bridgeNames {
            uiView.configuration.userContentController.removeScriptMessageHandler(forName: name)
        }
        uiView.stopLoading()
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        static let bridgeNames = [
            "monetizationReady",
            "purchaseRemoveAds",
            "restorePurchases",
            "showPrivacyOptions",
            "showInterstitial"
        ]

        @Binding private var loadFailed: Bool
        let purchases: PurchaseManager
        let consent: ConsentManager
        let controllerBridge: ControllerBridge
        weak var webView: WKWebView?
        var loadedURL: URL?

        init(loadFailed: Binding<Bool>, purchases: PurchaseManager, consent: ConsentManager, controllerBridge: ControllerBridge) {
            _loadFailed = loadFailed
            self.purchases = purchases
            self.consent = consent
            self.controllerBridge = controllerBridge
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loadFailed = false
            pushMonetizationState()
            controllerBridge.attach(webView)
            controllerBridge.showMainOrderControl()
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            loadFailed = true
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            loadFailed = true
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil, let target = navigationAction.request.url {
                UIApplication.shared.open(target)
            }
            return nil
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "monetizationReady":
                pushMonetizationState()

            case "purchaseRemoveAds":
                Task { @MainActor in
                    await purchases.purchasePremium()
                    pushMonetizationState()
                    sendPurchaseResult()
                }

            case "restorePurchases":
                Task { @MainActor in
                    await purchases.restore()
                    pushMonetizationState()
                    sendPurchaseResult()
                }

            case "showPrivacyOptions":
                Task { @MainActor in
                    await consent.presentPrivacyOptions()
                    pushMonetizationState()
                }

            case "showInterstitial":
                // TestFlight build 0.1.6 deliberately does not serve live ads.
                // Keep the web controller flow moving after the natural break.
                webView?.evaluateJavaScript("window.DeoferioMonetization?.adClosed?.();")

            default:
                break
            }
        }

        func pushMonetizationState() {
            guard let webView else { return }
            let state: [String: Any] = [
                "isNativeIOS": true,
                "adFree": purchases.isPremium,
                "canRequestAds": false,
                "removeAdsPrice": purchases.product?.displayPrice ?? "",
                "privacyOptionsRequired": consent.privacyOptionsRequired
            ]
            guard let data = try? JSONSerialization.data(withJSONObject: state),
                  let json = String(data: data, encoding: .utf8) else { return }
            webView.evaluateJavaScript("window.DeoferioMonetization?.setState(\(json));")
        }

        private func sendPurchaseResult() {
            guard let webView else { return }
            let result: [String: Any] = [
                "adFree": purchases.isPremium,
                "message": purchases.isPremium ? "Ads removed" : (purchases.errorMessage ?? "Purchase not completed")
            ]
            guard let data = try? JSONSerialization.data(withJSONObject: result),
                  let json = String(data: data, encoding: .utf8) else { return }
            webView.evaluateJavaScript("window.DeoferioMonetization?.purchaseResult(\(json));")
        }
    }
}
