# LCP 采集控制（WebView2 轻量版）

这是 LCP 数据采集窗口的 Windows 原生轻量版。它只显示现有前端页面中的“采集控制”面板，并保留置顶、重新加载、浏览器打开和 `Ctrl+Shift+T` 置顶切换。

程序不携带 Chromium，而是使用 Microsoft Edge WebView2 Runtime。因此发布包只包含本程序、WebView2 SDK 的少量 DLL 和配置文件；同一台电脑上的 WebView2 Runtime 由所有应用共享。

## 前端地址

首次启动默认访问 `http://192.168.50.32:5174/data-collection`。在程序菜单选择“设置 → 前端地址...”，修改并保存后会立即切换，并持久化到：

```text
%LocalAppData%\LCP Control\settings.json
```

如设置了 `LCP_FRONTEND_URL` 环境变量，它会临时覆盖本地保存的地址；清除该变量并重新启动程序后，才会使用保存的地址。

程序关闭时会将当前窗口的位置和尺寸写入同一个 `settings.json`，下次启动时恢复。若保存的位置已不在任何已连接显示器上，程序会改用默认居中位置。

## 编译

在 Windows 上安装 [.NET SDK 8 或更新版本](https://dotnet.microsoft.com/download)，然后在本目录运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\build.ps1
```

输出目录为 `release\LCP-Control-Only`；可分发压缩包为 `release\LCP-Control-Only-win-x64.zip`。

## 分发与运行

将 ZIP 的全部内容解压到同一目录，运行 `LCP Control.exe`。不要只复制 EXE，因为它依赖同目录的 WebView2 DLL。

运行电脑需具备：

- Windows x64 与 .NET Framework 4.8。
- Microsoft Edge WebView2 Evergreen Runtime。Windows 11 自带；多数 Windows 10 已有。如缺失，程序会打开 Microsoft 的下载页安装它。
- 能访问 `http://192.168.50.32:5174`。

临时覆盖地址可在启动前设置：

```powershell
$env:LCP_FRONTEND_URL = "http://<LCP主机>:5174/data-collection"
Start-Process ".\LCP Control.exe"
```

窗口不设置应用级最小尺寸；缩小时可滚动操作采集控制项。
