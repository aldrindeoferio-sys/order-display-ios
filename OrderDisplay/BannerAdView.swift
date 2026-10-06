import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let view = BannerView(adSize: AdSizeBanner)
        view.adUnitID = AdConfiguration.bannerUnitID
        view.load(Request())
        return view
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
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
