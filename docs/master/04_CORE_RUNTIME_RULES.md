# 04_CORE_RUNTIME_RULES.md
Version: 1.2 (2026-02-01)

## 1) Runtime-Aufgaben (`core/core.js`)
1) Customer JSON laden (URL via `window.FLOWSIGHT_CUSTOMER_URL`)
2) Conditionals:
   - `data-if`
3) Slots binden:
   - Text (`data-slot`)
   - href (`data-slot-href` + `data-href-prefix`)
   - images (`data-slot-image`)
4) Repeaters rendern:
   - Host `data-repeat`
   - Template `data-template`
   - Fields `data-bind`
5) Navigation:
   - Links mit `data-nav` werden auf Contract-IDs gemappt
6) CTAs routen:
   - `data-cta="emergency|normal|review"`
7) Map Embed:
   - `data-map-embed`

## 2) Sicherheits-/Stabilitätsregeln
- Slots nutzen standardmäßig `textContent` (kein HTML injection)
- Nur wenn explizit `data-slot-mode="html"` gesetzt ist, darf HTML gesetzt werden
- Fehlende Pfade: Element bleibt unverändert (keine Exceptions)
- Repeater: entfernt alle nicht-Template-Children im Host, bevor gerendert wird

## 3) Performance-Regeln
- 1x JSON fetch
- 1x DOM pass pro Binding-Typ
- Repeater rendert via DocumentFragment
- Keine Layout-Thrashing Loops

## 4) Debug
- `window.FLOWSIGHT_DEBUG = true` aktiviert Console-Logs
- Fehler als `console.warn`, Seite bleibt funktionsfähig

## 5) CTA-Routing Policy (v1)
- emergency:
  - href: `tel:` + `contact.phones.emergency.e164`
  - label: `contact.phones.emergency.display` oder `cta.labels.emergency`
- normal:
  - href: `tel:` + `contact.phones.normal.e164`
  - label: `contact.phones.normal.display` oder `cta.labels.normal`
- review:
  - href: `links.google_review`
  - label: `cta.labels.review` oder Default „Bewertung schreiben“

## 6) Nav-Mapping Policy (v1)
- `data-nav="start"`   → `#hero`
- `data-nav="services"` → `#services`
- `data-nav="process"`  → `#process`
- `data-nav="contact"`  → `#contact`
