import Foundation

enum ControlOnlyScript {
    static let source = #"""
    (() => {
      const state = window.__lcpControlOnlyState || (window.__lcpControlOnlyState = {});

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
          return;
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

        if (!state.active) {
          state.active = true;
          window.scrollTo(0, 0);
        }
      };

      const install = () => {
        activate();
        if (state.observer) return;
        state.observer = new MutationObserver(activate);
        state.observer.observe(document, { childList: true, subtree: true });
      };

      if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", install, { once: true });
      }
      install();
    })();
    """#
}
