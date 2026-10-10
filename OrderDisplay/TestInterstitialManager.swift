import UIKit
import GoogleMobileAds

/// TestFlight-only interstitial controller. No live advertising units.
@MainActor
final class TestInterstitialManager: NSObject, FullScreenContentDelegate {
    private let minimumInterval: TimeInterval = 600
    private let startedAt = Date()
    private var lastShownAt: Date?
    private var ad: InterstitialAd?
    private var loading = false
    private var presenting = false
    private var completion: (() -> Void)?

    func preloadIfAllowed(_ allowed: Bool) {
        guard allowed, !loading, ad == nil else { return }
        loading = true
        Task {
            defer { loading = false }
            do {
                let loaded = try await InterstitialAd.load(
                    with: "ca-app-pub-3940256099942544/4411468910",
                    request: Request()
                )
                loaded.fullScreenContentDelegate = self
                ad = loaded
            } catch {
                print("[OrderDisplay Ads] Test interstitial load failed: \(error)")
            }
        }
    }

    func showIfEligible(allowed: Bool, completion: @escaping () -> Void) {
        guard allowed,
              !presenting,
              Date().timeIntervalSince(startedAt) >= minimumInterval,
              lastShownAt.map({ Date().timeIntervalSince($0) >= minimumInterval }) ?? true,
              let ready = ad,
              let root = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })?
                .windows.first(where: { $0.isKeyWindow })?.rootViewController
        else {
            completion()
            preloadIfAllowed(allowed)
            return
        }
        presenting = true
        self.completion = completion
        ad = nil
        lastShownAt = Date()
        ready.present(from: root)
    }

    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        finish()
        preloadIfAllowed(true)
    }

    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[OrderDisplay Ads] Test interstitial presentation failed: \(error)")
        finish()
    }

    private func finish() {
        presenting = false
        let callback = completion
        completion = nil
        callback?()
    }
}
