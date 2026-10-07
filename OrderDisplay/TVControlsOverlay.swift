import SwiftUI

struct TVControlsOverlay: View {
    var body: some View {
        if CastConfiguration.isConfigured {
            GoogleCastButton()
                .frame(width: 40, height: 40)
                .accessibilityLabel("Connect to TV")
                // Place Cast directly beside the web app's top-right menu button.
                .padding(.top, 8)
                .padding(.trailing, 58)
        }
    }
}
