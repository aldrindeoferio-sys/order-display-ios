import Foundation
import UIKit
import GoogleCast

enum CastConfiguration {
    static var receiverApplicationID: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "OrderDisplayCastReceiverAppID") as? String else {
            return nil
        }
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? nil : clean
    }

    static var isConfigured: Bool {
        receiverApplicationID != nil
    }
}

final class CastAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        guard let receiverID = CastConfiguration.receiverApplicationID else {
            return true
        }

        let criteria = GCKDiscoveryCriteria(applicationID: receiverID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        return true
    }
}
