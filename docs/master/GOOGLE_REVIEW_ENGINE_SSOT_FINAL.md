# Google Review Engine (n8n) — SSOT (Single Source of Truth)

UPDATED_AT: 2026-02-05 Europe/Zurich  
OWNER: Gunnar Wende  
COMPANY: FlowSight GmbH  
SCOPE: Review Engine MVP (Google Rezensionen) — n8n + Google Sheets Queue + Twilio SMS + Gmail SMTP  
STATUS: Konzept final, Implementation pending (build strictly per Runbook)

---

## 0) Zweck & Nicht-Ziele

### Zweck
Die Review Engine versendet deterministisch Review-Requests für Google Rezensionen über:
- **SMS (Twilio)** — primär (SHK service-lastig: schneller gesehen)
- **E-Mail (Gmail SMTP)** — optional (nach SMS, falls E-Mail vorhanden)

Sie arbeitet als **Queue** über Google Sheets:
- `review_intake` ist **SSOT** für Queue-State & Dispatch
- `review_log` ist **append-only Audit** (keine Primärlogik)
- `review_config` mappt `location_id -> review_url` (+ brand)

### Nicht-Ziele (MVP Guardrails)
- Kein WhatsApp im MVP
- Kein Incentive / keine Fake Reviews
- Max 1 Reminder (MVP standardmäßig **OFF**; nur wenn `review_completed` zuverlässig gepflegt wird)
- Keine n8n **Wait**-Nodes für Timing (keine offenen Executions bei Volumen)
- Keine Webflow-/Frontend-Themen in diesem Projekt (rein n8n + Sheets + Provider)

---

## 1) Produkt-Entscheidungen (fix)

- MVP-Kanäle: **SMS + E-Mail**
- Standard-Auslieferung: **Stufe 2 (n8n)** als Primary
- Pflicht-Fallback: **Stufe 1 “Rescue Mode”** Minimal-Input (manuelles Sheet/Form), kein Feature-Sumpf
- Channel-Reihenfolge bei `both`: **SMS zuerst**, danach E-Mail optional
- `review_url` ist **nicht** Pflichtfeld im Intake: kommt aus Konfiguration via `location_id`
- Throttle: **Hour-Bucket** `throttle_key = location_id|YYYYMMDDHH(eligible_send_at)`; Limit **4 pro Stunde pro location**
- Timing:
  - Normal: **service_completed_at + 2h**
  - Emergency: **service_completed_at + 72h**
  - Quiet Hours: 20:00–08:00 ⇒ verschiebe auf **08:30**
- Dedupe: `dedupe_key = hash(job_id + contact + review_url)`; **Precheck gegen status=sent** (Request) vor Send
- Reminder: default **OFF**; nur mit `review_completed` Signal (sonst riskant)
- Lock/Queue Robustness:
  - Queue-State in `review_intake.status`
  - `next_attempt_at` als deterministischer Dispatch-Filter
  - Lock-Timeout: **30m** (stale processing reset)
  - Sender strict: **send nur wenn status=processing && lock_owner==run_id && locked_at > now-30m**
  - MAX_ATTEMPTS: **3** (Backoff 15m / 60m / dann failed)

---

## 2) System-Architektur (MVP)

### Komponenten
1) **n8n** (Workflow Engine)
2) **Google Sheets** (Queue SSOT + Config + Audit)
3) **Twilio** (SMS Provider)
4) **Gmail SMTP** (E-Mail Versand)

### Datenflüsse (high-level)
- Intake-Row kommt in `review_intake` (manuell/Integration)
- Workflow A (Intake) klassifiziert: `ready|delayed|skipped` + berechnet Felder
- Workflow B (Sender Poller) scannt due Rows, setzt Lock, prüft Dedupe/Throttle, sendet, setzt Final Status
- Workflow C (Cron Reset/Dispatch) (optional je nach Setup): Reset stuck locks + triggert Sender regelmäßig  
  **Hinweis:** In MVP darf Workflow B das Polling übernehmen; Workflow C kann als reiner Cron-Trigger dienen.

---

## 3) Tools & Setup (Minimum)

### n8n Runtime
- Empfehlung MVP: **n8n Cloud**
- Version: **stable** (z.B. 2.6.3 oder aktuelle stable; im Setup fixieren)

### Google Auth
- Empfehlung: **Google Service Account**
- Sheet wird mit Service-Account E-Mail als **Editor** geteilt

