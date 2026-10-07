import SwiftUI

struct TVControlsOverlay: View {
    @ObservedObject var controllerBridge: ControllerBridge
    @State private var showingConnections = false
    @State private var pairCode = ""

    var body: some View {
        if CastConfiguration.isConfigured {
            Button {
                showingConnections = true
            } label: {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(.black.opacity(0.72), in: Circle())
            }
            .accessibilityLabel("Connect TV")
            .padding(.top, 8)
            .padding(.trailing, 10)
            .sheet(isPresented: $showingConnections) {
                TVConnectionSheet(pairCode: $pairCode, pairAction: pairTV)
                    .presentationDetents([.height(330)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func pairTV() {
        let digits = String(pairCode.filter(\.isNumber).prefix(4))
        guard digits.count == 4 else { return }
        controllerBridge.pairTV(code: digits)
        pairCode = ""
        showingConnections = false
    }
}

private struct TVConnectionSheet: View {
    @Binding var pairCode: String
    let pairAction: () -> Void

    private var cleanCode: String {
        String(pairCode.filter(\.isNumber).prefix(4))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Connect TV")
                .font(.title2.bold())

            HStack(spacing: 14) {
                GoogleCastButton()
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Search for TV")
                        .font(.headline)
                    Text("Chromecast or Google TV")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))

            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.secondary.opacity(0.25))
                Text("OR")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.secondary.opacity(0.25))
            }

            HStack(spacing: 10) {
                TextField("4-digit TV code", text: $pairCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .font(.title3.monospacedDigit().bold())
                    .padding(.horizontal, 14)
                    .frame(height: 50)
                    .background(.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                    .onChange(of: pairCode) { newValue in
                        pairCode = String(newValue.filter(\.isNumber).prefix(4))
                    }

                Button("PAIR TV", action: pairAction)
                    .font(.headline)
                    .frame(height: 50)
                    .padding(.horizontal, 12)
                    .buttonStyle(.borderedProminent)
                    .disabled(cleanCode.count != 4)
            }
        }
        .padding(22)
    }
}
