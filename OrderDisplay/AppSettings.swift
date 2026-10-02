import Foundation

@MainActor
final class AppSettings: ObservableObject {
    @Published var serverAddress: String {
        didSet { UserDefaults.standard.set(serverAddress, forKey: "serverAddress") }
    }
    @Published var selectedBackground: DisplayBackground = .everyday

    init() {
        serverAddress = UserDefaults.standard.string(forKey: "serverAddress") ?? "http://192.168.0.193:3000"
    }

    var displayURL: URL? {
        URL(string: serverAddress.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/display.html")
    }
}
