# 08_QA_DEBUG_CHECKLIST.md
Version: 1.2 (2026-02-01)

Ziel: Mit einem Webflow-Export-ZIP sicherstellen, dass Contract/Binds/IDs/Forms korrekt sind.

## A) ZIP-First Quick Audit (empfohlen)
1) ZIP in Repo-Root ablegen:
   - `C:\flowsight-base\sanitar-template.webflow.zip`
2) Audit laufen lassen:
   ```powershell
   cd C:\flowsight-base
   powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\handoff\19_zip_audit_runner.ps1 -Open
   ```
3) Erwartete Ergebnisse:
   - **Sections**: alle required IDs (`hero...footer`) vorhanden
   - **Header Nav Keys**: start/services/process/contact OK
   - **Form**: message textarea OK
   - **Repeaters**: jeder Host hat `data-repeat` + Template `data-template` + required `data-bind`

## B) Einzel-Checks (wenn Quick Audit failt)
### B1) Section Inventory
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\handoff\15_section_inventory.ps1
```
Erwartung: genau diese IDs:
`hero, services, process, areas, trust-badges, reviews, cases, certs, faq, contact, footer`

### B2) Verify Custom Attributes
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\handoff\17_verify_custom_attrs.ps1
```
Achtungspunkte:
- fehlendes `data-template` in einem Repeater
- fehlendes `data-bind="title"` / `data-bind="text"`

### B3) Full Bindings Audit
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\handoff\18_audit_bindings_full.ps1
```
Erwartung:
- keine Missing-Paths für Pflicht-Slots
- keine Duplicate IDs
- Navigation-Mapping vorhanden

## C) Live-Checks (nach Deploy)
- Header Links springen sofort an die richtige Section
- CTAs rufen `tel:` korrekt auf (Notfall/Normal)
- Repeaters rendern korrekt (keine doppelten Template-Cards)
- Fades: keine „Balken“, keine harten Kanten

## D) Debug Toggle
- in Webflow Head: `window.FLOWSIGHT_DEBUG=true;`
- zum Release: `false`