### Evidence Setup (muss grün sein, bevor Build startet)
1) Read `review_config` funktioniert (Row count > 0)
2) Append `review_log` funktioniert (neue Zeile erscheint)
3) Update `review_intake` by Row Number funktioniert (status ändert sich deterministisch)

---

## 4) Google Sheets — SSOT Schema (exakt)

### 4.1 Tab: `review_intake` (Queue + Input)
**Business Input (Minimum):**
- `job_id`
- `service_completed_at` (ISO empfohlen)
- `customer_name`
- `location_id`
- `phone_e164` (E.164, z.B. +41…)
- `email`
- `channel_pref` (`sms|email|both|leer`)
- `is_emergency` (`true|false|leer`)
- `exclude` (`true|false|leer`)
- `exclude_reason`
- `optout` (`true|false|leer`)
- `customer_locale` (default `de-CH`)
- `review_url_override` (leer im Normalfall)
- `review_completed` (`true|false|leer`)
- `reminder_enabled` (`true|false|leer`, default false)
- `reminder_hours` (default 72; ignoriert wenn reminder_enabled=false)
- `notes`

**Queue/System (SSOT):**
- `status` (`new|ready|delayed|processing|sent|skipped|failed|duplicate`)
- `next_attempt_at` (ISO)
- `attempt_count` (int)
- `last_attempt_at` (ISO)
- `last_error` (string)
- `run_id` (UUID pro Lock/Attempt)
- `dedupe_key` (string)
- `eligible_send_at` (ISO)
- `throttle_key` (string hour-bucket)
- `lock_owner` (string; = run_id)
- `locked_at` (ISO)

### 4.2 Tab: `review_config` (Mapping pro location)
Pflicht:
- `location_id` (Key)
- `brand_name`
- `review_url`
Optional (nur Daten, keine neue Logik):
- `from_email_name`
- `timezone`

### 4.3 Tab: `review_log` (append-only Audit)
Pflichtfelder (MVP):
- `logged_at`
- `event_type` (`request`)
- `status`
- `reason_code` (falls Spalte existiert)
- `run_id`
- `job_id`
- `location_id`
- `dedupe_key`
- `throttle_key`
- `attempt_count`
- `next_attempt_at`
- `lock_owner`
- `locked_at`
Optional:
- `provider_sms_id`
- `provider_email_id`
- `eligible_send_at`
- `decision_path`
- `notes`

---

## 5) Deterministische Regeln (SSOT Contract)

### 5.1 Defaults
- `channel_pref` leer ⇒ `both`
- `reminder_enabled` leer ⇒ `false`
- `is_emergency/exclude/optout` leer ⇒ `false`
- `customer_locale` leer ⇒ `de-CH`

### 5.2 review_url Resolve
- `review_url = review_url_override` wenn gesetzt, sonst `review_config.review_url` via `location_id`
- Wenn keine Config gefunden ⇒ `skipped` (missing_config)

### 5.3 Timing
- Normal: `eligible_send_at = service_completed_at + 2h`
- Emergency: `eligible_send_at = service_completed_at + 72h`
- Quiet Hours (lokal): wenn eligible zwischen 20:00–08:00 ⇒ setze auf 08:30
- `next_attempt_at = eligible_send_at` (MVP)

### 5.4 Throttle
- `throttle_key = location_id|YYYYMMDDHH(eligible_send_at)`
- Gate: `count(status=sent in intake where throttle_key==current) >= 4` ⇒ delayed, `next_attempt_at = now + 30m`

### 5.5 Dedupe
- `dedupe_key = hash(job_id + contact + review_url)`
- Gate: `exists(status=sent in intake where dedupe_key==current)` ⇒ final `duplicate`

### 5.6 Locking & Retries
- Sender setzt Lock (processing) mit `run_id`, `lock_owner=run_id`, `locked_at=now`, `attempt_count++`
- Sender sendet **nur** wenn:
  - `status == processing`
  - `lock_owner == run_id`
  - `locked_at > now - 30m`
- Lock Timeout Reset:
  - `status=processing` und `locked_at <= now-30m` ⇒ setze `delayed`, `next_attempt_at=now+15m`, lock fields leeren, audit `lock_timeout_reset`
- MAX_ATTEMPTS=3:
  - attempt 1 error ⇒ `next_attempt_at=now+15m`
  - attempt 2 error ⇒ `next_attempt_at=now+60m`
  - attempt 3 error ⇒ `status=failed`

---

## 6) Provider (MVP Minimal)

