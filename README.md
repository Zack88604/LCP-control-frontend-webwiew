# LCP Collection Control (Lightweight WebView2 Edition)

A lightweight native Windows wrapper for the LCP data-collection UI. It shows only the **Collection Control** panel from the existing web frontend while preserving its original controls and behavior.

The application supports always-on-top mode, reload, opening the page in the default browser, `Ctrl+Shift+T` to toggle always-on-top mode, a configurable frontend address, and saved window placement.

Unlike the previous Electron version, this application does not bundle Chromium. It uses the shared Microsoft Edge WebView2 Runtime, keeping the distributable package small.

For Chinese documentation, see [README.zh-CN.md](README.zh-CN.md).

## Frontend address

On first launch, the application opens:

```text
http://192.168.50.32:5174/data-collection
```

Select **Settings → Frontend Address...** to change the address. The new address is applied immediately and saved locally in:

```text
%LocalAppData%\LCP Control\settings.json
```

The same file stores the window position and size when the application closes. The next launch restores them, unless the saved position is no longer visible on a connected display.

`LCP_FRONTEND_URL` can be used as a temporary override. It takes precedence over the saved address for the current process:

```powershell
$env:LCP_FRONTEND_URL = "http://<LCP-host>:5174/data-collection"
Start-Process ".\LCP Control.exe"
```

## Build

Install the [.NET SDK 8 or later](https://dotnet.microsoft.com/download) on Windows, then run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\build.ps1
```

The build output is written to:

```text
release\LCP-Control-Only
```

The distributable archive is created at:

```text
release\LCP-Control-Only-win-x64.zip
```

## Distribution and requirements

Extract the entire distribution archive to one folder and run `LCP Control.exe`. Do not distribute the executable by itself, because it needs the WebView2 DLL files beside it.

The target computer needs:

- Windows x64 and .NET Framework 4.8.
- Microsoft Edge WebView2 Evergreen Runtime. It is included with Windows 11 and is already present on most Windows 10 computers. If it is missing, the application opens Microsoft's download page.
- Network access to the configured LCP frontend.

The application does not impose a minimum window size. When the window is small, the page can be scrolled to access all collection controls.
