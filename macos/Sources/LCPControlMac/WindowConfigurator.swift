import AppKit
import SwiftUI

@MainActor
struct WindowConfigurator: NSViewRepresentable {
    @ObservedObject var model: AppModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.configure(windowFor: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.model = model
        context.coordinator.configure(windowFor: nsView)
    }

    @MainActor
    final class Coordinator {
        var model: AppModel

        private weak var window: NSWindow?
        private var notificationObservers: [NSObjectProtocol] = []

        init(model: AppModel) {
            self.model = model
        }

        deinit {
            notificationObservers.forEach(NotificationCenter.default.removeObserver)
        }

        func configure(windowFor view: NSView) {
            DispatchQueue.main.async { [weak self, weak view] in
                guard let self, let window = view?.window else { return }
                self.attach(to: window)
            }
        }

        private func attach(to window: NSWindow) {
            guard self.window !== window else { return }

            notificationObservers.forEach(NotificationCenter.default.removeObserver)
            notificationObservers.removeAll()
            self.window = window
            model.attach(window: window)

            let notificationCenter = NotificationCenter.default
            for name in [NSWindow.didMoveNotification, NSWindow.didResizeNotification] {
                notificationObservers.append(
                    notificationCenter.addObserver(forName: name, object: window, queue: .main) { notification in
                        guard let window = notification.object as? NSWindow,
                              !window.isMiniaturized,
                              !window.isZoomed else {
                            return
                        }
                        AppModel.saveWindowFrame(window.frame)
                    }
                )
            }
            notificationObservers.append(
                notificationCenter.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { notification in
                    guard let window = notification.object as? NSWindow,
                          !window.isMiniaturized,
                          !window.isZoomed else {
                        return
                    }
                    AppModel.saveWindowFrame(window.frame)
                }
            )
        }
    }
}
