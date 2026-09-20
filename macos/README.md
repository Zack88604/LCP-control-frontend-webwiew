# LCP Collection Control for macOS

A lightweight native macOS wrapper for the LCP data-collection frontend. It uses the system WebKit engine through `WKWebView` and displays only the **Collection Control** panel from the existing web page.

The macOS and Windows implementations are kept in separate sibling directories in this repository.

## Features

- Loads `http://192.168.50.32:5174/data-collection` by default.
- Shows only the existing Collection Control panel, retaining the original React controls and API calls.
- Always-on-top mode by default; toggle it with `Command-Shift-T`.
- Reload with `Command-R`.
- Opens popup links in the default browser.
- Lets the user change the frontend URL in **Settings → Frontend Address…**.
- Persists the frontend URL in `UserDefaults` and restores the window frame with macOS window autosave.
- Honors `LCP_FRONTEND_URL` as a per-launch environment-variable override.

## Requirements

- macOS 12 or later.
- Xcode 14 or later with Swift 5.7 or later. The build creates an Apple Silicon and Intel universal binary.
- Network access to the configured LCP frontend.

The bundled `Info.plist` permits HTTP content inside `WKWebView`, which is required because the default LCP endpoint is an internal HTTP address.

## Build

On a Mac, run:

```zsh
chmod +x build-macos.sh
./build-macos.sh
```

The script produces:

```text
release/LCP Control.app
release/LCP-Control-macos-universal.zip
```

For local development without an app bundle:

```zsh
swift run
```

## Distribution

Distribute the generated ZIP and instruct users to drag `LCP Control.app` to `Applications` before opening it. The unsigned development build may require the user to approve the app in macOS Privacy & Security settings.

For external production distribution, sign the app with an Apple Developer ID and notarize it before publishing.
