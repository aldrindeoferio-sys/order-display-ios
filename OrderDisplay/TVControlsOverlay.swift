import SwiftUI
import GoogleCast

// Invisible lifecycle owner for Cast session handoff. No floating native button.
struct TVControlsOverlay: View {
    let controllerBridge: ControllerBridge

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                CastRoomHandoff.shared.configure(bridge: controllerBridge)
            }
    }
}

@MainActor
final class CastRoomHandoff: NSObject, GCKSessionManagerListener {
    static let shared = CastRoomHandoff()
    private var controllerBridge: ControllerBridge?
    private var roomChannel: GCKGenericChannel?
    private var listening = false

    func configure(bridge: ControllerBridge) {
        controllerBridge = bridge
        guard CastConfiguration.isConfigured, !listening else { return }
        GCKCastContext.sharedInstance().sessionManager.add(self)
        listening = true
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        sendRoom(to: sessionManager.currentCastSession)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeSession session: GCKSession) {
        sendRoom(to: sessionManager.currentCastSession)
    }

    private func sendRoom(to session: GCKCastSession?) {
        guard let session, let controllerBridge else { return }
        controllerBridge.currentRoomID { [weak self, weak session] roomID in
            guard let self, let session, let roomID else { return }
            let channel = GCKGenericChannel(namespace: "urn:x-cast:com.deoferioapps.orderdisplay")
            session.add(channel)
            self.roomChannel = channel
            let payload: [String: Any] = ["type": "open-room", "roomId": roomID]
            guard let data = try? JSONSerialization.data(withJSONObject: payload),
                  let text = String(data: data, encoding: .utf8) else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                var error: GCKError?
                _ = channel.sendTextMessage(text, error: &error)
            }
        }
    }
}
