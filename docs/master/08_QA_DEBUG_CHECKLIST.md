# 08_QA_DEBUG_CHECKLIST.md
Version: 1.0 (2026-01-30)

## 1. Phase-1 QA (Webflow Struktur)
- Jede Section existiert im Navigator wie in `03_WEBFLOW_PHASE1_BLUEPRINT.md`
- Kein Element hat manuelle Typo/Margin/Padding Overrides
- Repeater-Hosts:
  - genau 1 Template (data-template) pro Host
  - Template liegt *innerhalb* des Hosts
- Phones:
  - Emergency/Normal haben je: data-slot, data-slot-href, data-href-prefix="tel:"
- Reviews CTA ist außerhalb des Reviews Grid (als Geschwister), nicht in Template

## 2. Runtime QA (core.js)
- `window.FLOWSIGHT_CUSTOMER_URL` ist gesetzt und lädt (Network 200)
- Keine Console Errors
- Repeater rendert: Service Cards/Reviews/Badges werden vervielfacht
- Slots binden: Headline/Subline/Footer etc. zeigen echte Werte
- CTA routing:
  - Emergency → tel:+41...
  - Normal → tel:+41...
  - Review → Google Review URL (target _blank)

## 3. Styling QA (core.css)
- Seite sieht ohne Webflow-Designer-Overrides korrekt aus
- Header sticky + lesbar
- Hero hat spacing + CTA Styling
- Grids brechen responsiv korrekt um
- Map hat iframe + rounded corners

## 4. Häufigste Fehler (Fix ohne Diskussion)
### A) Nichts ändert sich nach Publish
- Prüfen: core.css Link eingebunden?
- Prüfen: core.js Link eingebunden?
- Prüfen: Customer URL erreichbar?
- Cache: testweise Commit-SHA statt @main nutzen

### B) Repeater zeigt nur 1 Karte
- Template nicht im Host (data-template außerhalb)
- Host hat mehrere Templates
- data-repeat zeigt auf falschen Pfad

### C) Telefonlink klickt nicht
- Element ist <p> statt <a> (empfohlen: Link Block oder Text Link)
- data-slot-href fehlt oder e164 fehlt
- data-href-prefix fehlt

### D) Map leer
- data-map-embed steht auf falschem Element
- embed_url fehlt oder ist kein Google Maps Embed URL

## 5. Minimal Debug Toggle
In Footer-Code (nur temporär):
```
<script>window.FLOWSIGHT_DEBUG = true;</script>
```
