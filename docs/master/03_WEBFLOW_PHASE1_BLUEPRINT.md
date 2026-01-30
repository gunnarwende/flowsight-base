# 03_WEBFLOW_PHASE1_BLUEPRINT.md
Version: 1.1 (2026-01-30)
Ziel: Webflow = Struktur + Klassen + Data-Attribute. Keine Optik im Designer.

## A. Endstruktur (Navigator) – Minimal Set (verbindlich)
Body
└─ Navbar (class: navbar w-nav)
   └─ Navbar Container (class: container-navbar w-container)
      ├─ Brand Link (class: w-nav-brand) [data-slot-image="business.brand.logo.src"]
      ├─ Navigation (class: nav-links w-nav-menu)
      │  ├─ Nav Link (optional)
      │  ├─ Nav Link (optional)
      │  └─ Nav Link (optional)
      └─ Menu Button (class: nav-menu-button w-nav-button)
         └─ Menu Icon (class: w-icon-nav-menu)

Main
├─ Hero Section (class: section-hero)
│  └─ Hero Container (class: container-hero w-container)
│     ├─ Hero Headline (class: hero-headline) [data-slot="hero.headline"]
│     ├─ Hero Subline (class: hero-subline) [data-slot="hero.subline"]
│     ├─ CTA Emergency (class: hero-cta hero-cta--emergency w-button) [data-cta="emergency"]
│     └─ CTA Normal (class: hero-cta hero-cta--normal w-button) [data-cta="normal"]
│
├─ Services Section (class: section-services)
│  └─ Services Container (class: container-services w-container)
│     └─ Services Grid (class: services-grid) [data-repeat="services.items"]
│        └─ Service Card Template (class: service-card) [data-template=""]
│           ├─ Service Title (class: service-card-title) [data-bind="title"]
│           ├─ Service Text (class: service-card-description) [data-bind="description"]
│           └─ Service CTA (class: service-card-cta w-button) [data-cta="normal"]
│
├─ Trust Badges Section (class: section-trust-badges)
│  └─ Trust Badges Container (class: container-trust-badges w-container)
│     └─ Trust Badges Grid (class: trust-badges) [data-repeat="hero.trust_badges"]
│        └─ Trust Badge Template (class: trust-badge) [data-template=""]
│           └─ Trust Badge Label (class: trust-badge-label) [data-bind="label"]
│
├─ Reviews Section (class: section-reviews)
│  └─ Reviews Container (class: container-reviews w-container)
│     ├─ Reviews Headline (class: reviews-headline) [data-slot="trust.reviews.headline"]
│     ├─ Reviews Grid (class: reviews-grid) [data-repeat="trust.reviews.items"]
│     │  └─ Review Card Template (class: review-card) [data-template=""]
│     │     ├─ Review Author (class: review-author) [data-bind="author"]
│     │     └─ Review Text (class: review-text) [data-bind="text"]
│     └─ Reviews CTA (class: reviews-cta w-button) [data-cta="review"]
│
├─ Contact Section (id: kontakt, class: section-contact)
│  └─ Contact Container (class: container-contact w-container)
│     ├─ Contact Headline (class: contact-headline) [data-slot="contact.form.headline"]
│     ├─ Phone Emergency (class: contact-phone contact-phone--emergency)
│     │   [data-slot="contact.phones.emergency.display"]
│     │   [data-slot-href="contact.phones.emergency.e164"]
│     │   [data-href-prefix="tel:"]
│     ├─ Phone Normal (class: contact-phone contact-phone--normal)
│     │   [data-slot="contact.phones.normal.display"]
│     │   [data-slot-href="contact.phones.normal.e164"]
│     │   [data-href-prefix="tel:"]
│     ├─ Contact Address (class: contact-address) [data-slot="contact.address.street"]
│     ├─ Map Embed (class: contact-map w-container) [data-map-embed="contact.map.embed_url"]
│     └─ Contact Form Wrapper (class: contact-form w-form)
│        ├─ Form (Webflow Form Element)
│        ├─ Success Message (w-form-done)
│        └─ Error Message (w-form-fail)
│
└─ Footer Section (class: section-footer)
   └─ Footer Container (class: container-footer w-container)
      ├─ Footer Business (class: footer-business) [data-slot="business.name"]
      ├─ Footer Street (class: footer-street) [data-slot="contact.address.street"]
      ├─ Footer Hours Label (class: footer-hours-label) [data-slot="contact.opening_hours.label"]
      └─ Footer Legal Link (class: footer-legal) (statisch, bis Phase 3)

## B. Webflow Regeln (hart)
- Keine Styles im Designer setzen
- Nur Klassen und Data-Attribute wie oben
- Keine zusätzlichen Wrapper ohne Systemgrund


---

