# 00_FLOWSIGHT_MASTER_CONTEXT.md
Version: 1.0 (2026-01-30)
Status: verbindlich (oberste Instanz)

## 1. Ziel (nicht verhandelbar)
FlowSight macht Sanitär-/Spenglerbetriebe **24/7 erreichbar**, **fängt jeden Lead ab** und **erzeugt nach jedem Auftrag automatisch Google-Rezensionen**.

FlowSight ist **kein Website-Projekt**, sondern ein **Lead-Capture- und Lead-Conversion-System** für lokale Servicebetriebe (Start: Sanitär/Spengler 24/7).

Demo-Kunde: **Walter Leuthold – Sanitär & Spenglerei** (linker Zürichsee).  
Die bestehende Website dient **nur zur Kenntnisnahme**, nicht als Vorlage.

## 2. Systemarchitektur (4 Module)
1) Website – Conversion-Container (Mittel zum Zweck)  
2) Google Business Profile – Traffic + Social Proof  
3) Chat-Modul – Lead-Abfang bei Nicht-Anruf  
4) Voice-Agent – 24/7 Notfalltelefon & Qualifizierung

## 3. Technische Grundentscheidung (fix)
- Webflow = Struktur/HTML, Klassen, Data-Attribute
- Keine Fleißarbeit im Designer (keine tausend manuellen Overrides)
- Kein CMS-Gefummel
- **Baukasten-Ansatz**:
  - `core.css` = globales Design-System (für alle Kunden gleich)
  - `core.js`  = Runtime/Logik (Slots, Repeater, CTA-Routing, Hooks)
  - `customer.json` = **einzige** kundenspezifische Datei
  - `customer.v1.schema.json` = Validierung/Contract

## 4. No-Drift-Regeln (ab jetzt hart)
### 4.1 Webflow
- Keine Margins/Paddings manuell setzen
- Keine Typo-Overrides
- Keine Inline-Styles
- Keine “Optik”-Combo-Klassen (Combo nur für Zustände wie `is-active`)
- Nur: Klassen + Data-Attribute + saubere Struktur

### 4.2 Datenmodell
- Kein Slot/Path ohne Schema
- Keine “mal schnell”-Felder
- Schema-Änderungen nur als eigene Phase (Phase 3)

### 4.3 CSS/JS
- Keine kundenspezifischen CSS-Regeln
- Keine “quick fixes” ohne System-Entscheidung
- Runtime bleibt generisch: bindet nur Daten, entscheidet keine Kundensonderfälle

## 5. Arbeitsmodus (Kommunikationsvertrag)
- Kurz, präzise, reproduzierbar
- Immer Navigator-Namen nennen, wenn Webflow-Klicks nötig sind
- Keine unnötigen Erklärungen, keine Symbol-Icons
- Qualität vor Geschwindigkeit
- Wenn etwas unklar ist: Fix als **exakter Schritt** (wo klicken, was eintragen)

## 6. Phasenmodell
### Phase 1 – Struktur (Webflow)
- Sections/Wrapper/Container/Templates anlegen
- Klassen setzen
- Data-Attribute setzen
- Keine optischen Webflow-Overrides

### Phase 2 – Design-System (core.css)
- Tokens → Layout-Primitives → Components → Module-Skins
- Responsive ausschließlich per CSS
- Webflow bleibt “dumm”

### Phase 3 – Module & Datenmodell-Erweiterung
- optionale Module (Projects, Team, FAQ, Legal, …)
- `enabled: true/false` pro Modul im JSON
- Schema-Versionierung (v1 → v2)

### Phase 4 – Automation
- Chat, Voice, Review-Flow, Lead-Routing, Tracking

## 7. Global Definition of Done (DoD)
Eine Phase gilt nur als fertig, wenn:
- Austausch von `customer.json` ändert **nur Content**, nie Layout/Verhalten
- Keine JS-Fehler
- Performance: keine unnötigen Render-Blocker
- Niemand muss fragen “wo ist was definiert”
- Reproduzierbar für nächste Kundeninstanz
