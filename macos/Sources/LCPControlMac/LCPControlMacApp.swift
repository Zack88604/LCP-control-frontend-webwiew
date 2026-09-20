import SwiftUI

@main
struct LCPControlMacApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Frontend Address…") {
                    model.isAddressEditorPresented = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            CommandMenu("Collection") {
                Button("Reload Collection Control") {
                    model.reload()
                }
                .keyboardShortcut("r", modifiers: .command)

                Button("Open in Default Browser") {
                    model.openInDefaultBrowser()
                }
            }

            CommandMenu("Window Control") {
                Button(model.isAlwaysOnTop ? "Disable Always on Top" : "Enable Always on Top") {
                    model.toggleAlwaysOnTop()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }
}
