import SwiftUI

struct TVControlsOverlay: View {
    let controllerBridge: ControllerBridge

    var body: some View {
        if CastConfiguration.isConfigured {
            GoogleCastButton(controllerBridge: controllerBridge)
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
