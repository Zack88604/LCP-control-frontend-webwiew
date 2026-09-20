import Foundation

enum ControlOnlyScript {
    static let source = #"""
    (() => {
      if (window.__lcpControlOnlyScriptAdded) return;
      window.__lcpControlOnlyScriptAdded = true;

      const install = () => {
        let observer;
        let timeout;

        const activate = () => {
          const title = [...document.querySelectorAll('[data-slot="card-title"]')]
            .find((element) => element.textContent.trim() === "采集控制");
          const card = title?.closest('[data-slot="card"]');
          const column = card?.parentElement;
          const grid = column?.parentElement;
          const container = grid?.parentElement;

          if (!(card instanceof HTMLElement) ||
              !(column instanceof HTMLElement) ||
              !(grid instanceof HTMLElement) ||
              !(container instanceof HTMLElement)) {
            return false;
          }

          document.documentElement.classList.add("lcp-control-only");
          document.querySelectorAll("header").forEach((header) => {
            header.setAttribute("data-lcp-control-only-hidden", "1");
          });
          [...grid.children].forEach((child) => {
            if (child !== column) child.setAttribute("data-lcp-control-only-hidden", "1");
          });
          [...column.children].forEach((child) => {
            if (child !== card) child.setAttribute("data-lcp-control-only-hidden", "1");
          });

          grid.style.setProperty("display", "block", "important");
          column.style.setProperty("width", "100%", "important");
          column.style.setProperty("max-width", "960px", "important");
          column.style.setProperty("margin", "0 auto", "important");
          card.style.setProperty("width", "100%", "important");
          container.style.setProperty("max-width", "992px", "important");
          container.style.setProperty("padding", "16px", "important");

          if (!document.getElementById("lcp-control-only-style")) {
            const style = document.createElement("style");
            style.id = "lcp-control-only-style";
            style.textContent = [
              "html.lcp-control-only, html.lcp-control-only body, html.lcp-control-only #root {",
              "  min-width: 0 !important;",
              "  background: hsl(var(--background)) !important;",
              "}",
              "[data-lcp-control-only-hidden] { display: none !important; }",
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

      if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", install, { once: true });
      } else {
        install();
      }
    })();
    """#
}
