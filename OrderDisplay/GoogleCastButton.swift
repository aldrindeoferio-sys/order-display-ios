import SwiftUI
import UIKit
import GoogleCast

struct GoogleCastButton: UIViewRepresentable {
    final class Coordinator: NSObject {
        @objc func openCastDialog(_ sender: UIButton) {
            guard CastConfiguration.isConfigured else { return }
            GCKCastContext.sharedInstance().presentCastDialog()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.055, green: 0.125, blue: 0.18, alpha: 0.98)
        button.tintColor = .white
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        button.setImage(UIImage(systemName: "tv.badge.wifi"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.accessibilityLabel = "Connect to TV"
        button.addTarget(context.coordinator, action: #selector(Coordinator.openCastDialog(_:)), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.isHidden = false
        uiView.alpha = 1
    }
}
