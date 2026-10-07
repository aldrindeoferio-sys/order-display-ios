import SwiftUI
import UIKit
import GoogleCast

struct GoogleCastButton: UIViewRepresentable {
    let controllerBridge: ControllerBridge

    final class Coordinator: NSObject, GCKSessionManagerListener {
        let controllerBridge: ControllerBridge
        private var roomChannel: GCKGenericChannel?

        init(controllerBridge: ControllerBridge) {
            self.controllerBridge = controllerBridge
            super.init()
            GCKCastContext.sharedInstance().sessionManager.add(self)
        }

        deinit {
            GCKCastContext.sharedInstance().sessionManager.remove(self)
        }

        @objc func openCastDialog(_ sender: UIButton) {
            guard CastConfiguration.isConfigured else { return }
            GCKCastContext.sharedInstance().presentCastDialog()
        }

        func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
            sendRoom(to: sessionManager.currentCastSession)
        }

        func sessionManager(_ sessionManager: GCKSessionManager, didResumeSession session: GCKSession) {
            sendRoom(to: sessionManager.currentCastSession)
        }

        private func sendRoom(to session: GCKCastSession?) {
            guard let session else { return }
            Task { @MainActor in
                controllerBridge.currentRoomID { [weak self, weak session] roomID in
                    guard let self, let session, let roomID else { return }
                    let channel = GCKGenericChannel(namespace: "urn:x-cast:com.deoferioapps.orderdisplay")
                    session.add(channel)
                    self.roomChannel = channel

                    let payload: [String: Any] = [
                        "type": "open-room",
                        "roomId": roomID
                    ]
                    guard let data = try? JSONSerialization.data(withJSONObject: payload),
                          let text = String(data: data, encoding: .utf8) else { return }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        var error: GCKError?
                        _ = channel.sendTextMessage(text, error: &error)
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(controllerBridge: controllerBridge)
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
