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

      const local = fsClosestItemData(el);

      const vLocal = local ? getByPath(local, path) : undefined;

      const val = (vLocal !== undefined) ? vLocal : getByPath(rootData, path);

      if (val !== undefined) setImage(el, val);

    });
  }

function fsClosestItemData(el){
  var n = el;
  while (n) {
    if (n.__fsItemData !== undefined) return n.__fsItemData;
    n = n.parentElement;
  }
  return undefined;
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
clone.__fsItemData = item;
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
/* FS_P2_5_FOOTER_START
  Footer Contract (JSON-driven):
  - Year auto + business.name
  - Legal links (privacy/impressum) ensure non-empty labels + aria-label
  - Support footer.legal_title even if authored as data-bind (footer-scope alias)
  - Optional links.google_review -> append link in footer legal block
*/
function fsFooterGet(obj, path){
  try{
    if (typeof getByPath === 'function') return getByPath(obj, path);
  } catch(e){}
  // fallback
  const parts = String(path||'').split('.').filter(Boolean);
  let cur = obj;
  for (const k of parts){ if (cur == null) return undefined; cur = cur[k]; }
  return cur;
}

function fsApplyFooterContract(root, data){
  try{
    const footer = (root || document).querySelector && (root || document).querySelector('#footer');
    if (!footer) return;

    // A) footer.legal_title: allow authored as data-bind (alias) within footer scope only
    footer.querySelectorAll('[data-bind="footer.legal_title"]').forEach(el => {
      if ((el.textContent || '').trim()) return;
      const v = fsFooterGet(data, 'footer.legal_title');
      if (v != null) el.textContent = String(v);
    });

    // B) year + business name line (insert once)
    const year = String(new Date().getFullYear());
    const bname = fsFooterGet(data, 'business.name');
    const metaText = '© ' + year + (bname ? (' ' + String(bname)) : '');

    // Insert into footer__legal block if present; otherwise into footer container.
    const legal = footer.querySelector('.footer__legal') || footer;
    if (!legal.querySelector('[data-fs-footer-meta="1"]')){
      const meta = document.createElement('div');
      meta.className = 'footer__legal-title';
      meta.setAttribute('data-fs-footer-meta','1');
      meta.textContent = metaText;
      legal.appendChild(meta);
    } else {
      const meta = legal.querySelector('[data-fs-footer-meta="1"]');
      if (meta) meta.textContent = metaText;
    }

    // C) Ensure legal link labels are not empty (A11y safe)
    const links = footer.querySelectorAll('a.footer__legal-link');
    links.forEach(a => {
      const href = a.getAttribute('href') || '';
      const hasText = (a.textContent || '').trim().length > 0;

      if (!hasText){
        let label = '';
        if (href.indexOf('datenschutz') >= 0 || href.indexOf('privacy') >= 0) label = 'Datenschutz';
        if (href.indexOf('impressum') >= 0) label = 'Impressum';
        if (!label) label = 'Rechtliches';
        a.textContent = label;
      }
      if (!a.getAttribute('aria-label')){
        a.setAttribute('aria-label', (a.textContent || 'Rechtliches').trim());
      }
    });

    // D) Optional Google Review link
    const gr = fsFooterGet(data, 'links.google_review');
    if (gr && typeof gr === 'string'){
      const url = gr.trim();
      if (url){
        const exists = footer.querySelector('a[data-fs-google-review="1"]');
        if (!exists){
          const a = document.createElement('a');
          a.className = 'footer__legal-link w-inline-block';
          a.href = url;
          a.target = '_blank';
          a.rel = 'noopener';
          a.setAttribute('data-fs-google-review','1');
          a.textContent = 'Google Reviews';
          legal.appendChild(a);
        } else {
          exists.setAttribute('href', url);
        }
      }
    }
  } catch(e){
    if (window && window.FLOWSIGHT_DEBUG) console.warn('[FS_P2_5] footer contract failed', e);
  }
}
/* FS_P2_5_FOOTER_END */

async function boot(){
    try{
      const data = await loadCustomerData();
      if (!data) return;

      log("customer loaded");

      /* FS_BOOT_AFTER_CUSTOMER_LOADED */

      fsApplyDataIf(document, data);

      setDocumentTitle(data);
      
        applyTheme(data);
// Order matters: first render repeaters (creates nodes), then bind slots, then CTAs & map.
      applyConditionals(document, data);
      renderRepeaters(document, data);
      /* FS_BOOT_AFTER_REPEATERS */
      fsApplyDataIf(document, data);
      bindSlots(document, data);
      /* FS_P2_5_FOOTER_APPLIED */
      fsApplyFooterContract(document, data);
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

/* FS_REPEAT_FALLBACK_START */
/* Repeat Fallback Hydrator (robust, non-invasive)
   Purpose:
   - Fill Webflow repeat-lists even when templates are missing explicit data-bind nodes.
   - Supports: data-bind, data-bind-image, data-bind-href.
   - Safe: runs after DOMContentLoaded, marks repeaters as hydrated, avoids duplication.

   Note: This does NOT replace your existing engine; it only helps where templates are bind-less.
*/
(function(){
  'use strict';

  function isTemplateOn(){
    var u = String(window.FLOWSIGHT_CUSTOMER_URL || '');
    return (u.indexOf('/customers/template-on/') >= 0) || (u.indexOf('customers/template-on') >= 0);
  }

  // Run always; but log only in debug/template-on
  var DEBUG = !!window.FLOWSIGHT_DEBUG || isTemplateOn();

  function log(){
    if (!DEBUG) return;
    try { console.log.apply(console, arguments); } catch(_){}
  }

  function getByPath(obj, path){
    if (!obj || !path) return undefined;
    var p = String(path).split('.');
    var cur = obj;
    for (var i=0;i<p.length;i++){
      var key = p[i];
      if (cur == null) return undefined;
      // array index support
      if (key.match(/^\d+$/)) key = parseInt(key,10);
      cur = cur[key];
    }
    return cur;
  }

  function setText(el, val){
    if (!el) return;
    if (val == null) return;
    el.textContent = String(val);
  }

  function setHref(el, val){
    if (!el || val == null) return;
    var a = el;
    if (a.tagName !== 'A') a = el.closest('a') || el;
    try { a.setAttribute('href', String(val)); } catch(_){}
  }

  function setImage(el, val){
    if (!el || val == null) return;
    var img = el;
    if (img.tagName !== 'IMG') img = el.querySelector('img') || el.closest('img');
    if (!img) return;
    try { img.setAttribute('src', String(val)); } catch(_){}
  }

  function hasExplicitBinds(node){
    if (!node) return false;
    return !!(node.querySelector('[data-bind], [data-slot], [data-bind-image], [data-bind-href], [data-slot-image], [data-slot-href]'));
  }

  function smartFallbackFill(node, item, repeatPath){
    var p = String(repeatPath || '').toLowerCase();

    // primitive items -> label/text
    var t = '';
    var x = '';
    if (item == null) { t=''; x=''; }
    else if (typeof item === 'string' || typeof item === 'number'){
      t = String(item);
      x = '';
    } else {
      t = (item.title || item.label || item.name || item.q || item.question || '') + '';
      x = (item.text || item.description || item.subline || item.a || item.answer || '') + '';
    }

    var h = node.querySelector('h1,h2,h3,h4,h5,h6');
    var body = node.querySelector('p') || node.querySelector('[data-fs-body]') || node.querySelector('div') || node.querySelector('span');

    if (p.indexOf('faq') >= 0){
      if (h) setText(h, t);
      if (body) setText(body, x);
      return;
    }

    if (p.indexOf('process') >= 0 || p.indexOf('services') >= 0){
      if (h) setText(h, t);
      if (body) setText(body, x);
      return;
    }

    if (p.indexOf('areas') >= 0 || p.indexOf('cert') >= 0 || p.indexOf('trust') >= 0){
      setText(h || body || node, t || x);
      return;
    }

    if (p.indexOf('cases') >= 0){
      if (h) setText(h, t);
      if (body) setText(body, x);
      if (item && item.photos && Array.isArray(item.photos)){
        var imgs = node.querySelectorAll('img');
        for (var i=0; i<imgs.length && i<item.photos.length; i++){
          var src = item.photos[i] && (item.photos[i].src || item.photos[i].url || item.photos[i].image);
          if (src) setImage(imgs[i], src);
        }
      }
      return;
    }

    setText(h || body || node, t || x);
  }

  function bindNode(node, item, rootData, repeatPath){
    var did = false;

    // relative binds
    node.querySelectorAll('[data-bind]').forEach(function(el){
      var rel = el.getAttribute('data-bind');
      var v = getByPath(item, rel);
      if (v !== undefined){ setText(el, v); did = true; }
    });

    node.querySelectorAll('[data-bind-href]').forEach(function(el){
      var rel = el.getAttribute('data-bind-href');
      var v = getByPath(item, rel);
      if (v !== undefined){ setHref(el, v); did = true; }
    });

    node.querySelectorAll('[data-bind-image]').forEach(function(el){
      var rel = el.getAttribute('data-bind-image');
      var v = getByPath(item, rel);
      if (v !== undefined){ setImage(el, v); did = true; }
    });

    // allow absolute slots (rootData)
    node.querySelectorAll('[data-slot]').forEach(function(el){
      var path = el.getAttribute('data-slot');
      var v = getByPath(rootData, path);
      if (v !== undefined){ setText(el, v); did = true; }
    });

    node.querySelectorAll('[data-slot-href]').forEach(function(el){
      var path = el.getAttribute('data-slot-href');
      var v = getByPath(rootData, path);
      if (v !== undefined){ setHref(el, v); did = true; }
    });

    node.querySelectorAll('[data-slot-image]').forEach(function(el){

      var path = el.getAttribute('data-slot-image');

      var local = fsClosestItemData(el);

      var vLocal = local ? getByPath(local, path) : undefined;

      var v = (vLocal !== undefined) ? vLocal : getByPath(rootData, path);

      if (v !== undefined){ setImage(el, v); did = true; }

    });
    // fallback for bind-less templates
    if (!did){
      smartFallbackFill(node, item, repeatPath);
    }
  }

  function normalizeItems(items){
    if (!items) return [];
    if (Array.isArray(items)) return items;
    return [];
  }

  async function getCustomerData(){
    if (window.__fsCustomerCache) return window.__fsCustomerCache;
    var url = window.FLOWSIGHT_CUSTOMER_URL;
    if (!url) return null;
    try{
      var res = await fetch(url, { cache: 'no-store' });
      var json = await res.json();
      window.__fsCustomerCache = json;
      return json;
    } catch(e){
      log('[FlowSight][fallback] customer fetch failed', e);
      return null;
    }
  }

  function hydrateRepeater(rep, data){
    if (!rep || rep.getAttribute('data-fs-hydrated') === '1') return;

    var path = rep.getAttribute('data-repeat') || '';
    if (!path) return;

    var items = normalizeItems(getByPath(data, path));
    if (!items.length) return;

    // detect template
    var tpl = rep.querySelector('[data-template]');
    var children = Array.prototype.slice.call(rep.children || []);

    // CASE A: explicit data-template exists -> clone to match items
    if (tpl){
      // If already has clones produced by another engine, do not duplicate. Just fill existing.
      var nodes = Array.prototype.slice.call(rep.querySelectorAll('[data-fs-item]'));
      if (!nodes.length){
        // build nodes list from current children (including tpl)
        // keep tpl as base, then clone
        // First: ensure tpl is visible
        tpl.removeAttribute('data-template');

        // clear other children except tpl
        children.forEach(function(ch){
          if (ch !== tpl) ch.remove();
        });

        // create N nodes
        var frag = document.createDocumentFragment();
        for (var i=0; i<items.length; i++){
          var node = (i === 0) ? tpl : tpl.cloneNode(true);
          node.setAttribute('data-fs-item','1');
          frag.appendChild(node);
        }
        rep.appendChild(frag);
        nodes = Array.prototype.slice.call(rep.querySelectorAll('[data-fs-item]'));
      }

      for (var j=0; j<nodes.length && j<items.length; j++){
        var n = nodes[j];
        // if template has explicit binds, let them win; otherwise fallback
        bindNode(n, items[j], data, path);
      }

      rep.setAttribute('data-fs-hydrated','1');
      return;
    }

    // CASE B: no template marker. If multiple static children exist, fill them sequentially.
    if (children.length > 1){
      for (var k=0; k<children.length && k<items.length; k++){
        bindNode(children[k], items[k], data, path);
      }
      rep.setAttribute('data-fs-hydrated','1');
      return;
    }

    // CASE C: single child, clone it to match items
    if (children.length === 1){
      var base = children[0];
      var frag2 = document.createDocumentFragment();
      rep.innerHTML = '';
      for (var m=0; m<items.length; m++){
        var node2 = base.cloneNode(true);
        node2.setAttribute('data-fs-item','1');
        bindNode(node2, items[m], data, path);
        frag2.appendChild(node2);
      }
      rep.appendChild(frag2);
      rep.setAttribute('data-fs-hydrated','1');
      return;
    }
  }

  async function run(){
    var data = await getCustomerData();
    if (!data) return;

    var reps = document.querySelectorAll('[data-repeat]');
    reps.forEach(function(rep){
      // only help bind-less repeaters; if there are explicit binds inside, skip to avoid conflicts
      if (hasExplicitBinds(rep)) return;
      hydrateRepeater(rep, data);
    });

    log('[FlowSight][fallback] hydrated repeaters (bind-less only)');
  }

  function boot(){
    run();
    setTimeout(run, 200);
    setTimeout(run, 800);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
  else boot();

})();
/* FS_REPEAT_FALLBACK_END */


/* FS_P2_4_DATAIF_START
  Deterministic conditional rendering:
  - data-if="flags.x" where flags.x is:
      - boolean (false => hide)
      - object { enabled:false } => hide
  - missing/null => visible (default, no lead loss)
  - writes: hidden + data-fs-hidden-reason="if:false"
  - idempotent; never unhides anything hidden for other reasons
*/
function fsResolveDotPath(obj, path) {
  if (!obj || !path) return undefined;
  const parts = String(path).split(".").map(p => p.trim()).filter(Boolean);
  let cur = obj;
  for (const k of parts) {
    if (cur == null) return undefined;
    cur = cur[k];
  }
  return cur;
}
function fsEvalFlagEnabled(v) {
  if (v === false) return false;
  if (v && typeof v === "object" && v.enabled === false) return false;
  return true; // includes undefined/null/true/objects without enabled=false
}
function fsIsEnabledFromDataIf(expr, rootData) {
  const p = (expr || "").trim();
  if (!p) return true;
  const v = fsResolveDotPath(rootData, p);
  return fsEvalFlagEnabled(v);
}
function fsApplyDataIf(root, rootData) {
  try {
    const scope = root || document;
    const nodes = scope.querySelectorAll ? scope.querySelectorAll("[data-if]") : [];
    nodes.forEach(el => {
      const expr = el.getAttribute("data-if");
      const enabled = fsIsEnabledFromDataIf(expr, rootData);

      if (!enabled) {
        el.hidden = true;
        el.setAttribute("data-fs-hidden-reason", "if:false");
        return;
      }

      // only unhide if we previously hid it via if:false
      if (el.hidden && el.getAttribute("data-fs-hidden-reason") === "if:false") {
        el.hidden = false;
        el.removeAttribute("data-fs-hidden-reason");
      }
    });
  } catch (e) {
    if (window && window.FLOWSIGHT_DEBUG) console.warn("[FS_P2_4] applyDataIf failed", e);
  }
}
/* FS_P2_4_DATAIF_END */

/* FS_P2_3_AUTOHIDE_START: auto-hide empty sections + sanitize slot artifacts (debug-safe) */
(function () {
  var DEBUG = !!window.FLOWSIGHT_DEBUG;

  function warn() {
    if (!DEBUG) return;
    try { console.warn.apply(console, arguments); } catch (e) {}
  }

  function qsa(sel, root) {
    try { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }
    catch (e) { return []; }
  }

  function isRenderableTag(n) {
    if (!n || n.nodeType !== 1) return false;
    var t = n.tagName;
    return t !== "SCRIPT" && t !== "STYLE" && t !== "TEMPLATE" && t !== "NOSCRIPT";
  }

  // --- A) sanitize stray "[object Object]" artifacts (always sanitize, log only in debug)
  function fsSanitizeObjectArtifacts() {
    try {
      var hits = 0;
      var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
      var n;
      while (n = walker.nextNode()) {
        var t = (n.textContent || "").trim();
        if (t === "[object Object]" || t === "object Object") {
          hits++;
          var p = n.parentElement;
          if (p) {
            n.textContent = "";
            var info = p.tagName +
              (p.id ? ("#" + p.id) : "") +
              (p.className ? ("." + String(p.className).split(" ").join(".")) : "");
            warn("[Flowsight][P2.3] sanitized object artifact in", info);
          }
        }
      }
      if (hits && DEBUG) warn("[Flowsight][P2.3] total sanitized object artifacts:", hits);
    } catch (e) {}
  }

  // --- B) auto-hide empty sections (contract ids)
  var AUTOHIDE_IDS = ["services","process","areas","trust-badges","reviews","cases","certs","faq"];

  // IMPORTANT: do NOT rely on computed styles, otherwise hidden sections can never be unhidden.
  function countRenderableChildren(el) {
    if (!el) return 0;
    var kids = el.children ? Array.prototype.slice.call(el.children) : [];
    var c = 0;
    kids.forEach(function (k) {
      if (!isRenderableTag(k)) return;
      if (k.hasAttribute && (k.hasAttribute("data-repeat-template") || k.hasAttribute("data-template"))) return;
      if (k.hasAttribute && k.hasAttribute("hidden")) return;
      c++;
    });
    return c;
  }

  function sectionLooksEmpty(sec) {
    if (!sec) return false;

    // If section contains repeaters, use them as primary signal.
    var repeaters = qsa("[data-repeat],[data-repeater],[data-repeat-list],[data-repeat-parent]", sec);
    if (repeaters.length) {
      var rendered = 0;
      repeaters.forEach(function (r) { rendered += countRenderableChildren(r); });
      // If hydrated and we have items -> not empty.
      if (rendered > 0) return false;
      // If not hydrated yet, do NOT immediately mark empty; fall through to heuristic below.
    }

    // Keep sections that have media/forms even if text is short
    var hasMedia = qsa("img,iframe,video,svg,canvas,form,input,textarea,button", sec).length > 0;
    if (hasMedia) return false;

    var text = (sec.innerText || "").trim();
    if (!text || text.length < 8) return true;

    return false;
  }

  function fsAutoHideEmptySections() {
    try {
      AUTOHIDE_IDS.forEach(function (id) {
        var sec = document.getElementById(id);
        if (!sec) return;

        // Don’t fight explicit author intent
        if (sec.hasAttribute("data-fs-keep")) return;

        var empty = sectionLooksEmpty(sec);

        if (empty) {
          // hide only if state changes (dedupe logs)
          if (sec.getAttribute("data-fs-hidden-reason") !== "empty") {
            sec.setAttribute("hidden", "");
            sec.setAttribute("data-fs-hidden-reason", "empty");
            warn("[Flowsight][P2.3] auto-hide empty section:", "#" + id);
          }
        } else {
          // unhide if we previously hid it
          if (sec.getAttribute("data-fs-hidden-reason") === "empty") {
            if (!(sec.getAttribute && sec.getAttribute("data-fs-hidden-reason") === "if:false")) { sec.removeAttribute("hidden"); }
            sec.removeAttribute("data-fs-hidden-reason");
            warn("[Flowsight][P2.3] unhide section (now has content):", "#" + id);
          }
        }
      });
    } catch (e) {}
  }

  function runPass() {
    fsSanitizeObjectArtifacts();
    fsAutoHideEmptySections();
  }

  // Run after boot/hydration (a few retries, deterministic)
  function schedule() {
    [50, 250, 800, 1500].forEach(function (ms) { setTimeout(runPass, ms); });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", schedule);
  } else {
    schedule();
  }
  window.addEventListener("load", schedule);
})();
/* FS_P2_3_AUTOHIDE_END */








