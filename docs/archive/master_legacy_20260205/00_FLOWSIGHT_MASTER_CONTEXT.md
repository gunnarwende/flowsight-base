# 00_FLOWSIGHT_MASTER_CONTEXT.md
Version: 1.2 (2026-02-01)
Status: verbindlich (oberste Instanz / Single Source of Truth)

## 1) Ziel (nicht verhandelbar)
Wir bauen ein **Swiss-High-End Webflow-Template** für lokale SHK-Betriebe (**Sanitär / Heizung / Spenglerei / Service**).

Kernziel: **kein Lead darf verloren gehen**.
- klare Primär-CTAs (Notfall / Kontakt)
- solide Trust-Architektur (Bewertungen, Referenzen)
- sauberer, konsistenter Auftritt (ruhig, technisch, premium)

## 2) Systemprinzip (fix)
- **Webflow** liefert Struktur/HTML + Navigator-Namen + Custom Attributes.
- Optik + Runtime kommt aus dem Repo **flowsight-base** über **jsDelivr per Commit-SHA**.
- Kundenspezifik ist primär **`customers/<customer>/customer.json`**.

Wichtig: Das Template ist ein **skalierbarer Baukasten**. Alles, was systemisch ist, muss in Repo/Specs landen (kein Webflow-„Fummeln“).

## 3) Current Scope (jetzt)
Wir halten Fokus auf:
1) **Struktur/Contract** im Webflow-Template (IDs, Navigator-Namen, Templates, Bindings, Form-Felder).
2) **Automatisierte Verifikation** via ZIP-Audit (ZIP-first).
3) **High-End Design-System** in `core/core.css` als **einziger** Override-Block am Dateiende.

Nicht im Scope, bis explizit beauftragt:
- Chat-/Voice-/Tracking-Add-ons (nur als technische Hooks, keine Produktdiskussion)

## 4) Hard Rules (No-Drift)
### 4.1 CSS – exakt ein finaler Override-Block
In `core/core.css` wird genau **ein** finaler Override-Block gepflegt (am Dateiende):

```css
/* FS_ACTIVE_THEME_START */
...
/* FS_ACTIVE_THEME_END */
```

- Keine zweiten Theme-/Fade-Blöcke.
- Alles Systemische (Tokens/Canvas/Nav-Glass/Fades/Container/Shadow-Radii) lebt **nur** dort.

### 4.2 Webflow – „dumm“, keine Optik
- Keine manuellen Typo-/Spacing-Overrides in Webflow.
- Keine Inline-Styles.
- Nur: **saubere Struktur**, **Klassen**, **IDs**, **Custom Attributes**.

### 4.3 Contract vor Design
Bevor CSS/Design-Finetuning weitergeht, müssen ZIP-Checks **PASS** sein:
- Sections vorhanden
- Repeater korrekt (data-repeat + data-template + data-bind)
- Nav Keys vorhanden
- Contact-Form korrekt (inkl. message = textarea)

## 5) Verbindlicher Seiten-Contract (IDs)
Diese Sections müssen als `section[id]` existieren:
- `hero`
- `services`
- `process`
- `areas`
- `trust-badges`
- `reviews`
- `cases`
- `certs`
- `faq`
- `contact`
- `footer`

Hinweis: Der Header ist als Webflow-Navbar im `body` – **ohne** eigene Section-ID.

## 6) Navigation Contract
Header-Navigation hat genau **4** Links, stabil über `data-nav` Keys:
- `start`  → `#hero`
- `services` → `#services`
- `process` → `#process`
- `contact` → `#contact`

Labels sind deutsch (Start / Leistungen / Ablauf / Kontakt). Keys bleiben englisch, weil stabil.

## 7) Standard-Loop (operativ)
1) Webflow → Export ZIP nach `C:\flowsight-base\sanitar-template.webflow.zip`.
2) ZIP-first Audit laufen lassen (Tools).
3) Erst wenn Contract/Bindings PASS sind: CSS/Design weiter.

## 8) Output-Disziplin (Chat-übergreifend)
- Wenn ein Tool fehlschlägt: **nur** Konsolenoutput + Name der betroffenen Navigator-Node.
- Anweisungen immer als: **Style → Settings (ID/Custom Attributes/Link/etc.)**.
- Keine Optionen, kein „vielleicht“.


## 9) Deployment Contract (jsDelivr)
Webflow bekommt pro Deploy eine **fixe Commit-SHA**.

Head:
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@<SHA>/core/core.css">
<script>
  window.FLOWSIGHT_CUSTOMER_URL="https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@<SHA>/customers/template-on/customer.json";
  window.FLOWSIGHT_DEBUG=true;
</script>
```

Footer:
```html
<script src="https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@<SHA>/core/core.js" defer></script>
```

## 10) PowerShell-Patch Standard
Jede Repo-Änderung wird immer als vollständiger PowerShell-Workflow geliefert:
- Backup
- Patch/Edit (robust, marker-basiert)
- git status → add → commit → push
- Ausgabe: **NEUE HEAD SHA** + **fertiger Head/Footer Code** (Copy/Paste)