### 6.1 Twilio (SMS)
- Credential: Account SID + Auth Token
- From: Twilio Number
- SMS Template:
  - Request: `Hallo {{customer_name}}, danke fuer den Einsatz. Wie war Ihre Erfahrung? {{review_url}}`

### 6.2 Gmail SMTP (E-Mail)
- SMTP Host: `smtp.gmail.com`
- Port: 587 (STARTTLS) oder 465 (SSL)
- Auth: App Password
- Email Template (Plain):
  - Subject: `Danke fuer Ihren Auftrag – kurze Bewertung?`
  - Body: `Hallo {{customer_name}}, ... {{review_url}} ... {{brand_name}}`

---

## 7) Workflows (MVP) — Namen + Verantwortung

### Workflow A: `RE_A_Intake_Router_NewRow`
**Responsibility:** Intake klassifizieren + Felder berechnen; keine Sends.

**Outputs:** `status ready|delayed|skipped`, setzt `eligible_send_at`, `next_attempt_at`, `dedupe_key`, `throttle_key`, `attempt_count=0`

### Workflow B: `RE_B_Sender_Poller_Lock_Gates_Send`
**Responsibility:** Strict Lock + Lock setzen + Gates (dedupe/throttle) + Send + Final Status; reset stuck processing.

**Polling:** Read last N=500 aus `review_intake`, Function filter due_queue + stuck_processing.

### Workflow C: `RE_C_Reset_And_Dispatch_Cron_15m`
**Responsibility:** Cron Trigger alle 15 Minuten; kann Sender ausführen.  
(MVP minimal: Cron triggert Sender; Sender macht Read/Filter/Lock/Gates/Send.)

---

## 8) Node Settings (SSOT Summary)

Prinzip: Google Sheets ohne fragile Filter: überall **Read last N + Function-Filter**, Updates nur via **Row Number**.

- Trigger: New Row on `review_intake`
- Reads: `review_intake` last N (Sender: 500; Gates: 2000)
- Updates: `review_intake` via row_number
- Append Audit: `review_log` append-only

---

## 9) Test-Runbook (8 Tests)

Konventionen:
- Lock Timeout: 30m anhand locked_at
- Quiet Hours: 20:00–08:00 ⇒ 08:30
- Status: new|ready|delayed|processing|sent|skipped|failed|duplicate
- MAX_ATTEMPTS: 3 (15m/60m/failed)

### Test 1 — missing_config → skipped (Intake)
- location_id ohne config ⇒ status=skipped, audit missing_config

### Test 2 — invalid_input → skipped (Intake)
- kein gültiger contact ⇒ status=skipped, audit invalid_input

### Test 3 — optout/exclude → skipped (Intake)
- optout=true oder exclude=true ⇒ status=skipped, audit optout/exclude

### Test 4 — not due → delayed (Intake)
- eligible_send_at in Zukunft ⇒ status=delayed, next_attempt_at=eligible_send_at

### Test 5 — due → ready → sent (Sender)
- due row ⇒ Lock (processing) ⇒ sent ⇒ audit sent

### Test 6 — dedupe verhindert → duplicate (Sender)
- dedupe_key bereits sent ⇒ status=duplicate, audit dedupe_blocked

### Test 7 — throttle backoff → delayed +30m (Sender)
- throttle_count>=4 ⇒ delayed, next_attempt_at=now+30m, audit throttled

### Test 8 — stuck processing reset → delayed +15m (Sender/Dispatcher)
- processing + stale locked_at ⇒ delayed, next_attempt_at=now+15m, audit lock_timeout_reset

---

## 10) Setup-Checkliste (phased)

Phase 0: Entscheidungen fix (n8n Cloud, Service Account, Tabs)  
Phase 1: n8n Cloud bereit, Version prüfen  
Phase 2: Google Cloud Service Account + APIs  
Phase 3: Sheet Tabs + Header anlegen  
Phase 4: Sheet share an Service Account (Editor)  
Phase 5: n8n Credentials anlegen  
Phase 6: Smoke Tests (Read config, Append log, Update intake by row number)  
Phase 7: Build Workflows A/B/C + Tests 1–8

---

## 11) Definition of Done (MVP)
- n8n Workflows A/B/C existieren und laufen deterministisch
- Ein due item wird genau einmal gesendet (dedupe + lock strict)
- Throttle 4/h/location enforced via throttle_key
- Quiet hours enforced (20–08 ⇒ 08:30)
- Lock timeout repair (30m) funktioniert
- MAX_ATTEMPTS=3 funktioniert (15m/60m/failed)
- Audit log append-only ist vollständig (review_log)
