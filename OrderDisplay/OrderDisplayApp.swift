import SwiftUI
import GoogleMobileAds

@main
struct OrderDisplayApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var purchases = PurchaseManager()
    @StateObject private var server = OrderDisplayServer()
    @StateObject private var consent = ConsentManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(purchases)
                .environmentObject(server)
                .environmentObject(consent)
                .task {
                    await consent.requestConsent()
                    if consent.canRequestAds {
                        _ = await MobileAds.shared.start()
                    }
                    await purchases.refreshEntitlements()
                    await server.checkConnection(serverAddress: settings.serverAddress)
                }
        }
    }
}
