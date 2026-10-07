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
            style.textContent = '#pairPanel{display:none!important}#controller{display:block!important}';
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

    func pairTV(code: String) {
        let digits = String(code.filter(\.isNumber).prefix(4))
        guard digits.count == 4,
              let data = try? JSONSerialization.data(withJSONObject: digits),
              let json = String(data: data, encoding: .utf8) else { return }

        let script = """
        (() => {
          const input = document.getElementById('pairCode');
          const button = document.getElementById('pairBtn');
          if (!input || !button) return;
          input.value = \(json);
          input.dispatchEvent(new Event('input', { bubbles: true }));
          button.click();
        })();
        """
        webView?.evaluateJavaScript(script)
    }
}
