/* FlowSight Core JS v1.0.0 */

(function () {
  const CUSTOMER_URL = window.FLOWSIGHT_CUSTOMER_URL;
  if (!CUSTOMER_URL) {
    console.error("FlowSight: window.FLOWSIGHT_CUSTOMER_URL missing");
    return;
  }

  const FS = {
    data: null,
    events: [],
    config: {
      attrText: "data-slot",
      attrImage: "data-slot-image",
      attrHref: "data-slot-href",
      attrCta: "data-cta",
      repeater: "data-repeat",
      template: "data-template",
      bind: "data-bind",
      chatRoot: "data-chat"
    }
  };

  function get(obj, path) {
    if (!obj || !path) return undefined;
    return path.split(".").reduce((o, k) => (o ? o[k] : undefined), obj);
  }

  async function loadCustomer() {
    const res = await fetch(CUSTOMER_URL, { cache: "no-store" });
    if (!res.ok) throw new Error("FlowSight: customer.json fetch failed");
    return await res.json();
  }

  function setText(el, value) {
    if (value === undefined || value === null) return;
    el.textContent = String(value);
  }

  function setImage(el, value) {
    if (!value) return;
    el.setAttribute("src", value);
  }

  function setHref(el, value) {
    if (!value) return;
    el.setAttribute("href", value);
  }

  function fillSlots(root, data) {
    root.querySelectorAll(`[${FS.config.attrText}]`).forEach(el => {
      const path = el.getAttribute(FS.config.attrText);
      setText(el, get(data, path));
    });

    root.querySelectorAll(`[${FS.config.attrImage}]`).forEach(el => {
      const path = el.getAttribute(FS.config.attrImage);
      setImage(el, get(data, path));
    });

    root.querySelectorAll(`[${FS.config.attrHref}]`).forEach(el => {
      const path = el.getAttribute(FS.config.attrHref);
      setHref(el, get(data, path));
    });
  }

  function renderRepeaters(data) {
    document.querySelectorAll(`[${FS.config.repeater}]`).forEach(host => {
      const listPath = host.getAttribute(FS.config.repeater);
      const items = get(data, listPath);
      if (!Array.isArray(items)) return;

      const tpl = host.querySelector(`[${FS.config.template}]`);
      if (!tpl) return;

      host.querySelectorAll(`:scope > :not([${FS.config.template}])`).forEach(n => n.remove());

      items.forEach((item, idx) => {
        const node = tpl.cloneNode(true);
        node.removeAttribute(FS.config.template);
        node.classList.remove("fs-hidden");

        node.querySelectorAll(`[${FS.config.bind}]`).forEach(bindEl => {
          const bindKey = bindEl.getAttribute(FS.config.bind);
          setText(bindEl, item[bindKey]);
        });

        node.querySelectorAll(`[${FS.config.attrImage}]`).forEach(imgEl => {
          const p = imgEl.getAttribute(FS.config.attrImage);
          if (p.startsWith("$item.")) {
            const k = p.replace("$item.", "");
            setImage(imgEl, item[k]);
          } else {
            setImage(imgEl, get(data, p));
          }
        });

        node.setAttribute("data-idx", String(idx));
        host.appendChild(node);
      });
    });
  }

  function track(name, payload) {
    FS.events.push({ name, payload, ts: Date.now() });
    if (window.dataLayer) window.dataLayer.push({ event: name, ...payload });
  }

  function openChat(reason) {
    const chat = document.querySelector(`[${FS.config.chatRoot}]`);
    if (chat) chat.classList.add("is-open");
    track("fs_chat_open", { reason: reason || "manual" });
    if (!chat) alert("Chat-Demo: Rückruf-Anfrage wird erfasst.");
  }

  function setupCTAs(data) {
    const ctas = data?.routing?.ctas || {};
    document.querySelectorAll(`[${FS.config.attrCta}]`).forEach(el => {
      const mode = el.getAttribute(FS.config.attrCta);
      const cta = ctas[mode];
      if (!cta) return;

      el.textContent = cta.label;

      if (cta.type === "tel") {
        el.setAttribute("href", "tel:" + cta.value);
        el.addEventListener("click", () => track("fs_cta_tel", { mode, track_id: cta.track_id || "" }));
        return;
      }

      if (cta.type === "form") {
        el.setAttribute("href", cta.value || "#kontakt");
        el.addEventListener("click", () => track("fs_cta_form", { mode, track_id: cta.track_id || "" }));
        return;
      }

      if (cta.type === "link") {
        el.setAttribute("href", cta.value || "#");
        el.setAttribute("rel", "noopener");
        el.setAttribute("target", "_blank");
        el.addEventListener("click", () => track("fs_cta_link", { mode, track_id: cta.track_id || "" }));
        return;
      }

      if (cta.type === "chat") {
        el.setAttribute("href", "#");
        el.addEventListener("click", (e) => {
          e.preventDefault();
          openChat("cta_" + mode);
        });
        return;
      }
    });
  }

  function setupProactiveChat(data) {
    const chatCfg = data?.integrations?.chat;
    if (!chatCfg?.enabled) return;
    if (chatCfg.mode !== "proactive") return;

    let opened = false;

    const openIfIdle = () => {
      if (opened) return;
      opened = true;
      openChat("proactive_idle");
    };

    const timer = setTimeout(openIfIdle, 11000);

    const cancel = () => clearTimeout(timer);
    ["click", "keydown", "scroll", "touchstart"].forEach(evt =>
      window.addEventListener(evt, cancel, { passive: true, once: true })
    );
  }

  async function init() {
    const data = await loadCustomer();
    FS.data = data;

    fillSlots(document, data);
    renderRepeaters(data);
    setupCTAs(data);
    setupProactiveChat(data);

    track("fs_init", { customer_id: data?.meta?.customer_id || "unknown" });
    console.log("FlowSight: initialized");
  }

  document.addEventListener("DOMContentLoaded", () => {
    init().catch(err => console.error("FlowSight init failed:", err));
  });
})();
