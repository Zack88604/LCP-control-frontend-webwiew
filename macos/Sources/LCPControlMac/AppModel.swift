import AppKit
import Foundation
import WebKit

enum FrontendAddressError: LocalizedError {
    case invalid

    var errorDescription: String? {
        "The frontend address must be a valid http or https URL."
    }
}

@MainActor
final class AppModel: ObservableObject {
    static let defaultFrontendAddress = "http://192.168.50.32:5174/data-collection"

    private static let savedFrontendAddressKey = "frontendAddress"
    private static let windowFrameAutosaveName = "LCPControlWindow"

    @Published private(set) var frontendURL: URL
    @Published var isAddressEditorPresented = false
    @Published private(set) var isAlwaysOnTop = true
    @Published private(set) var isPageLoading = true
    @Published private(set) var pageLoadError: String?

    private let environmentOverride: URL?
    private weak var webView: WKWebView?
    private weak var window: NSWindow?

    init() {
        let environmentValue = ProcessInfo.processInfo.environment["LCP_FRONTEND_URL"]
        environmentOverride = environmentValue.flatMap { try? Self.normalizedURL(from: $0) }

        if let environmentOverride {
            frontendURL = environmentOverride
        } else if let savedValue = UserDefaults.standard.string(forKey: Self.savedFrontendAddressKey),
                  let savedURL = try? Self.normalizedURL(from: savedValue) {
            frontendURL = savedURL
        } else {
            frontendURL = try! Self.normalizedURL(from: Self.defaultFrontendAddress)
        }
    }

    var hasEnvironmentOverride: Bool {
        environmentOverride != nil
    }

    var savedFrontendAddress: String {
        UserDefaults.standard.string(forKey: Self.savedFrontendAddressKey) ?? Self.defaultFrontendAddress
    }

    func attach(webView: WKWebView) {
        self.webView = webView
        loadCurrentPage()
    }

    func attach(window: NSWindow) {
        guard self.window !== window else { return }
        self.window = window

        window.title = windowTitle
        window.minSize = .zero
        window.isReleasedWhenClosed = false

        let restoredFrame = window.setFrameUsingName(Self.windowFrameAutosaveName)
        if !restoredFrame || !Self.isUsablyVisible(window.frame) {
            window.setContentSize(NSSize(width: 900, height: 900))
            window.center()
        }
        window.setFrameAutosaveName(Self.windowFrameAutosaveName)
        applyAlwaysOnTop()
    }

    func reload() {
        isPageLoading = true
        pageLoadError = nil
        webView?.reloadFromOrigin()
    }

    func navigationDidStart() {
        isPageLoading = true
        pageLoadError = nil
    }

    func navigationDidFinish() {
        isPageLoading = false
    }

    func navigationDidFail(_ message: String) {
        isPageLoading = false
        if pageLoadError == nil {
            pageLoadError = message
        }
    }

    func webContentProcessDidTerminate() {
        isPageLoading = false
        pageLoadError = "The embedded web content process stopped unexpectedly. Retry to start it again."
    }

    func openInDefaultBrowser() {
        NSWorkspace.shared.open(frontendURL)
    }

    func toggleAlwaysOnTop() {
        isAlwaysOnTop.toggle()
        applyAlwaysOnTop()
    }

    @discardableResult
    func saveFrontendAddress(_ rawValue: String) throws -> Bool {
        let url = try Self.normalizedURL(from: rawValue)
        UserDefaults.standard.set(url.absoluteString, forKey: Self.savedFrontendAddressKey)

        guard environmentOverride == nil else {
            return false
        }

        frontendURL = url
        loadCurrentPage()
        return true
    }

    private func loadCurrentPage() {
        isPageLoading = true
        pageLoadError = nil
        webView?.load(URLRequest(url: frontendURL))
    }

    private func applyAlwaysOnTop() {
        window?.level = isAlwaysOnTop ? .floating : .normal
        window?.title = windowTitle
    }

    private var windowTitle: String {
        isAlwaysOnTop ? "LCP Collection Control (Always on Top)" : "LCP Collection Control"
    }

    /// Window autosave data may outlive a monitor change. Do not restore a
    /// frame that is almost entirely outside every connected display.
    private static func isUsablyVisible(_ frame: NSRect) -> Bool {
        let visibleArea = NSScreen.screens.reduce(CGFloat.zero) { result, screen in
            let intersection = frame.intersection(screen.visibleFrame)
            guard !intersection.isNull else { return result }
            return result + intersection.width * intersection.height
        }
        let frameArea = frame.width * frame.height
        return frameArea > 0 && visibleArea / frameArea >= 0.35
    }

    static func normalizedURL(from rawValue: String) throws -> URL {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: value),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              components.host != nil else {
            throw FrontendAddressError.invalid
        }

        if components.path.isEmpty || components.path == "/" {
            components.path = "/data-collection"
        }
        guard let url = components.url else {
            throw FrontendAddressError.invalid
        }
        return url
    }
}