## F. Webflow AI Prompt (Phase 1) – 1:1 Copy/Paste (verbindlich)

**Ziel:** Webflow AI soll NUR die Struktur erzeugen (Sections + Elemente), inkl. Klassen + Custom Attributes. **Kein Styling** (keine Farben, keine Fonts, keine Spacing-Overrides), **keine Inline-Styles**, **keine Combo-Classes zur Optik**.

**Webflow AI Prompt (kopieren):**

```text
Du erstellst eine EINSEITIGE Landingpage-Struktur (nur HTML-Struktur in Webflow), ohne Design-Styling.
Regeln:
- Setze KEINE Margins/Paddings/Typo/Colors im Designer. Keine visuellen Overrides.
- Keine Inline-Styles.
- Keine Combo-Classes für Optik (Combo nur für Zustände, hier nicht nötig).
- Erzeuge die Struktur exakt wie unten (Navigator-Baum) und setze die Klassen exakt wie angegeben.
- Setze Custom Attributes exakt wie angegeben (Name + Value).
- Inhalte dürfen Platzhalter sein (Heading, Lorem, Button Text).
- Buttons/Links bekommen href="#" (Runtime überschreibt später via core.js).
- Repeater: Ein Wrapper mit data-repeat="..." und darin genau ein Template-Item mit data-template="".
- Template-Item enthält data-bind Felder exakt wie angegeben.

Erstelle folgende Struktur:

1) Navbar
Element: Navbar Wrapper (Nav)
Class: "navbar w-nav"
Inside: Div Container
Class: "container-navbar w-container"
Children:
- Brand Link (Link)
  Class: "w-nav-brand"
  Custom Attribute: data-slot-image="business.brand.logo.src"
- Nav Menu (Nav)
  Class: "nav-links w-nav-menu"
  Children: 3 Links (optional Platzhalter)
  Class je Link: "nav-link w-nav-link"
- Menu Button (Div)
  Class: "nav-menu-button w-nav-button"
  Child: Icon Div
  Class: "w-icon-nav-menu"

2) Hero Section
Element: Section
Class: "section-hero"
Inside: Div Container
Class: "container-hero w-container"
Children:
- H1 Headline
  Class: "hero-headline"
  Custom Attribute: data-slot="hero.headline"
- Paragraph Subline
  Class: "hero-subline"
  Custom Attribute: data-slot="hero.subline"
- Button Emergency
  Class: "hero-cta hero-cta--emergency w-button"
  Custom Attribute: data-cta="emergency"
- Button Normal
  Class: "hero-cta hero-cta--normal w-button"
  Custom Attribute: data-cta="normal"

3) Services Section
Element: Section
Class: "section-services"
Inside: Div Container
Class: "container-services w-container"
Children:
- Services Grid Wrapper (Div)
  Class: "services-grid"
  Custom Attribute: data-repeat="services.items"
  Inside (Template Item):
  - Service Card (Div)
    Class: "service-card"
    Custom Attribute: data-template=""
    Children:
    - Title (H3 oder H2)
      Class: "service-card-title"
      Custom Attribute: data-bind="title"
    - Description (Paragraph)
      Class: "service-card-description"
      Custom Attribute: data-bind="description"
    - CTA Link/Button
      Class: "service-card-cta w-button"
      Custom Attribute: data-cta="normal"

4) Trust Badges Section
Element: Section
Class: "section-trust-badges"
Inside: Div Container
Class: "container-trust-badges w-container"
Children:
- Badges Wrapper (Div)
  Class: "trust-badges"
  Custom Attribute: data-repeat="hero.trust_badges"
  Inside (Template Item):
  - Badge (Div)
    Class: "trust-badge"
    Custom Attribute: data-template=""
    Children:
    - Badge Label (Paragraph)
      Class: "trust-badge-label"
      Custom Attribute: data-bind="label"

5) Reviews Section
Element: Section
Class: "section-reviews"
Inside: Div Container
Class: "container-reviews w-container"
Children:
- Reviews Headline (H2)
  Class: "reviews-headline"
  Custom Attribute: data-slot="trust.reviews.headline"
- Reviews Grid Wrapper (Div)
  Class: "reviews-grid"
  Custom Attribute: data-repeat="trust.reviews.items"
  Inside (Template Item):
  - Review Card (Div)
    Class: "review-card"
    Custom Attribute: data-template=""
    Children:
    - Author (Paragraph)
      Class: "review-author"
      Custom Attribute: data-bind="author"
    - Text (Paragraph)
      Class: "review-text"
      Custom Attribute: data-bind="text"
- Review CTA (Link/Button) (unterhalb des Grids, als Sibling)
  Class: "reviews-cta w-button"
  Custom Attribute: data-cta="review"

6) Contact Section
Element: Section
Class: "section-contact"
ID: "kontakt"
Inside: Div Container
Class: "container-contact w-container"
Children:
- Contact Headline (H2)
  Class: "contact-headline"
  Custom Attribute: data-slot="contact.form.headline"
- Phone Emergency (Link oder Paragraph)
  Class: "contact-phone contact-phone--emergency"
  Custom Attributes:
    data-slot="contact.phones.emergency.display"
    data-slot-href="contact.phones.emergency.e164"
    data-href-prefix="tel:"
- Phone Normal (Link oder Paragraph)
  Class: "contact-phone contact-phone--normal"
  Custom Attributes:
    data-slot="contact.phones.normal.display"
    data-slot-href="contact.phones.normal.e164"
    data-href-prefix="tel:"
- Contact Address (Paragraph)
  Class: "contact-address"
  Custom Attribute: data-slot="contact.address.street"
- Map Embed (Div)
  Class: "contact-map w-container"
  Custom Attribute: data-map-embed="contact.map.embed_url"
- Contact Form Wrapper (Form Block)
  Class: "contact-form w-form"
  (Form kann Webflow Standard bleiben; keine Custom Attributes nötig.)

7) Footer Section
Element: Section
Class: "section-footer"
Inside: Div Container
Class: "container-footer w-container"
Children:
- Business Name (Paragraph)
  Class: "footer-business"
  Custom Attribute: data-slot="business.name"
- Street (Paragraph)
  Class: "footer-street"
  Custom Attribute: data-slot="contact.address.street"
- Opening Hours Label (Paragraph)
  Class: "footer-hours-label"
  Custom Attribute: data-slot="contact.opening_hours.label"
- Legal Link (Link) (statisch, kein data-slot)
  Class: "footer-legal w-inline-block"
  Text: "Impressum / Datenschutz"
  Link: "#"
```

