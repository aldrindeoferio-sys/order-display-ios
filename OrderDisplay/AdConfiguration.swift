import Foundation

/// AdMob IDs for Order Display.
/// DEBUG builds always use Google's test banner to protect the live account.
enum AdConfiguration {
    static let productionAppID = "ca-app-pub-2593622446351585~9721410448"
    static let productionBannerUnitID = "ca-app-pub-2593622446351585/7255029209"
    static let testBannerUnitID = "ca-app-pub-3940256099942544/2934735716"

    #if DEBUG
    static let bannerUnitID = testBannerUnitID
    #else
    static let bannerUnitID = productionBannerUnitID
    #endif
}
