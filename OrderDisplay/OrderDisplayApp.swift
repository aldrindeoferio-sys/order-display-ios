import SwiftUI
import GoogleMobileAds

@main
struct OrderDisplayApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var purchases = PurchaseManager()
    @StateObject private var server = OrderDisplayServer()

    init() {
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(purchases)
                .environmentObject(server)
                .task {
                    await purchases.refreshEntitlements()
                    await server.checkConnection(serverAddress: settings.serverAddress)
                }
        }
    }
}
