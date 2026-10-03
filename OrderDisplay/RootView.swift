import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            OrdersView().tabItem { Label("Orders", systemImage: "list.bullet.rectangle") }
            DisplayView().tabItem { Label("Display", systemImage: "tv") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

struct OrdersView: View {
    @State private var orders: [Order] = []
    @State private var number = ""
    @State private var source: Order.Source = .pickup

    var body: some View {
        NavigationStack {
            List {
                Section("New order") {
                    TextField("Order number", text: $number).keyboardType(.numbersAndPunctuation)
                    Picker("Source", selection: $source) {
                        ForEach(Order.Source.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                    Button("Add Order") {
                        let clean = number.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !clean.isEmpty else { return }
                        orders.insert(Order(number: clean, source: source), at: 0)
                        number = ""
                    }.buttonStyle(.borderedProminent)
                }
                Section("Current Orders") {
                    if orders.filter({ $0.status != .collected }).isEmpty {
                        ContentUnavailableView("No current orders", systemImage: "checkmark.circle")
                    }
                    ForEach($orders) { $order in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(order.source.rawValue).font(.caption.bold())
                                Spacer()
                                Text(order.receivedAt, style: .time).font(.caption).foregroundStyle(.secondary)
                            }
                            Text(order.number).font(.title2.bold())
                            HStack {
                                Text(order.status.rawValue).foregroundStyle(.secondary)
                                Spacer()
                                if order.status == .preparing {
                                    Button("Ready") { order.status = .ready }
                                } else if order.status == .ready {
                                    Button("Collected") { order.status = .collected; order.collectedAt = Date() }
                                }
                            }
                        }.padding(.vertical, 4)
                    }
                }
            }.navigationTitle("Order Display")
        }
    }
}

struct DisplayView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            List {
                Section("Customer Display") {
                    Button { if let url = settings.displayURL { openURL(url) } } label: {
                        Label("Open Customer Display", systemImage: "tv")
                    }
                }
                Section("Background") {
                    ForEach(DisplayBackground.allCases) { background in
                        Button {
                            if background.isFree || purchases.isPremium { settings.selectedBackground = background }
                        } label: {
                            HStack {
                                Text(background.rawValue)
                                Spacer()
                                if settings.selectedBackground == background { Image(systemName: "checkmark") }
                                if !background.isFree && !purchases.isPremium { Image(systemName: "lock.fill") }
                            }
                        }
                    }
                }
                if !purchases.isPremium { PremiumCard() }
            }.navigationTitle("Display")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var purchases: PurchaseManager

    var body: some View {
        NavigationStack {
            Form {
                Section("Order Display Server") {
                    TextField("Server address", text: $settings.serverAddress)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                    Text("Example: http://192.168.0.193:3000").font(.caption).foregroundStyle(.secondary)
                }
                Section("Premium") {
                    if purchases.isPremium {
                        Label("Order Display Premium", systemImage: "checkmark.seal.fill")
                    } else {
                        PremiumCard()
                        Button("Restore Purchase") { Task { await purchases.restore() } }
                    }
                }
                Section("Version") { Text("0.1.0") }
            }.navigationTitle("Settings")
        }
    }
}

struct PremiumCard: View {
    @EnvironmentObject var purchases: PurchaseManager
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order Display Premium").font(.headline)
            Text("No ads • All seasonal backgrounds • One-time purchase")
                .font(.subheadline).foregroundStyle(.secondary)
            Button(purchases.product?.displayPrice.map { "Unlock Premium — \($0)" } ?? "Unlock Premium") {
                Task { await purchases.purchasePremium() }
            }.buttonStyle(.borderedProminent)
        }.padding(.vertical, 4)
    }
}
