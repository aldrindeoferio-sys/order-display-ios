import SwiftUI
import WebKit

@MainActor
final class ControllerBridge: ObservableObject {
    weak var webView: WKWebView?

    func attach(_ webView: WKWebView) {
        self.webView = webView
    }

    func showMainOrderControl() {
        let script = """
        (() => {
          let style = document.getElementById('order-display-native-main-style');
          if (!style) {
            style = document.createElement('style');
            style.id = 'order-display-native-main-style';
            style.textContent = '#pairPanel{display:none!important}#controller{display:block!important}.info-label,.helper-text,.hint-text,.status-label[data-info-only="true"]{display:none!important}';
            document.head.appendChild(style);
          }
          const pair = document.getElementById('pairPanel');
          const controller = document.getElementById('controller');
          if (pair) pair.classList.add('hidden');
          if (controller) controller.classList.remove('hidden');
        })();
        """
        webView?.evaluateJavaScript(script)
    }

    func currentRoomID(completion: @escaping (String?) -> Void) {
        let script = "localStorage.getItem('hapag-room-id') || ''"
        webView?.evaluateJavaScript(script) { value, _ in
            let room = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            completion((room?.isEmpty == false) ? room : nil)
        }
    }
}
