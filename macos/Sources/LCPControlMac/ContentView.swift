import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ZStack {
            LCPWebView(model: model)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            WindowConfigurator(model: model)
                .frame(width: 0, height: 0)

            if model.isPageLoading {
                ProgressView("Loading collection control…")
                    .padding(18)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .cornerRadius(10)
                    .shadow(radius: 4)
                    .allowsHitTesting(false)
            }

            if let error = model.pageLoadError {
                PageLoadErrorView(model: model, error: error)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $model.isAddressEditorPresented) {
            FrontendAddressSheet(model: model)
        }
    }
}

private struct PageLoadErrorView: View {
    @ObservedObject var model: AppModel
    let error: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unable to load the collection page")
                .font(.headline)

            Text(model.frontendURL.absoluteString)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(error)
                .font(.caption)
                .foregroundColor(.red)

            HStack {
                Button("Retry") {
                    model.reload()
                }
                Button("Open in Default Browser") {
                    model.openInDefaultBrowser()
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 520, alignment: .leading)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 6)
        .padding(24)
    }
}

private struct FrontendAddressSheet: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var address: String
    @State private var errorMessage: String?

    init(model: AppModel) {
        self.model = model
        _address = State(initialValue: model.savedFrontendAddress)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Frontend Address")
                .font(.headline)

            TextField("http://host:5174/data-collection", text: $address)
                .textFieldStyle(.roundedBorder)

            Text("The address is saved locally and used at the next launch.")
                .font(.caption)
                .foregroundColor(.secondary)

            if model.hasEnvironmentOverride {
                Text("LCP_FRONTEND_URL is set, so it overrides the saved address for this launch.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Button("Save") {
                    do {
                        _ = try model.saveFrontendAddress(address)
                        dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 520)
    }
}
