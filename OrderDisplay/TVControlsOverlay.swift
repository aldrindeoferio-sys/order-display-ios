import SwiftUI

struct TVControlsOverlay: View {
    var body: some View {
        if CastConfiguration.isConfigured {
            GoogleCastButton()
                .frame(width: 48, height: 48)
                .accessibilityLabel("Connect to TV")
                .padding(.top, 48)
                .padding(.trailing, 92)
                .allowsHitTesting(true)
                .zIndex(10000)
        }
    }
}
