# 03_WEBFLOW_PHASE1_BLUEPRINT.md
Version: 1.2 (2026-02-01)

Ziel: Webflow-Template so aufbauen, dass es als **skalierbarer Contract** mit JSON-Bindings funktioniert.

## 1) Sections (IDs müssen exakt so heißen)
Es müssen genau diese Sections existieren:
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

## 2) Header (Navbar)
- Webflow: Nutze eine Navbar-Komponente.
- Keine eigene Section-ID.
- Navigation-Links (4 Stück), jeweils:
  - Link-Text deutsch (Start, Leistungen, Ablauf, Kontakt)
  - `href` in Webflow direkt setzen:
    - Start → `#hero`
    - Leistungen → `#services`
    - Ablauf → `#process`
    - Kontakt → `#contact`
  - Custom Attribute auf dem Link:
    - `data-nav="start" | "services" | "process" | "contact"`
- Logo:
  - `<img>` im Brand-Link
  - Custom Attribute am `<img>`:
    - `data-slot-image="business.brand.logo.src"`
  - Brand-Link `href` → `#hero`

## 3) Repeaters (Cards/Lists)
### 3.1 Services (`#services`)
Host-Element:
- `data-repeat="services.items"`
- enthält genau **eine** Template-Card mit `data-template=""`

In der Template-Card:
- Titel-Element: `data-bind="title"`
- Text-Element: `data-bind="text"`

### 3.2 Prozess (`#process`)
Host-Element:
- `data-repeat="process.items"`
- Template-Item: `data-template=""`

In Template:
- Titel: `data-bind="title"`
- Text: `data-bind="text"`

### 3.3 Einsatzgebiet (`#areas`)
Host-Element:
- `data-repeat="areas.items"`
- Template-Item: `data-template=""`

In Template:
- Titel: `data-bind="title"`

### 3.4 Referenzen (`#cases`)
Host-Element:
- `data-repeat="cases.items"`
- Template-Item: `data-template=""`

In Template:
- Titel: `data-bind="title"`
- Text: `data-bind="text"`

### 3.5 Zertifikate (`#certs`)
Host-Element:
- `data-repeat="certs.items"`
- Template-Item: `data-template=""`

In Template:
- Titel: `data-bind="title"`

### 3.6 FAQ (`#faq`)
Host-Element:
- `data-repeat="faq.items"`
- Template-Item: `data-template=""`

In Template:
- Titel: `data-bind="title"`
- Text: `data-bind="text"`

### 3.7 Reviews (`#reviews`)
- Headline kann Slot sein: `data-slot="trust.reviews.headline"`
- Repeater:
  - Host: `data-repeat="trust.reviews.items"`
  - Template: `data-template=""`
  - Author: `data-bind="author"`
  - Text: `data-bind="text"`

## 4) Contact (`#contact`)
### 4.1 Phone CTAs
- Notfall-CTA Button/Link:
  - `data-cta="emergency"`
- Normal-CTA Button/Link:
  - `data-cta="normal"`

### 4.2 Map
- Container für Map:
  - `data-map-embed="contact.map.embed_url"`

### 4.3 Contact Form
Form-Wrapper:
- `data-name="contact-form"`

Felder:
- name: `name`
- email: `email` (type email)
- phone: `phone` (type tel)
- message: `message` (**Textarea**, nicht Input)

Webflow Success/Fail Blöcke müssen vorhanden sein.

## 5) Footer (`#footer`)
- Legal Links müssen Links sein (nicht Plain Text):
  - Impressum: `data-slot-href="links.legal.impressum_url"` + `data-href-prefix=""`
  - Datenschutz: `data-slot-href="links.legal.privacy_url"` + `data-href-prefix=""`

## 6) Navigator-Namen (Empfehlung)
- Sections nummerieren: `01 Header`, `02 Hero`, `03 Leistungen`, `04 Ablauf`, `05 Einsatzgebiet`, `06 Vertrauen`, `07 Bewertungen`, `08 Referenzen`, `09 Zertifikate`, `10 FAQ`, `11 Kontakt`, `12 Fusszeile`
- Innerhalb einer Section: `01.1 ...`, `01.2 ...` etc.

Wichtig: Namen sind nur Orientierung. **Funktion** kommt ausschließlich über IDs + Custom Attributes.
