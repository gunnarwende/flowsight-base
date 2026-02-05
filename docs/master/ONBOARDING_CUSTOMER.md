# ONBOARDING_CUSTOMER.md — Customer Onboarding Wizard (SSOT Template)

## Zweck
Dieses Dokument ist das **interaktive Runbook** (Wizard) für jeden Kunden.
Es ist **SSOT für Reihenfolge & Gates**: Dialog → Record → Gate → (erst dann) Execution.

## Grundregeln (No Drift, hard)
- Webflow liefert **nur Struktur/IDs/Custom Attributes**. Keine Optik-Overrides in Webflow.
- Keine Inline-Styles, keine Webflow-CSS Overrides, exakt **1 aktiver Theme-Block**.
- PS 5.1 kompatibel: kein `?:`, kein `??`, keine Auto-Stash/Pop.
- **Repo muss clean sein** vor jedem Execution-Block (`git status --porcelain` muss leer sein).
- ZIP-Audit Gate: im Repo-Root muss lokal **mind. 1 `*.webflow.zip`** liegen (ignoriert, nicht committen).
- Kundenbilder niemals “inboxen” im Repo. Inbox ist **außerhalb**: `C:\flowsight-staging\<customer_slug>\inbox\`.
- jsDelivr: **commit-SHA** Mode (empfohlen): `https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@<SHA>/...`

## Artefakte pro Kunde (Pflicht)
Für jeden Kunden existieren genau:
1) **Customer Record (Instanz, ausfüllbar):** `customers/<slug>/ONBOARDING_RECORD.md`
2) **Customer Data Contract (Execution):** `customers/<slug>/customer.json`

> Dieses Dokument bleibt generisch. Kundendaten gehören ausschließlich in den Customer Record.

## Wie du diesen Wizard benutzt (immer gleich)
1) Du sagst: **“Neuer Kunde, ich hatte ein Gespräch.”**
2) Wir arbeiten Stage für Stage durch (0 → 7).
3) Du antwortest **immer** im vorgegebenen Antwortformat.
4) Erst wenn ein Gate grün ist, gilt die Stage als abgeschlossen.
5) **Execution** (PowerShell) kommt erst nach “GO” und Gate-Freigabe.

---

# Stage Map (fixe Reihenfolge)

## Stage 0 — Intake & Identity (Dialog)
**Ziel:** Kunde eindeutig identifizieren und Basisparameter festziehen.

**Antwortformat (copy/paste):**
~~~txt
A) customer_display_name=
B) customer_slug=(suggest|value)
C) legal_entity_type=
D) market_country=
E) market_region_or_city=
F) primary_language=
G) mode=(golden|scaffold|production)
~~~

**Gate 0 (HARD):**
- `customer_slug` final (kebab-case, eindeutig)
- `mode` gesetzt

---

## Stage 1 — Scope Matrix (Dialog)
Ref: `docs/master/MASTER_TEMPLATE_EXPORT_INVENTORY.md`

~~~txt
A) GOLDEN_ALL_ON=(yes|no)
B) OFF_EXCEPTIONS=(none|list items + reason)
C) SECOND_LANGUAGE=(no|yes -> which?)
~~~

---

## Stage 2 — Proof Pack (Golden: 6/12/8) (Dialog)
~~~txt
A) IMAGE_MODE=(duplicate-seed|distinct)
B) CASES_6=(gc-001:..., gc-002:..., gc-003:..., gc-004:..., gc-005:..., gc-006:...)
C) REVIEWS_8_SOURCE=
D) REVIEWS_8_TEXTS=(paste|tbd)
E) CERTS_PARTNERS_BADGES=(list|tbd|none)
~~~

---

## Stage 3 — Data Contract Plan
~~~txt
A) CONTRACT_READY=(yes|no)
B) STABLE_IDS=(cases.case_id format, reviews.id format, etc.)
C) OPTIONAL_SECTIONS_OFF=(none|list)
~~~

---

## Stage 4 — Assets Policy (Inbox outside repo)
~~~txt
A) INBOX_PATH=C:\flowsight-staging\<customer_slug>\inbox\
B) SEED_OK=(yes|no)
C) IMAGE_MODE=(duplicate-seed|distinct)
D) DISTINCT_INPUT=(ready_12|not_ready)
~~~

---

## Stage 5 — Webflow Binding Plan
~~~txt
A) WEBFLOW_IDS_LOCKED=(yes|no)
B) SECTION_TOGGLES_CONFIRMED=(yes|no)
C) ATTR_BINDINGS_PLAN=(ready|tbd)
~~~

---

## Stage 6 — Execution Preconditions (Hard Gate)
~~~txt
A) GIT_PORCELAIN=<paste output>  # must be empty
B) ZIP_IN_ROOT=(yes|no)
C) INBOX_OK=(yes|no)
D) GO_EXECUTION=(yes|no)
~~~

---

## Stage 7 — Change Control (nur wenn Prozess geändert wird)
~~~txt
Decision=
Why=
Impact=
~~~