# 02_DATA_MODEL_AND_SLOTS.md
Version: 1.0 (2026-01-30)

## 1. Grundsatz
- HTML enthält Slots und Templates
- Content kommt ausschließlich aus `customer.json`
- Pfade sind dot-notation (z. B. `hero.headline`)

## 2. Unterstützte Binding-Attribute (Runtime)
### 2.1 Text/HTML Slots (Root)
- `data-slot="path.to.value"`
  - setzt `textContent` (sicher)
  - optional `data-slot-mode="html"` (wenn ausdrücklich erlaubt)

### 2.2 Href Slots (Tel/Links)
- `data-slot-href="path.to.value"`
- optional: `data-href-prefix="tel:" | "mailto:" | "https://"`
- Runtime setzt `href = prefix + value`

### 2.3 Image Slots
- `data-slot-image="path.to.url"`
  - für `<img>`: setzt `src`
  - für `<a>`/`<div>`: setzt `style.backgroundImage` (optional, wenn aktiv)

### 2.4 Repeater (Arrays)
Host:
- `data-repeat="path.to.array"`

Template in Host (genau 1 Template pro Host):
- `data-template=""`

Bindings innerhalb Template:
- `data-bind="field"` (relativ zum Array-Item)
- `data-bind="nested.field"` (relativ)

### 2.5 Map Embed
- `data-map-embed="contact.map.embed_url"`
Runtime erstellt `<iframe>`.

### 2.6 CTA Routing
- `data-cta="emergency" | "normal" | "review"`
Runtime setzt Text + href (nach Rules in `core.js`).

## 3. Minimaler Datensatz (v1)
Diese Felder sind im v1-System “Pflicht” (Design/Runtime setzt voraus):
- `business.name`
- `business.region_label`
- `business.brand.logo.src`
- `hero.headline`
- `hero.subline`
- `hero.trust_badges[]`
- `services.items[]`
- `trust.reviews.headline`
- `trust.reviews.items[]`
- `contact.form.headline`
- `contact.phones.emergency.display` + `.e164`
- `contact.phones.normal.display` + `.e164`
- `contact.address.street`
- `contact.opening_hours.label`
- `contact.map.embed_url`
- `links.google_review`

## 4. Regeln: Slots nur wenn Feld existiert
Wenn ein Feld nicht im Schema/Dataset existiert:
- Kein `data-slot` setzen
- Inhalt statisch in Webflow lassen (bis Phase 3 Schema-Erweiterung)
