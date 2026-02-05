# FLOW_PACK_REQUEST_SYSTEM (Presets)

## Gemeinsame Prinzipien
- Request/Approval first (kein Live-Booking Day-1)
- Minimalprinzip Daten: Name + Kontakt + Anliegen + Zeit
- Microcopy ohne harte SLA, wenn Owner nicht liefern kann
- Logging: created_at, request_type, name, contact, status

## Preset 1: Callback Request
Felder:
- Name (Pflicht)
- Telefon (Pflicht)
- Anliegen (Kurztext)
- Rückruf-Zeitfenster (Dropdown)
Microcopy: "Wir melden uns so bald wie möglich. Wenn dringend: direkt anrufen."

## Preset 2: Reservation Request (Pub)
Felder:
- Name (Pflicht)
- Telefon (Pflicht)
- Datum (Pflicht)
- Uhrzeit (Pflicht)
- Personen (Pflicht)
- Anlass (optional)
- Bemerkung (optional)
Checkbox (Pflicht): "Das ist eine Anfrage. Gültig erst nach Bestätigung."
Success: "Danke – wir bestätigen oder schlagen eine Alternative vor."

## Preset 3: Offer Request (später)
Felder:
- Name, Kontakt, Dienstleistung, Ort, Wunschdatum, Beschreibung, Fotos optional