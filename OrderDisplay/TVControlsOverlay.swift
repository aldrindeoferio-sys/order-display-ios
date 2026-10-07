import SwiftUI
import UIKit

struct TVControlsOverlay: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var showingTVSetup = false

    var body: some View {
        HStack(spacing: 10) {
            if CastConfiguration.isConfigured {
                GoogleCastButton()
                    .frame(width: 30, height: 30)
                    .accessibilityLabel("Cast to TV")
            }

            Button {
                showingTVSetup = true
            } label: {
                Image(systemName: "tv")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(.black.opacity(0.72), in: Circle())
            }
            .accessibilityLabel("Smart TV setup")
        }
        .padding(.top, 8)
        .padding(.trailing, 10)
        .sheet(isPresented: $showingTVSetup) {
            TVSetupView()
                .environmentObject(settings)
        }
    }
}

private struct TVSetupView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Smart TV") {
                    Text("Open this address in the TV's web browser:")
                    Text(settings.displayURL?.absoluteString ?? "https://orderdisplay.workforcemanager.no/display.html")
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)

                    Button("Copy TV Address") {
                        UIPasteboard.general.string = settings.displayURL?.absoluteString
                    }

                    if let url = settings.displayURL {
                        ShareLink(item: url) {
                            Label("Share TV Address", systemImage: "square.and.arrow.up")
                        }
                    }
                }

                Section("Chromecast / Google TV") {
                    if CastConfiguration.isConfigured {
                        HStack {
                            GoogleCastButton()
                                .frame(width: 32, height: 32)
                            Text("Tap the Cast button and choose your Chromecast or Google Cast compatible TV.")
                        }
                    } else {
                        Text("Chromecast support is installed. The Google Cast Receiver App ID must be added before the Cast button can be enabled.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("How the TV connects") {
                    Text("The TV loads the customer display from the hosted Order Display server. Pair it with the controller using the 4-digit code shown on the TV.")
                }
            }
            .navigationTitle("Connect a TV")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
