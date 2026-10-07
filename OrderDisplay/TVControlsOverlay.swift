import SwiftUI

struct TVControlsOverlay: View {
    var body: some View {
        if CastConfiguration.isConfigured {
            HStack(spacing: 0) {
                GoogleCastButton()
                    .frame(width: 48, height: 48)
                    .accessibilityLabel("Connect to TV")
                Spacer(minLength: 0)
            }
            .padding(.top, 48)
            .padding(.leading, 566)
            .allowsHitTesting(true)
            .zIndex(10000)
        }
    }
}
