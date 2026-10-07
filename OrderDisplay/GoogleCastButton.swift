import SwiftUI
import GoogleCast

struct GoogleCastButton: UIViewRepresentable {
    func makeUIView(context: Context) -> GCKUICastButton {
        let button = GCKUICastButton(frame: .zero)
        button.tintColor = .white
        return button
    }

    func updateUIView(_ uiView: GCKUICastButton, context: Context) {}
}
