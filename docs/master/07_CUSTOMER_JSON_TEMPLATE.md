# 07_CUSTOMER_JSON_TEMPLATE.md
Version: 1.0 (2026-01-30)

Diese Datei ist die **Copy/Paste-Vorlage** für `customers/<customer>/customer.json`.

```json
{
  "business": {
    "name": "Walter Leuthold – Sanitär & Spenglerei",
    "region_label": "Oberrieden • linker Zürichsee",
    "brand": {
      "logo": {
        "src": "https://example.com/logo.svg"
      }
    }
  },
  "hero": {
    "headline": "24/7 Sanitär-Notfall in Oberrieden & Umgebung",
    "subline": "Soforthilfe bei Rohrbruch, verstopften Abflüssen, Wasserschaden – schnell vor Ort, transparent, sauber.",
    "trust_badges": [
      {
        "label": "24/7 Notfall"
      },
      {
        "label": "Schnell vor Ort"
      },
      {
        "label": "Transparente Preise"
      },
      {
        "label": "Top Bewertungen"
      }
    ]
  },
  "services": {
    "items": [
      {
        "title": "Rohrbruch / Leckortung",
        "description": "Schnelle Lecksuche, Abdichtung, provisorische Sofortmassnahmen."
      },
      {
        "title": "Abfluss verstopft",
        "description": "Küche, Bad, WC – professionell reinigen, ohne Pfuschlösungen."
      },
      {
        "title": "Wasserschaden",
        "description": "Sofortmassnahmen, Koordination, Dokumentation für Versicherung."
      },
      {
        "title": "Boiler / Warmwasser",
        "description": "Reparatur, Austausch, Wartung."
      },
      {
        "title": "Armaturen / WC",
        "description": "Montage, Reparatur, Dichtungen, Spülungen."
      },
      {
        "title": "Sanitär-Service",
        "description": "Unterhalt, kleine Umbauten, schnelle Einsätze."
      }
    ]
  },
  "trust": {
    "reviews": {
      "headline": "Bewertungen aus der Region",
      "items": [
        {
          "author": "A. M.",
          "text": "Sehr schnell vor Ort, sauber gearbeitet, faire Kosten."
        },
        {
          "author": "M. K.",
          "text": "Notfall am Sonntag – freundlich, kompetent, Problem gelöst."
        }
      ]
    }
  },
  "contact": {
    "form": {
      "headline": "Kontakt & Soforthilfe"
    },
    "phones": {
      "emergency": {
        "display": "24/7 Notfall: 044 000 00 00",
        "e164": "+41440000000"
      },
      "normal": {
        "display": "Büro: 044 111 11 11",
        "e164": "+41441111111"
      }
    },
    "address": {
      "street": "Musterstrasse 12"
    },
    "opening_hours": {
      "label": "Mo–Fr 08:00–17:00 • Notfall 24/7"
    },
    "map": {
      "embed_url": "https://www.google.com/maps/embed?pb=!1m18..."
    }
  },
  "links": {
    "google_review": "https://search.google.com/local/writereview?placeid=PLACE_ID_HERE"
  },
  "cta": {
    "labels": {
      "review": "Google Bewertung schreiben"
    }
  }
}
```
