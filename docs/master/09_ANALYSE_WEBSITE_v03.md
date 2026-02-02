# 09_ANALYSE_WEBSITE_v03.md
Version: 1.2 (2026-02-01)

Ziel: strukturierte Bestandsaufnahme mit minimaler Reibung.

## 1) Reihenfolge (immer)
1) **ZIP Audit** (Contract + Bindings)
2) **Live-Sichtprüfung** (High-End Optik + Performance)
3) erst dann: CSS/JS Änderungen

## 2) ZIP Audit (One-shot)
Voraussetzung: `sanitar-template.webflow.zip` liegt im Repo-Root `C:\flowsight-base`.

```powershell
cd C:\flowsight-base
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\handoff\19_zip_audit_runner.ps1 -Open
```

Was du bekommst:
- Konsole zeigt den Pfad zur entpackten ZIP (`.local_artifacts\_wf_zip_audit_<timestamp>`) und die Zusammenfassung.
- Falls `-Open` aktiv ist, öffnet sich der Report automatisch.

## 3) Wenn Quick Audit FAILt
```powershell
cd C:\flowsight-base
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\handoff\15_section_inventory.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\handoff\17_verify_custom_attrs.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\handoff\18_audit_bindings_full.ps1
```

Fixes passieren **nur in Webflow** (IDs/Custom Attributes/Field-Typen), danach ZIP neu exportieren.

## 4) Live-Sichtprüfung (nach Deploy)
- Header-Navigation springt sofort (kein 1s Delay) zu:
  - `#hero`, `#services`, `#process`, `#contact`
- Keine fehlenden Sections
- Repeaters rendern ohne doppelte Template-Cards
- Contact-Form: Nachricht ist Textarea

## 5) Designer-Freeze (was im Designer manuell gepflegt wird)
**Erlaubt/erwartet**:
- Section IDs (Contract)
- Repeaters: `data-repeat`, `data-template`, `data-bind`
- Slots/Links: `data-slot*`, `data-nav`, `data-cta`
- Form Field Typen (`email`, `tel`, `textarea`)
- Footer Legal Links (Impressum/Datenschutz) als echte Links

**Nicht im Designer pflegen**:
- Layout/Spacing/Colors/Shadows (kommt aus `core.css`)