**Wichtig:** Wenn Webflow AI Abweichungen einbaut (zusätzliche Wrapper, andere Klassennamen), ist das akzeptabel als Rohbau – wir korrigieren danach per Validation unten.

---

## G. AI Output Validation (Soll-Kontrolle) – ohne Diskussion

Nach dem AI-Run prüfst du pro Section **nur diese drei Dinge**:

1) **Klassen exakt**
- Stimmen alle Klassenstrings exakt (inkl. `w-*` Klassen, falls vorhanden)?

2) **Custom Attributes exakt**
- data-slot / data-slot-image / data-slot-href / data-href-prefix / data-repeat / data-template / data-bind / data-map-embed

3) **Repeater korrekt**
- Wrapper hat `data-repeat="…"`
- Template Item hat `data-template=""`
- Template enthält `data-bind="…"` Felder
- CTA ist **außerhalb** des Repeater-Wrapper (bei Reviews)

Wenn eines davon nicht stimmt: **Fix nach Abschnitt H**.

---

## H. Fallback: Minimal Manual Fixes (wenn AI “kreativ” war)

**Regel:** Wir ändern nur Klassen + Attributes, nicht das Layout “anfassen”.

### H1) Repeater-Fix (Services / Badges / Reviews)
Soll:
- Wrapper: `data-repeat="…"`
- Child (ein Element): `data-template=""`
- Inside: `data-bind="…"`

Fix:
- Wenn AI den Wrapper falsch gesetzt hat: setze `data-repeat` auf den **Grid-Wrapper** (das Element, das mehrere Cards enthalten soll).
- Wenn AI mehrere Templates erzeugt hat: **lasse 1 Template übrig**, lösche den Rest.

### H2) Reviews-CTA Position
Soll:
- `Review CTA` ist **Sibling** von `Reviews Grid`, nicht Kind davon.

Fix:
- Ziehe `reviews-cta` im Navigator **aus** `reviews-grid` heraus, direkt unter `reviews-grid` (im gleichen Container).

### H3) Contact Map Embed
Soll:
- Element: `Map Embed` (Div)
- Attribute: `data-map-embed="contact.map.embed_url"`

Fix:
- Wenn AI statt Div ein Embed erzeugt: ersetze durch Div und setze das Attribut auf das Div.

### H4) Phone Links
Soll:
- `data-slot` (Display) + `data-slot-href` (E164) + `data-href-prefix="tel:"`

Fix:
- Wenn AI echte hrefs gesetzt hat: lässt du sie drin, ist egal – core.js überschreibt zur Laufzeit.
- Wichtig ist nur: die drei Attributes sind korrekt.

---

## I. Phase-1 Definition of Done (AI oder manuell identisch)

Phase 1 ist fertig, wenn:
- Jede Section existiert
- Alle Klassen + Attributes exakt sind
- Repeater/Templates korrekt sind
- Keine visuellen Overrides in Webflow gesetzt sind
