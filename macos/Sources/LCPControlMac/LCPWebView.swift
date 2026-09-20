import AppKit
import SwiftUI
import WebKit

struct LCPWebView: NSViewRepresentable {
    @ObservedObject var model: AppModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeNSView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.addUserScript(
            WKUserScript(
                source: ControlOnlyScript.source,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        model.attach(webView: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.model = model
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        weak var model: AppModel?

        init(model: AppModel) {
            self.model = model
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            model?.navigationDidStart()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            model?.navigationDidFinish()
            webView.evaluateJavaScript(ControlOnlyScript.source)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            reportNavigationFailure(error)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            reportNavigationFailure(error)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            model?.webContentProcessDidTerminate()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
            }
            return nil
        }

        private func reportNavigationFailure(_ error: Error) {
            model?.navigationDidFail(error.localizedDescription)
        }
    }
}
