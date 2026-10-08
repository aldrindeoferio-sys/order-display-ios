import SwiftUI

struct TVControlsOverlay: View {
    let controllerBridge: ControllerBridge

    var body: some View {
        if CastConfiguration.isConfigured {
            // Keep the Google Cast session listener alive for room handoff.
            // The visible Cast button is in the web Display Settings header.
            GoogleCastButton(controllerBridge: controllerBridge)
                .frame(width: 1, height: 1)
                .opacity(0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}
