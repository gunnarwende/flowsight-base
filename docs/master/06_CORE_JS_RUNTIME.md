# 06_CORE_JS_RUNTIME.md
Version: 1.2 (2026-02-01)

## 1) Zweck
`core/core.js` ist die Runtime-Schicht, die Webflow-HTML in ein skalierbares Template verwandelt:
- lädt `customer.json`
- bindet Slots (`data-slot*`)
- rendert Repeaters (`data-repeat`/`data-template`/`data-bind`)
- mappt Header-Navigation (`data-nav`)
- routet CTAs (`data-cta`)
- verarbeitet `data-if`

## 2) Garantien (Contract)
- Fail-safe: fehlende Daten dürfen die Seite nicht crashen (nur `console.warn`)
- 1x JSON Fetch pro Page Load
- DOM-Operationen in batches (DocumentFragment)
- keine Inline-Style-Wildwuchs außer dort, wo es Contract ist (Image background)

## 3) Supported Custom Attributes
Siehe `02_DATA_MODEL_AND_SLOTS.md` (normativ).

## 4) Reihenfolge der Ausführung (v1)
1) JSON laden
2) `data-if` anwenden
3) Repeaters rendern (Templates einfügen)
4) Slots binden (Text/Href/Image)
5) CTAs routen
6) Nav mapping
7) Map embed

## 5) Smooth Scroll / Navigation Performance
- Default: Browser-native anchor navigation (kein JS-smooth-scroll)
- Wenn JS smooth scroll verwendet wird: muss `requestAnimationFrame` nutzen und darf nicht blockieren.

## 6) Debug
- `window.FLOWSIGHT_DEBUG=true` → logs aktiv
- Logs müssen gruppiert und knapp sein (kein spam)

## 7) Script/Tool Kompatibilität (wichtig)
PowerShell Tools müssen auf Windows PowerShell 5.1 laufen:
- **kein** `ConvertFrom-Json -Depth`
- keine PS7-only Syntax
