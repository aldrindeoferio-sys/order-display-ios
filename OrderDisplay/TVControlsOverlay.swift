import SwiftUI

struct TVControlsOverlay: View {
    var body: some View {
        if CastConfiguration.isConfigured {
            GoogleCastButton()
                .frame(width: 36, height: 36)
                .accessibilityLabel("Cast to TV")
                .padding(.top, 8)
                .padding(.trailing, 10)
        }
    }
}
