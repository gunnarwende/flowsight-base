# FlowSight – Master Context (verbindlich)

## 1. Was FlowSight ist (nicht verhandelbar)

FlowSight ist **kein Website-Baukasten**, kein klassisches Webflow-Projekt und kein Agentur-Template.

FlowSight ist ein **produktisiertes Website-Runtime-System** für lokale Dienstleister (Start: Sanitär / Spengler 24/7), bestehend aus:

- einer **stabilen Runtime (HTML + core.js)**
- einem **strikten Design-System (core.css)**
- einem **klaren Datenmodell (customer.json + schema)**
- einer **AI- & Automation-fähigen Erweiterungsschicht** (Chat, Voice, Reviews)

Die Website ist **kein Einzelfall**, sondern eine **Instanz eines Systems**.

---

## 2. Grundprinzip (oberstes Gesetz)

> **Struktur ist statisch – Inhalte sind dynamisch – Verhalten ist systemisch.**

Konkret:

- **Webflow**
  - liefert **nur** HTML-Struktur, Klassen, Data-Attribute
  - enthält **keine Design-Entscheidungen**
  - enthält **keine Logik**
- **core.css**
  - steuert **100 % des Designs**
  - Tokens → Layout → Components → Module
- **core.js**
  - injiziert Daten
  - steuert Wiederholer, Slots, CTAs, Map, später Chat & Voice
- **customer.json**
  - ist die **einzige** kundenspezifische Quelle
  - kein Content darf hart im HTML „leben“

---

## 3. Zielgruppe & Scope (bewusst eingeschränkt)

### Aktiver Fokus (Phase 1–2)
- Sanitärbetriebe
- Spenglerbetriebe
- 24/7-Notdienst
- Schweiz (Start: Kanton Zürich)

### Bewusste Nicht-Ziele (vorerst)
- komplexe CMS-Sites
- individuelle Design-Wünsche pro Kunde
- Marketing-Spielereien
- SEO-Overengineering

FlowSight ist ein **80/20-Produkt**:
> schnell, performant, klar, konvertierend.

---

## 4. Arbeitsmodus (wie mit mir gearbeitet wird)

### Kommunikationsstil
- **kurz, präzise, technisch**
- keine Erklärungen ohne Mehrwert
- keine „warum“-Texte
- kein Marketing-Sprech
- keine Emojis, keine Icons, keine Checkmarks

### Erwartung an Antworten
- immer **konkret**
- immer **reproduzierbar**
- immer **systemisch gedacht**
- immer **drift-sicher**

Wenn eine Antwort:
- unklar ist
- Interpretationsspielraum lässt
- Webflow-Clicks nicht exakt benennt

→ sie ist **falsch**.

---

## 5. Tooling & Setup (fix)

### Arbeitsumgebung
- Webflow (Designer)
- GitHub (Single Repo)
- PowerShell / Terminal
- Cursor / VS Code
- CDN (jsDelivr oder äquivalent)

### Source of Truth
| Bereich | Wahrheit |
|------|---------|
| Struktur | Webflow HTML |
| Design | core.css |
| Logik | core.js |
| Content | customer.json |
| Regeln | diese Datei |

---

## 6. No-Drift-Regeln (absolut)

### Webflow
- keine Margins / Paddings manuell setzen
- keine Typo-Overrides
- keine Inline-Styles
- keine „Design-Kombi-Klassen“
- nur Klassen + Data-Attribute

### CSS
- keine Section-Sonderlösungen pro Kunde
- kein „quick fix“
- alles über Tokens & Primitives lösbar

### Daten
- keine neuen Felder „mal schnell“
- kein Slot ohne Schema-Definition
- Schema-Änderungen nur als Phase-3-Thema

---

## 7. Phasenmodell (verbindlich)

### Phase 0 – Architektur (abgeschlossen)
- Systemdenken
- Datenmodell
- Runtime-Logik

### Phase 1 – Struktur
- AI-Template oder manuell
- Navigator-Struktur
- Klassen & Data-Attribute
- kein Design

### Phase 2 – Design System
- core.css auf High-End-Niveau
- Tokens
- Layout-Primitives
- Components
- Responsive ausschließlich per CSS

### Phase 3 – Module & Erweiterung
- optionale Sections (Projects, Team, FAQ, Legal)
- Enable/Disable via JSON
- kein Strukturumbau

### Phase 4 – Automation
- Chatbot
- Voice Agent
- Review-Flows
- Lead-Routing

---

## 8. Definition of Done (global)

Eine Phase gilt **nur dann** als abgeschlossen, wenn:

- Austausch von `customer.json`:
  - ändert Inhalte
  - ändert niemals Layout oder Verhalten
- Website:
  - lädt schnell
  - funktioniert ohne JS-Fehler
  - sieht ohne Webflow-Styles korrekt aus
- Kein Mensch:
  - muss nachfragen „wo was definiert ist“

---

## 9. Erweiterbarkeit (von Anfang an vorgesehen)

FlowSight ist modular:

- jede Section ist ein Modul
- jedes Modul:
  - kann enabled / disabled werden
  - kann später erweitert werden
- neue Branchen (z. B. Elektriker, Physio):
  - kopieren System
  - tauschen Daten & Module
  - kein Re-Build

---

## 10. Konsequenz

Wenn etwas:
- schneller geht, aber Regeln bricht → nicht erlaubt
- schöner aussieht, aber System verletzt → nicht erlaubt
- individuell wirkt, aber Skalierung verhindert → nicht erlaubt

FlowSight gewinnt nicht durch Kreativität,
sondern durch Klarheit, Geschwindigkeit und Wiederholbarkeit.

---

Dieses Dokument ist die oberste Instanz.
Alle anderen Dateien müssen damit kompatibel sein.
