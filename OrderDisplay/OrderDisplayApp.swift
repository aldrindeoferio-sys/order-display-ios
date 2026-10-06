import SwiftUI
import GoogleMobileAds

@main
struct OrderDisplayApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var purchases = PurchaseManager()
    @StateObject private var server = OrderDisplayServer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(purchases)
                .environmentObject(server)
                .task {
                    MobileAds.shared.start(completionHandler: nil)
                    await purchases.refreshEntitlements()
                    await server.checkConnection(serverAddress: settings.serverAddress)
                }
        }
    }
}
