import SwiftUI

struct TVControlsOverlay: View {
    var body: some View {
        if CastConfiguration.isConfigured {
            GoogleCastButton()
                .frame(width: 44, height: 44)
                .accessibilityLabel("Connect to TV")
                // RootView respects the iPhone safe area. Align this control
                // with the web header and leave the hamburger unobstructed.
                .padding(.top, 48)
                .padding(.trailing, 96)
                .zIndex(1000)
        }
    }
}
