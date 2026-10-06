import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let view = BannerView(adSize: AdSizeBanner)
        view.adUnitID = AdConfiguration.bannerUnitID
        view.rootViewController = topViewController()
        view.load(Request())
        return view
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        if uiView.rootViewController == nil {
            uiView.rootViewController = topViewController()
        }
    }

    private func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        return root
    }
}

struct FreeAdBanner: View {
    @EnvironmentObject var purchases: PurchaseManager
    @EnvironmentObject var consent: ConsentManager

    var body: some View {
        if !purchases.isPremium && consent.canRequestAds {
            AdMobBannerView()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
    }
}
