/* FlowSight core.js
   Version: 1.0 (2026-01-30)
   Responsibilities:
     - load customer.json
     - bind slots (text/href/image)
     - render repeaters
     - route CTAs
     - embed map
     - expose hooks for Chat/Voice later
*/

(function(){
  'use strict';

  const DEBUG = !!window.FLOWSIGHT_DEBUG;

  const log = (...args) => { if (DEBUG) console.log('[FlowSight]', ...args); };
  const warn = (...args) => console.warn('[FlowSight]', ...args);

  function isObject(v){ return v && typeof v === 'object' && !Array.isArray(v); }

  function getByPath(obj, path){
    if (!path) return undefined;
    const parts = path.split('.').filter(Boolean);
    let cur = obj;
    for (const p of parts){
      if (cur == null) return undefined;
      cur = cur[p];
    }
    return cur;
  }
  function applyConditionals(root, data){
    // STRICT: show only if value === true; otherwise hide.
    root.querySelectorAll('[data-if]').forEach(el => {
      const path = el.getAttribute('data-if');
      const val  = getByPath(data, path);
      const show = (val === true);

      if (!show){
        el.style.display = 'none';
        el.setAttribute('data-if-hidden','1');
      } else {
        el.style.removeProperty('display');
        el.removeAttribute('data-if-hidden');
      }
    });
  }



  function setText(el, value){
    if (value == null) return;
    const mode = el.getAttribute('data-slot-mode');
    if (mode === 'html'){
      el.innerHTML = String(value);
    } else {
      el.textContent = String(value);
    }
  }

  function setHref(el, value){
    if (value == null) return;
    const prefix = el.getAttribute('data-href-prefix') || '';
    const href = prefix + String(value);
    // Only set if element supports href
    if ('href' in el){
      el.setAttribute('href', href);
    } else {
      // fallback: data-href on non-link elements
      el.setAttribute('data-href', href);
    }
  }

  function setImage(el, value){
    if (value == null) return;
    const url = String(value);
    const tag = (el.tagName || '').toLowerCase();
    if (tag === 'img'){
      el.setAttribute('src', url);
      return;
    }
    // For <a> used as brand, prefer background-image so Webflow stays valid
    el.style.backgroundImage = `url("${url}")`;
  }

  function bindSlots(root, data){
    // data-slot
    root.querySelectorAll('[data-slot]').forEach(el => {
      const path = el.getAttribute('data-slot');
      const value = getByPath(data, path);
      if (value !== undefined) setText(el, value);
    });

    // data-slot-href
    root.querySelectorAll('[data-slot-href]').forEach(el => {
      const path = el.getAttribute('data-slot-href');
      const value = getByPath(data, path);
      if (value !== undefined) setHref(el, value);
    });

    // data-slot-image
    root.querySelectorAll('[data-slot-image]').forEach(el => {
      const path = el.getAttribute('data-slot-image');
      const value = getByPath(data, path);
      if (value !== undefined) setImage(el, value);
    });
  }

  function clearRepeaterHost(host){
    const tpl = host.querySelector('[data-template]');
    if (!tpl){
      warn('Repeater host has no [data-template] child:', host);
      return null;
    }
    // Remove everything except template
    [...host.children].forEach(ch => { if (ch !== tpl) ch.remove(); });
    return tpl;
  }

  function bindTemplateNode(node, item, rootData){
    node.querySelectorAll('[data-bind]').forEach(el => {
      const rel = el.getAttribute('data-bind');
      const val = getByPath(item, rel);
      if (val !== undefined) setText(el, val);
    });

    node.querySelectorAll('[data-bind-image]').forEach(el => {
      const rel = el.getAttribute('data-bind-image');
      const val = getByPath(item, rel);
      if (val !== undefined) setImage(el, val);
    });

    node.querySelectorAll('[data-bind-alt]').forEach(el => {
      const rel = el.getAttribute('data-bind-alt');
      const val = getByPath(item, rel);
      if (val !== undefined) el.setAttribute('alt', String(val));
    });

    node.querySelectorAll('[data-bind-href]').forEach(el => {
      const rel = el.getAttribute('data-bind-href');
      const val = getByPath(item, rel);
      if (val !== undefined) setHref(el, val);
    });

    node.querySelectorAll('[data-slot]').forEach(el => {
      const path = el.getAttribute('data-slot');
      const val = getByPath(rootData, path);
      if (val !== undefined) setText(el, val);
    });

    node.querySelectorAll('[data-slot-href]').forEach(el => {
      const path = el.getAttribute('data-slot-href');
      const val = getByPath(rootData, path);
      if (val !== undefined) setHref(el, val);
    });

    node.querySelectorAll('[data-slot-image]').forEach(el => {
      const path = el.getAttribute('data-slot-image');
      const val = getByPath(rootData, path);
      if (val !== undefined) setImage(el, val);
    });
  }

function renderRepeaters(root, data, ctx){
    const context = ctx || data;

    root.querySelectorAll('[data-repeat]').forEach(host => {
      const path = host.getAttribute('data-repeat');

      let arr = getByPath(context, path);
      if (!Array.isArray(arr)) arr = getByPath(data, path);

      if (!Array.isArray(arr)){
        return;
      }

      const tpl = clearRepeaterHost(host);
      if (!tpl) return;

      tpl.style.display = 'none';

      const frag = document.createDocumentFragment();

      arr.forEach(item => {
        const clone = tpl.cloneNode(true);
        clone.removeAttribute('data-template');
        clone.style.display = '';

        bindTemplateNode(clone, item, data);

        // nested repeaters inside clone
        renderRepeaters(clone, data, item);

        frag.appendChild(clone);
      });

      host.appendChild(frag);
    });
  }

function routeCTAs(root, data){
    const emergencyTel = getByPath(data, 'contact.phones.emergency.e164');
    const emergencyLabel = getByPath(data, 'contact.phones.emergency.display') || '24/7 Notfall';
    const normalTel = getByPath(data, 'contact.phones.normal.e164');
    const normalLabel = getByPath(data, 'contact.phones.normal.display') || 'Kontakt';
    const reviewUrl = getByPath(data, 'links.google_review');
    const reviewLabel = getByPath(data, 'cta.labels.review') || 'Bewertung schreiben';

    root.querySelectorAll('[data-cta]').forEach(el => {
      const type = (el.getAttribute('data-cta') || '').toLowerCase();

      if (type === 'emergency'){
        if (emergencyTel) el.setAttribute('href', 'tel:' + emergencyTel);
        if (el.textContent.trim() === '' || el.textContent.trim() === 'Button Text') el.textContent = emergencyLabel;
        el.classList.add('btn','btn--emergency');
        return;
      }

      if (type === 'normal'){
        if (normalTel) el.setAttribute('href', 'tel:' + normalTel);
        if (el.textContent.trim() === '' || el.textContent.trim() === 'Button Text') el.textContent = normalLabel;
        el.classList.add('btn','btn--primary');
        return;
      }

      if (type === 'review'){
        if (reviewUrl) el.setAttribute('href', reviewUrl);
        if (el.textContent.trim() === '' || el.textContent.trim() === 'Button Text') el.textContent = reviewLabel;
        el.setAttribute('target','_blank');
        el.setAttribute('rel','noopener');
        el.classList.add('btn','btn--ghost');
        return;
      }
    });
  }

  function embedMap(root, data){
    root.querySelectorAll('[data-map-embed]').forEach(el => {
      const path = el.getAttribute('data-map-embed');
      const url = getByPath(data, path);
      if (!url) return;

      // Only inject once
      if (el.querySelector('iframe')) return;

      const iframe = document.createElement('iframe');
      iframe.src = String(url);
      iframe.width = '100%';
      iframe.height = '360';
      iframe.loading = 'lazy';
      iframe.referrerPolicy = 'no-referrer-when-downgrade';
      iframe.style.border = '0';
      iframe.setAttribute('allowfullscreen', '');

      el.innerHTML = '';
      el.appendChild(iframe);
    });
  }

  async function loadCustomerData(){
    const url = window.FLOWSIGHT_CUSTOMER_URL;
    if (!url){
      warn('window.FLOWSIGHT_CUSTOMER_URL missing. No bindings executed.');
      return null;
    }
    const res = await fetch(url, { cache: 'no-store' });
    if (!res.ok) throw new Error(`customer.json fetch failed: ${res.status}`);
    return await res.json();
  }

  function setDocumentTitle(data){
    // If body has data-bind="title", treat as "business.name – region"
    const body = document.body;
    if (!body) return;
    const bind = body.getAttribute('data-bind');
    if (bind !== 'title') return;

    const name = getByPath(data, 'business.name');
    const region = getByPath(data, 'business.region_label');
    if (name && region) document.title = `${name} – ${region}`;
    else if (name) document.title = String(name);
  }
  function applyTheme(data){
    const c = (data && data.theme && data.theme.colors) ? data.theme.colors : null;
    if (!c) return;

    const root = document.documentElement;
    const map = {
      "--c-primary": c.primary,
      "--c-primary-600": c.primary_600,
      "--c-primary-200": c.primary_200,
      "--c-on-primary": c.on_primary,
      "--c-accent": c.accent,
      "--c-on-accent": c.on_accent,
      "--c-bg": c.bg,
      "--c-surface": c.surface,
      "--c-surface-2": c.surface_2,
      "--c-text": c.text,
      "--c-muted": c.muted,
      "--c-border": c.border,
      "--c-success": c.success,
      "--c-danger": c.danger,
      "--radius": c.radius,
      "--shadow-1": c.shadow_1
    };

    Object.entries(map).forEach(([k,v]) => {
      if (v !== undefined && v !== null && String(v).trim() !== ""){
        root.style.setProperty(k, String(v));
      }
    });
  }



  function initHooks(data){
    // Placeholder extension points (do nothing unless provided)
    if (window.FlowSightChat && typeof window.FlowSightChat.init === 'function'){
      try { window.FlowSightChat.init({ data }); } catch (e){ warn('Chat init failed:', e); }
    }
    if (window.FlowSightVoice && typeof window.FlowSightVoice.init === 'function'){
      try { window.FlowSightVoice.init({ data }); } catch (e){ warn('Voice init failed:', e); }
    }
  }

  async function boot(){
    try{
      const data = await loadCustomerData();
      if (!data) return;

      log('customer loaded');

      setDocumentTitle(data);
      
        applyTheme(data);
// Order matters: first render repeaters (creates nodes), then bind slots, then CTAs & map.
      applyConditionals(document, data);
      renderRepeaters(document, data);
      bindSlots(document, data);
      routeCTAs(document, data);
      embedMap(document, data);
      initHooks(data);

      log('boot complete');
    } catch (e){
      warn('boot failed:', e);
    }
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();

/* FS_FAST_ANCHORS_START */
/* Fast anchor navigation (prevents Webflow smooth-scroll lag)
   - intercepts internal hash links early (capture)
   - scrolls instantly with sticky-nav offset
   Optional:
   window.FLOWSIGHT_SCROLL_BEHAVIOR = "smooth" | "auto" (default auto)
*/
(function(){
  'use strict';

  function getNavOffset(){
    var nav = document.querySelector('.w-nav');
    var h = nav ? nav.offsetHeight : 0;
    return Math.max(0, h + 12);
  }

  function onClick(e){
    var a = e.target && e.target.closest ? e.target.closest('a[href^="#"]') : null;
    if (!a) return;

    var href = a.getAttribute('href');
    if (!href || href === '#') return;

    var id = href.slice(1);
    var target = document.getElementById(id);
    if (!target) return;

    // override Webflow scroll handlers
    e.preventDefault();
    e.stopPropagation();

    // close mobile nav if open
    var openBtn = document.querySelector('.w-nav-button.w--open');
    if (openBtn) { try { openBtn.click(); } catch(_){} }

    var offset = getNavOffset();
    var top = target.getBoundingClientRect().top + (window.pageYOffset || 0) - offset;
    if (top < 0) top = 0;

    var behavior = (window.FLOWSIGHT_SCROLL_BEHAVIOR || 'auto');
    window.scrollTo({ top: top, behavior: behavior === 'smooth' ? 'smooth' : 'auto' });

    // keep URL hash (without triggering default jump)
    try { history.pushState(null, '', href); } catch(_){}
  }

  // capture = true so we win against Webflow handlers
  document.addEventListener('click', onClick, true);
})();
/* FS_FAST_ANCHORS_END */

/* FS_TEMPLATE_ON_QA_START */
/* Template-on QA Mode:
   - ensures all standard sections are visible on template-on
   - removes common hide mechanisms (display:none, hidden, w-condition-invisible)
   - logs missing IDs (hard facts)
*/
(function(){
  'use strict';

  function isTemplateOn(){
    var u = String(window.FLOWSIGHT_CUSTOMER_URL || '');
    return (u.indexOf('/customers/template-on/') >= 0) || (u.indexOf('customers/template-on') >= 0);
  }

  var QA = isTemplateOn() || !!window.FLOWSIGHT_DEBUG;
  if (!QA) return;

  var IDS = ['hero','services','process','areas','trust-badges','reviews','cases','certs','faq','contact','footer'];

  function unhide(el){
    if (!el) return;
    try { el.hidden = false; } catch(_){}
    try { el.removeAttribute('hidden'); } catch(_){}
    try { el.classList.remove('w-condition-invisible'); } catch(_){}
    try { el.style.removeProperty('display'); } catch(_){}
    try { el.style.removeProperty('visibility'); } catch(_){}
    try { el.style.removeProperty('opacity'); } catch(_){}
  }

  function forceShow(){
    var missing = [];
    IDS.forEach(function(id){
      var s = document.getElementById(id);
      if (!s){ missing.push(id); return; }
      unhide(s);

      // also unhide common hidden descendants (Webflow conditionals etc.)
      var hiddenKids = s.querySelectorAll('[hidden], .w-condition-invisible');
      for (var i=0; i<hiddenKids.length; i++) unhide(hiddenKids[i]);
    });

    if (window.FLOWSIGHT_DEBUG && missing.length){
      console.warn('[FlowSight][QA] Missing section IDs in DOM:', missing);
    }
  }

  // Run multiple times to beat late-applied Webflow/JS hides
  function boot(){
    forceShow();
    setTimeout(forceShow, 50);
    setTimeout(forceShow, 350);
    setTimeout(forceShow, 900);
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
/* FS_TEMPLATE_ON_QA_END */
