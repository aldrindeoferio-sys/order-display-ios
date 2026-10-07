import SwiftUI

struct RootView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var consent: ConsentManager

    @State private var loadFailed = false
    @StateObject private var controllerBridge = ControllerBridge()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let url = settings.controllerURL, !loadFailed {
                    ControllerWebView(
                        url: url,
                        loadFailed: $loadFailed,
                        purchases: purchases,
                        consent: consent,
                        controllerBridge: controllerBridge
                    )
                    .ignoresSafeArea()
                } else {
                    ServerSetupView(loadFailed: $loadFailed)
                }
            }

            TVControlsOverlay()
        }
    }
}

private struct ServerSetupView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var server: OrderDisplayServer
    @Binding var loadFailed: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Server address", text: $settings.serverAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)

                    Text("Example: http://192.168.0.193:3000")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Order Display Server")
                } footer: {
                    Text("Your iPhone and Order Display server must be on the same local network.")
                }

                Section {
                    Button("Connect to Order Display") {
                        Task {
                            await server.checkConnection(serverAddress: settings.serverAddress)
                            if server.state == .connected {
                                loadFailed = false
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    HStack {
                        Image(systemName: server.state == .connected ? "checkmark.circle.fill" : "wifi.exclamationmark")
                            .foregroundStyle(server.state == .connected ? .green : .secondary)
                        Text(statusText)
                    }
                }
            }
            .navigationTitle("Order Display")
        }
    }

    private var statusText: String {
        switch server.state {
        case .idle: return "Enter the server address"
        case .checking: return "Checking server…"
        case .connected: return "Server connected"
        case .disconnected: return "Server not reachable"
        }
    }
}
