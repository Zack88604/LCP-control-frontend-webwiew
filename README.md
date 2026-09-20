# LCP Collection Control

Native desktop wrappers for the LCP data-collection frontend. Each application displays only the existing **Collection Control** panel and retains the frontend's original controls and API calls.

## Projects

| Directory | Platform | Technology | Build |
| --- | --- | --- | --- |
| [`windows`](windows/README.md) | Windows x64 | .NET Framework 4.8 + Microsoft Edge WebView2 | Run `build.ps1` in Windows PowerShell. |
| [`macos`](macos/README.md) | macOS 12+ | SwiftUI + AppKit + WKWebView | Run `./build-macos.sh` on a Mac. |

Both applications load `http://192.168.50.32:5174/data-collection` by default, provide an address setting with local persistence, restore the window frame, and support an always-on-top mode. `LCP_FRONTEND_URL` can temporarily override the saved frontend address for a launch.

Generated build output is ignored by Git. Use the platform-specific README for prerequisites, build output, and distribution instructions.
