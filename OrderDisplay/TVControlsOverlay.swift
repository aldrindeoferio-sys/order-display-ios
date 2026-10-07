import SwiftUI

struct TVControlsOverlay: View {
    var body: some View {
        if CastConfiguration.isConfigured {
            GoogleCastButton()
                .frame(width: 40, height: 40)
                .accessibilityLabel("Connect to TV")
                // Keep the native Cast control clear of the web app's top-right menu.
                .padding(.top, 68)
                .padding(.trailing, 12)
        }
    }
}
