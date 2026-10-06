import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let view = BannerView()
        view.adSize = AdSizeBanner
        view.adUnitID = AdConfiguration.bannerUnitID
        view.rootViewController = context.coordinator.rootViewController
        view.load(Request())
        return view
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        let rootViewController = UIViewController()
    }
}

struct FreeAdBanner: View {
    @EnvironmentObject var purchases: PurchaseManager

    var body: some View {
        if !purchases.isPremium {
            AdMobBannerView()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
    }
}
