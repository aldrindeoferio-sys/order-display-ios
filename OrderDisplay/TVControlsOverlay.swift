import SwiftUI

struct TVControlsOverlay: View {
    @ObservedObject var controllerBridge: ControllerBridge
    @State private var showingPairCode = false
    @State private var pairCode = ""

    var body: some View {
        HStack(spacing: 10) {
            Button {
                showingPairCode = true
            } label: {
                Image(systemName: "number")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(.black.opacity(0.55), in: Circle())
            }
            .accessibilityLabel("Pair with TV code")

            if CastConfiguration.isConfigured {
                GoogleCastButton()
                    .frame(width: 36, height: 36)
                    .accessibilityLabel("Cast to TV")
            }
        }
        // Keep native TV controls clear of the web app's top-right menu button.
        .padding(.top, 68)
        .padding(.trailing, 12)
        .sheet(isPresented: $showingPairCode) {
            PairCodeSheet(pairCode: $pairCode, pairAction: pairTV)
                .presentationDetents([.height(235)])
                .presentationDragIndicator(.visible)
        }
    }

    private func pairTV() {
        let digits = String(pairCode.filter(\.isNumber).prefix(4))
        guard digits.count == 4 else { return }
        controllerBridge.pairTV(code: digits)
        pairCode = ""
        showingPairCode = false
    }
}

private struct PairCodeSheet: View {
    @Binding var pairCode: String
    let pairAction: () -> Void

    private var cleanCode: String {
        String(pairCode.filter(\.isNumber).prefix(4))
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("Pair with TV")
                .font(.title2.bold())

            TextField("4-digit code", text: $pairCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .font(.title2.monospacedDigit().bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .frame(height: 54)
                .background(.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                .onChange(of: pairCode) { newValue in
                    pairCode = String(newValue.filter(\.isNumber).prefix(4))
                }

            Button("Pair TV", action: pairAction)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .buttonStyle(.borderedProminent)
                .disabled(cleanCode.count != 4)
        }
        .padding(22)
    }
}
