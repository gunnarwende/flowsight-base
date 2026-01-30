# 04_CORE_RUNTIME_RULES.md
Version: 1.0 (2026-01-30)

## 1. Runtime-Aufgaben (core.js)
1) Customer JSON laden (URL via `window.FLOWSIGHT_CUSTOMER_URL`)
2) Slots binden:
   - Text (`data-slot`)
   - href (`data-slot-href` + `data-href-prefix`)
   - images (`data-slot-image`)
3) Repeaters rendern:
   - Host `data-repeat`
   - Template `data-template`
   - Bindings `data-bind`
4) CTAs routen:
   - `data-cta="emergency|normal|review"`
5) Map Embed:
   - `data-map-embed`
6) Hooks (später):
   - Chat: `window.FlowSightChat.init(...)`
   - Voice: `window.FlowSightVoice.init(...)`

## 2. Sicherheits-/Stabilitätsregeln
- Slots nutzen standardmäßig `textContent` (kein HTML injection)
- Nur wenn explizit `data-slot-mode="html"` gesetzt ist, darf HTML gesetzt werden
- Fehlende Pfade: Element bleibt unverändert (keine Exceptions)
- Repeater: entfernt alle nicht-Template-Children im Host, bevor gerendert wird

## 3. Performance-Regeln
- 1x JSON fetch
- 1x DOM pass pro Binding-Typ
- Repeater rendert via DocumentFragment
- Keine Layout-Thrashing Loops

## 4. Debug
- `window.FLOWSIGHT_DEBUG = true` aktiviert Console-Logs
- Fehler werden als `console.warn` ausgegeben, Seite bleibt funktionsfähig

## 5. CTA-Routing Policy (v1)
- emergency:
  - href: `tel:` + `contact.phones.emergency.e164`
  - label: `contact.phones.emergency.display` oder `cta.labels.emergency`
- normal:
  - href: `tel:` + `contact.phones.normal.e164`
  - label: `contact.phones.normal.display` oder `cta.labels.normal`
- review:
  - href: `links.google_review`
  - label: `cta.labels.review` oder Default “Bewertung schreiben”
