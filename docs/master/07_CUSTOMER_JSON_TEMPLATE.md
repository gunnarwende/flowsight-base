# 07_CUSTOMER_JSON_TEMPLATE.md
Version: 1.2 (2026-02-01)

Ziel: Referenzstruktur für `customers/<name>/customer.json`.

## 1) Template (JSON)
```json
{
  "business": {
    "name": "Muster Sanitär & Heizung AG",
    "region_label": "Kanton Zürich",
    "brand": {
      "logo": {
        "src": "https://example.com/logo.svg"
      }
    }
  },
  "hero": {
    "headline": "Sanitär, Heizung & Spenglerei – zuverlässig in Zürich",
    "subline": "24/7 Notfall, Reparaturen, Badumbau und Wartung."
  },
  "services": {
    "items": [
      { "title": "Sanitär", "text": "Reparaturen, Installationen, Badumbau." },
      { "title": "Heizung", "text": "Wartung, Austausch, Störungen." },
      { "title": "Spenglerei", "text": "Dachrinnen, Blecharbeiten, Abdichtungen." },
      { "title": "Service", "text": "Unterhalt, Entkalkung, Kleinreparaturen." }
    ]
  },
  "process": {
    "items": [
      { "title": "Kontakt", "text": "Anrufen oder Formular senden." },
      { "title": "Analyse", "text": "Kurze Klärung, Termin oder Notfall." },
      { "title": "Ausführung", "text": "Saubere Arbeit, klare Kommunikation." },
      { "title": "Abschluss", "text": "Dokumentation und Empfehlung." }
    ]
  },
  "areas": {
    "items": [
      { "title": "Zürich" },
      { "title": "Winterthur" },
      { "title": "Uster" }
    ]
  },
  "cases": {
    "items": [
      { "title": "Badumbau EFH", "text": "Vorher/Nachher – Komplettsanierung." },
      { "title": "Heizungsservice", "text": "Wartung + Störungsbehebung." }
    ]
  },
  "certs": {
    "items": [
      { "title": "Meisterbetrieb" },
      { "title": "Zertifizierte Partner" }
    ]
  },
  "faq": {
    "items": [
      { "title": "Wie schnell sind Sie vor Ort?", "text": "Je nach Lage – wir melden uns sofort mit ETA." },
      { "title": "Gibt es fixe Preise?", "text": "Transparente Offerte nach Kurzklärung." }
    ]
  },
  "trust": {
    "reviews": {
      "headline": "Kundenstimmen",
      "items": [
        { "author": "A. Muster", "text": "Schnell, sauber, fair." },
        { "author": "B. Beispiel", "text": "Top Kommunikation und Qualität." }
      ]
    }
  },
  "contact": {
    "phones": {
      "emergency": { "display": "Notfall: 044 000 00 00", "e164": "+41440000000" },
      "normal":    { "display": "Büro: 044 111 11 11",   "e164": "+41441111111" }
    },
    "address": {
      "street": "Musterstrasse 1, 8000 Zürich"
    },
    "opening_hours": {
      "label": "Mo–Fr 08:00–18:00, Notfall 24/7"
    },
    "map": {
      "embed_url": "https://www.google.com/maps/embed?..."
    },
    "form": {
      "headline": "Kontakt aufnehmen"
    }
  },
  "cta": {
    "labels": {
      "emergency": "Jetzt Notfall anrufen",
      "normal": "Jetzt anrufen",
      "review": "Bewertung schreiben"
    }
  },
  "links": {
    "google_review": "https://g.page/r/....",
    "legal": {
      "impressum_url": "/impressum",
      "privacy_url": "/datenschutz"
    }
  }
}
```

## 2) Naming Rules
- Arrays heißen immer `items`.
- Textfelder heißen immer `text` (nicht `description`).
- Telefonnummern: immer `display` + `e164`.

## 3) Feature Flags (optional, wenn gebraucht)
Wenn Sections per `data-if` steuerbar werden sollen:
- `flags.services`
- `flags.process`
- `flags.areas`
- `flags.cases`
- `flags.certs`
- `flags.faq`

(Erst einführen, wenn es im HTML tatsächlich benutzt wird.)
