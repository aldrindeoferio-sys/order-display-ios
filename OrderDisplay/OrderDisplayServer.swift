import Foundation

@MainActor
final class OrderDisplayServer: ObservableObject {
    enum ConnectionState: Equatable {
        case idle, checking, connected, disconnected(String)
    }

    @Published private(set) var state: ConnectionState = .idle

    private func baseURL(from address: String) throws -> URL {
        let clean = address.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: clean), url.scheme != nil, url.host != nil else {
            throw URLError(.badURL)
        }
        return url
    }

    func checkConnection(serverAddress: String) async {
        state = .checking
        do {
            let base = try baseURL(from: serverAddress)
            let url = base.appendingPathComponent("health")
            var request = URLRequest(url: url)
            request.timeoutInterval = 5
            request.cachePolicy = .reloadIgnoringLocalCacheData
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            state = .connected
        } catch {
            state = .disconnected(error.localizedDescription)
        }
    }

    // The current Windows app's exact order mutation routes will be wired here
    // after its server.js API contract is imported. Do not guess production routes.
}
