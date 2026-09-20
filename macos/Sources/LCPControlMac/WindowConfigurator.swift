import AppKit
import SwiftUI

struct WindowConfigurator: NSViewRepresentable {
    @ObservedObject var model: AppModel

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        configure(windowFor: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        configure(windowFor: nsView)
    }

    private func configure(windowFor view: NSView) {
        DispatchQueue.main.async {
            if let window = view.window {
                model.attach(window: window)
            }
        }
    }
}
