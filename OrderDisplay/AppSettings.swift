import Foundation

@MainActor
final class AppSettings: ObservableObject {
    @Published var serverAddress: String {
        didSet { UserDefaults.standard.set(serverAddress, forKey: "serverAddress") }
    }

    init() {
        serverAddress = UserDefaults.standard.string(forKey: "serverAddress") ?? "http://192.168.0.193:3000"
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
