using System;
using System.Diagnostics;
using System.Drawing;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace LcpControlOnly
{
    internal sealed class CollectorForm : Form
    {
        private const string WindowTitle = "LCP 采集控制（置顶）";

        // The LCP site exposes the full data-collection dashboard as one route.
        // Keep the original React card in place, so its handlers continue to work,
        // and hide the surrounding dashboard after the lazy component is mounted.
        private const string ControlOnlyScript = @"
(() => {
  if (window.__lcpControlOnlyScriptAdded) return;
  window.__lcpControlOnlyScriptAdded = true;

  const install = () => {
    let observer;
    let timeout;

    const activate = () => {
      const title = [...document.querySelectorAll('[data-slot=""card-title""]')]
        .find((element) => element.textContent.trim() === ""采集控制"");
      const card = title?.closest('[data-slot=""card""]');
      const column = card?.parentElement;
      const grid = column?.parentElement;
      const container = grid?.parentElement;

      if (!(card instanceof HTMLElement) ||
          !(column instanceof HTMLElement) ||
          !(grid instanceof HTMLElement) ||
          !(container instanceof HTMLElement)) {
        return false;
      }

      document.documentElement.classList.add(""lcp-control-only"");
      document.querySelectorAll(""header"").forEach((header) => {
        header.setAttribute(""data-lcp-control-only-hidden"", ""1"");
      });
      [...grid.children].forEach((child) => {
        if (child !== column) child.setAttribute(""data-lcp-control-only-hidden"", ""1"");
      });
      [...column.children].forEach((child) => {
        if (child !== card) child.setAttribute(""data-lcp-control-only-hidden"", ""1"");
      });

      grid.style.setProperty(""display"", ""block"", ""important"");
      column.style.setProperty(""width"", ""100%"", ""important"");
      column.style.setProperty(""max-width"", ""960px"", ""important"");
      column.style.setProperty(""margin"", ""0 auto"", ""important"");
      card.style.setProperty(""width"", ""100%"", ""important"");
      container.style.setProperty(""max-width"", ""992px"", ""important"");
      container.style.setProperty(""padding"", ""16px"", ""important"");

      if (!document.getElementById(""lcp-control-only-style"")) {
        const style = document.createElement(""style"");
        style.id = ""lcp-control-only-style"";
        style.textContent = [
          ""html.lcp-control-only, html.lcp-control-only body, html.lcp-control-only #root {"",
          ""  min-width: 0 !important;"",
          ""  background: hsl(var(--background)) !important;"",
          ""}"",
          ""[data-lcp-control-only-hidden] { display: none !important; }"",
        ].join(String.fromCharCode(10));
        document.head.append(style);
      }

      window.scrollTo(0, 0);
      observer?.disconnect();
      window.clearTimeout(timeout);
      return true;
    };

    if (activate()) return;
    observer = new MutationObserver(() => activate());
    observer.observe(document.documentElement, { childList: true, subtree: true });
    timeout = window.setTimeout(() => observer?.disconnect(), 15000);
  };

  if (document.readyState === ""loading"") {
    document.addEventListener(""DOMContentLoaded"", install, { once: true });
  } else {
    install();
  }
})();";

        private readonly WebView2 webView;
        private readonly ToolStripMenuItem topMostMenuItem;
        private Uri collectorUri;

        public CollectorForm()
        {
            collectorUri = ResolveStartupUri();

            Text = WindowTitle;
            StartPosition = FormStartPosition.CenterScreen;
            Size = new Size(900, 900);
            TopMost = true;
            KeyPreview = true;
            RestoreSavedWindowBounds();

            var menu = new MenuStrip();
            var collectionMenu = new ToolStripMenuItem("采集");
            var reloadMenuItem = new ToolStripMenuItem("重新加载采集控制", null, ReloadPage, Keys.Control | Keys.R);
            var openInBrowserMenuItem = new ToolStripMenuItem("在默认浏览器中打开", null, OpenInBrowser);
            collectionMenu.DropDownItems.Add(reloadMenuItem);
            collectionMenu.DropDownItems.Add(openInBrowserMenuItem);
            collectionMenu.DropDownItems.Add(new ToolStripSeparator());
            collectionMenu.DropDownItems.Add(new ToolStripMenuItem("退出", null, delegate { Close(); }));

            var windowMenu = new ToolStripMenuItem("窗口");
            topMostMenuItem = new ToolStripMenuItem("始终置顶")
            {
                CheckOnClick = true,
                Checked = true,
                ShortcutKeys = Keys.Control | Keys.Shift | Keys.T,
            };
            topMostMenuItem.CheckedChanged += TopMostMenuItem_CheckedChanged;
            windowMenu.DropDownItems.Add(topMostMenuItem);
            windowMenu.DropDownItems.Add(new ToolStripMenuItem("最小化", null, delegate { WindowState = FormWindowState.Minimized; }));

            var settingsMenu = new ToolStripMenuItem("设置");
            settingsMenu.DropDownItems.Add(new ToolStripMenuItem("前端地址...", null, ConfigureFrontendAddress));

            menu.Items.Add(collectionMenu);
            menu.Items.Add(windowMenu);
            menu.Items.Add(settingsMenu);
            MainMenuStrip = menu;

            webView = new WebView2 { Dock = DockStyle.Fill };
            webView.NavigationCompleted += WebView_NavigationCompleted;

            Controls.Add(webView);
            Controls.Add(menu);
            Load += CollectorForm_Load;
            FormClosing += CollectorForm_FormClosing;
            KeyDown += CollectorForm_KeyDown;
        }

        private async void CollectorForm_Load(object sender, EventArgs e)
        {
            try
            {
                await webView.EnsureCoreWebView2Async(null);
                webView.CoreWebView2.NewWindowRequested += CoreWebView2_NewWindowRequested;
                await webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(ControlOnlyScript);
                webView.Source = collectorUri;
            }
            catch (WebView2RuntimeNotFoundException)
            {
                MessageBox.Show(
                    this,
                    "未检测到 Microsoft Edge WebView2 Runtime。请安装 Evergreen Runtime 后重新启动程序。",
                    "缺少 WebView2 Runtime",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                OpenExternal("https://developer.microsoft.com/microsoft-edge/webview2/");
                Close();
            }
            catch (Exception exception)
            {
                MessageBox.Show(
                    this,
                    "无法初始化采集控制窗口：" + exception.Message,
                    "LCP 采集控制",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                Close();
            }
        }

        private async void WebView_NavigationCompleted(object sender, CoreWebView2NavigationCompletedEventArgs e)
        {
            if (!e.IsSuccess)
            {
                Text = "LCP 采集控制（连接失败）";
                return;
            }

            Text = TopMost ? WindowTitle : "LCP 采集控制";
            try
            {
                // Also run after navigation completes in case a local development
                // server loads the React component after DOMContentLoaded.
                await webView.CoreWebView2.ExecuteScriptAsync(ControlOnlyScript);
            }
            catch (Exception exception)
            {
                Debug.WriteLine("Unable to apply control-only layout: " + exception);
            }
        }

        private void CoreWebView2_NewWindowRequested(object sender, CoreWebView2NewWindowRequestedEventArgs e)
        {
            e.Handled = true;
            OpenExternal(e.Uri);
        }

        private void ReloadPage(object sender, EventArgs e)
        {
            if (webView.CoreWebView2 != null)
            {
                webView.CoreWebView2.Reload();
            }
        }

        private void OpenInBrowser(object sender, EventArgs e)
        {
            OpenExternal(collectorUri.AbsoluteUri);
        }

        private void ConfigureFrontendAddress(object sender, EventArgs e)
        {
            var configuredUri = SettingsStore.LoadFrontendUri();
            using (var dialog = new FrontendAddressDialog(configuredUri.AbsoluteUri))
            {
                if (dialog.ShowDialog(this) != DialogResult.OK)
                {
                    return;
                }

                try
                {
                    var savedUri = SettingsStore.SaveFrontendUri(dialog.FrontendAddress);
                    if (HasEnvironmentOverride())
                    {
                        MessageBox.Show(
                            this,
                            "地址已保存。当前进程设置了 LCP_FRONTEND_URL，清除该环境变量后重启程序即可使用保存的地址。",
                            "前端地址已保存",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Information);
                        return;
                    }

                    collectorUri = savedUri;
                    if (webView.CoreWebView2 != null)
                    {
                        webView.Source = collectorUri;
                    }
                }
                catch (Exception exception)
                {
                    MessageBox.Show(
                        this,
                        exception.Message,
                        "前端地址无效",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                }
            }
        }

        private void TopMostMenuItem_CheckedChanged(object sender, EventArgs e)
        {
            TopMost = topMostMenuItem.Checked;
            Text = TopMost ? WindowTitle : "LCP 采集控制";
        }

        private void CollectorForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            try
            {
                var bounds = WindowState == FormWindowState.Normal ? Bounds : RestoreBounds;
                SettingsStore.SaveWindowBounds(bounds);
            }
            catch (Exception exception)
            {
                Debug.WriteLine("Unable to save window bounds: " + exception);
            }
        }

        private void CollectorForm_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control && !e.Shift && e.KeyCode == Keys.R)
            {
                ReloadPage(sender, EventArgs.Empty);
                e.SuppressKeyPress = true;
            }
            else if (e.Control && e.Shift && e.KeyCode == Keys.T)
            {
                topMostMenuItem.Checked = !topMostMenuItem.Checked;
                e.SuppressKeyPress = true;
            }
        }

        private static Uri ResolveStartupUri()
        {
            var configuredUrl = Environment.GetEnvironmentVariable("LCP_FRONTEND_URL");
            return string.IsNullOrWhiteSpace(configuredUrl)
                ? SettingsStore.LoadFrontendUri()
                : SettingsStore.NormalizeFrontendUri(configuredUrl);
        }

        private static bool HasEnvironmentOverride()
        {
            return !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("LCP_FRONTEND_URL"));
        }

        private void RestoreSavedWindowBounds()
        {
            var savedBounds = SettingsStore.LoadWindowBounds();
            if (!savedBounds.HasValue || !IsVisibleOnAnyScreen(savedBounds.Value))
            {
                return;
            }

            StartPosition = FormStartPosition.Manual;
            Bounds = savedBounds.Value;
        }

        private static bool IsVisibleOnAnyScreen(Rectangle bounds)
        {
            foreach (var screen in Screen.AllScreens)
            {
                if (screen.WorkingArea.IntersectsWith(bounds))
                {
                    return true;
                }
            }
            return false;
        }

        private static void OpenExternal(string url)
        {
            Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
        }
    }
}
