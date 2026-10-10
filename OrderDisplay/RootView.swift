import SwiftUI

struct RootView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var consent: ConsentManager

    @State private var loadFailed = false
    @State private var showPurchases = false
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

            TVControlsOverlay(controllerBridge: controllerBridge)

            // Native fallback: independent of web JavaScript purchase button.
            if !purchases.isPremium {
                Button {
                    showPurchases = true
                } label: {
                    Label("Remove Ads", systemImage: "nosign")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 54)
                .padding(.trailing, 12)
                .accessibilityIdentifier("nativeRemoveAdsButton")
            }
        }
        .sheet(isPresented: $showPurchases) {
            NativePurchaseSheet()
                .environmentObject(purchases)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !purchases.isPremium && consent.canRequestAds {
                FreeAdBanner()
                    .background(.regularMaterial)
                    .accessibilityLabel("Test advertisement")
            }
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

private struct NativePurchaseSheet: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var busy = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Ad-Free Upgrade") {
                    if purchases.isPremium {
                        Label("Ads removed on this Apple account", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } else {
                        Text("Remove banner and full-screen advertisements from this iOS app.")
                        Text("Price: \(purchases.product?.displayPrice ?? "Checking App Store…")")
                            .foregroundStyle(.secondary)
                        Button("Purchase Remove Ads") {
                            Task {
                                busy = true
                                await purchases.purchasePremium()
                                busy = false
                            }
                        }
                        .disabled(busy || purchases.product == nil)
                        .accessibilityIdentifier("nativePurchaseButton")
                    }
                    Button("Restore Purchases") {
                        Task {
                            busy = true
                            await purchases.restore()
                            busy = false
                        }
                    }
                    .disabled(busy)
                }
                if let error = purchases.errorMessage, !error.isEmpty {
                    Section("Purchase status") {
                        Text(error).foregroundStyle(.red)
                    }
                }
                if purchases.product == nil && !purchases.isPremium {
                    Section {
                        Text("If the product does not load, verify that the non-consumable in-app purchase exists in App Store Connect with product ID com.deoferioapps.orderdisplay.removeads and that agreements and sandbox testing are configured.")
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Remove Ads")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                if purchases.product == nil {
                    await purchases.loadProduct()
                }
            }
        }
    }
}
