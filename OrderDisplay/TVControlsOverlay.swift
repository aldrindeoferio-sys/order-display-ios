import SwiftUI

struct TVControlsOverlay: View {
    var body: some View {
        if CastConfiguration.isConfigured {
            GoogleCastButton()
                .frame(width: 48, height: 48)
                .accessibilityLabel("Connect to TV")
                // Align with the hamburger button in the web header.
                .padding(.top, 8)
                .padding(.trailing, 92)
                .allowsHitTesting(true)
                .zIndex(10000)
        }
    }
}
