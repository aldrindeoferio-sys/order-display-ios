import SwiftUI

@main
struct OrderDisplayApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(purchases)
                .task { await purchases.refreshEntitlements() }
        }
    }
}
