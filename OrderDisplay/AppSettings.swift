import Foundation

@MainActor
final class AppSettings: ObservableObject {
    static let productionServerAddress = "https://orderdisplay.workforcemanager.no"
    private static let legacyDefaultServerAddress = "http://192.168.0.193:3000"

    @Published var serverAddress: String {
        didSet { UserDefaults.standard.set(serverAddress, forKey: "serverAddress") }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "serverAddress")?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Migrate the original TestFlight prototype from the LAN-only default
        // to the hosted Order Display server. Preserve any custom address the
        // user deliberately entered.
        if saved == nil || saved?.isEmpty == true || saved == Self.legacyDefaultServerAddress {
            serverAddress = Self.productionServerAddress
            UserDefaults.standard.set(serverAddress, forKey: "serverAddress")
        } else {
            serverAddress = saved!
        }
    }

    var controllerURL: URL? {
        let clean = serverAddress.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: clean + "/")
    }

    var displayURL: URL? {
        let clean = serverAddress.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: clean + "/display.html")
    }
}
