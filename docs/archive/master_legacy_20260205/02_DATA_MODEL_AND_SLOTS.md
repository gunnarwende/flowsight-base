# 02_DATA_MODEL_AND_SLOTS.md
Version: 1.2 (2026-02-01)

## 1) Grundsatz
- HTML enthält Slots und Templates
- Content kommt ausschließlich aus `customer.json`
- Pfade sind dot-notation, z. B. `hero.headline`

## 2) Unterstützte Binding-Attribute (Runtime)
### 2.1 Text-Slots (Root)
- `data-slot="path.to.value"`
  - setzt `textContent` (sicher)
  - optional `data-slot-mode="html"` (nur wenn ausdrücklich erlaubt)

### 2.2 Link/Href-Slots
- `data-slot-href="path.to.value"`
- optional `data-href-prefix="tel:" | "mailto:" | "https://" | ""`

### 2.3 Image-Slots
- `data-slot-image="path.to.url"`
  - für `<img>`: setzt `src`
  - für `<a>`/`<div>`: setzt `style.backgroundImage`

### 2.4 Conditional Rendering
- `data-if="path.to.boolean"`
  - `false` → Element wird entfernt oder versteckt (je nach core.js policy)

### 2.5 Navigation Mapping
- `data-nav="start|services|process|contact"`
  - Runtime kann Link-`href` auf die Contract-IDs setzen

### 2.6 Repeater (Arrays)
Host:
- `data-repeat="path.to.array"`

Template in Host (genau 1 Template pro Host):
- `data-template=""`

Bindings innerhalb Template:
- `data-bind="field"` (relativ zum Array-Item)
- `data-bind="nested.field"` (relativ)

### 2.7 Map Embed
- `data-map-embed="contact.map.embed_url"`
  - Runtime erstellt `<iframe>`.

### 2.8 CTA Routing
- `data-cta="emergency" | "normal" | "review"`
  - Runtime setzt Text + href nach Regeln in `04_CORE_RUNTIME_RULES.md`.

## 3) Minimaler Datensatz (v1)
Diese Felder sind im Template v1 funktional „Pflicht“:
- `business.name`
- `business.region_label`
- `business.brand.logo.src`
- `hero.headline`
- `hero.subline`
- `hero.trust_badges[]` (`label`)
- `services.items[]` (`title`, `text`)
- `process.items[]` (`title`, `text`)
- `areas.items[]` (`title`)
- `cases.items[]` (`title`, `text`)
- `certs.items[]` (`title`)
- `faq.items[]` (`title`, `text`)
- `trust.reviews.headline`
- `trust.reviews.items[]` (`author`, `text`)
- `contact.form.headline`
- `contact.phones.emergency.display` + `.e164`
- `contact.phones.normal.display` + `.e164`
- `contact.address.street`
- `contact.opening_hours.label`
- `contact.map.embed_url`
- `links.google_review`

## 4) Legal (Template-Standard)
Für Schweizer Templates sind Footer-Links Pflicht:
- `links.legal.impressum_url`
- `links.legal.privacy_url`

(Die Links können auf Webflow-Seiten oder externe URLs zeigen.)

## 5) Regel: Slots nur wenn Feld existiert
Wenn ein Feld nicht im Datensatz existiert:
- kein `data-slot*` setzen
- Inhalt statisch in Webflow lassen (oder Schema erweitern)
