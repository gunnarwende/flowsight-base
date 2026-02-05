# DELIVERY_FASTSHIP_WEBFLOW (FlowSight)

## Ziel
Speed-first Websites in Webflow liefern, ohne Designer-Friemeln und ohne Prozessdrift.
Website = Container. Outcome = Request Capture System (Approval/Request).

## Rollen
- Owner (Kunde): liefert Fakten, bestätigt Brief.
- Operator (du): setzt in Webflow um, go-live, QA.
- AI/Assistant: strukturiert Brief, erzeugt Prompt/Copy/Flow-Pack, QA-Checkliste.

## Phasen (Ping-Pong mit Stop-Kriterien)
### Phase 0 – Projektkarte
- slug, Sprache(n), Preset (Callback/Reservation), Pricing, Timeline.

### Phase 1 – Artefakt A: CUSTOMER BRIEF (Owner-Doc)
**Stop-Kriterium: Brief complete**
- Öffnungszeiten, Adresse, Kontakt
- Preset-Regeln (Approval/Request)
- Sections ON/OFF
- Assets-Quelle (GBP/Social/Owner)
- Sprache(n) + Default
→ Erst dann Prompt erzeugen.

### Phase 2 – Artefakt B: Webflow AI Builder Prompt (≤ 5k)
- Struktur/Sections/Style/CTA-Positionierung.
**Stop-Kriterium: Draft steht** (Webflow Site generiert)

### Phase 3 – Artefakt C: Content Pack (DE/EN)
- Final Copy + Microcopy + FAQ + Trust Claims.
**Stop-Kriterium: Copy final** (eingepflegt)

### Phase 4 – Artefakt D: Flow Pack (Request System)
- Form-Felder, Success Message, Notification, Logging, Tracking.
**Stop-Kriterium: End-to-End Request** (Submit → Notification → Log)

### Phase 5 – QA / DoD
- 3 Test-Requests
- Mobile
- Sprache(n)
- Messung aktiv (Sessions + Requests)
**Stop-Kriterium: Live-ready**

## Nicht verhandelbar
- Kein Scope-Creep: kein Live-Booking, kein Voice, kein Reviews Engine Day-1
- Messbarkeit ab Tag 1
- Decisions als 3-Zeilen Log (Decision/Why/Impact)