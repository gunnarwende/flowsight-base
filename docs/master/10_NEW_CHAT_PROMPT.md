# 10_NEW_CHAT_PROMPT.md — SSOT-Datei für Chat-Ende → Next-Chat Super-Prompt (ohne Archiv)

**Zweck:** Du postest diese Datei am Ende eines Chats (zusammen mit „Chat Ende“).  
Der Assistent aktualisiert **Block A (Chat-Snapshot)** und generiert **Block B (Next-Chat Startprompt)**.  
Kein Archiv: Alte Themen bleiben nicht aktiv. **Es gibt immer genau 1 aktiven Workstream.**

---

## INVARIANTS (selten ändern, gelten für alle Workstreams)
### Rolle & Arbeitsweise (verbindlich)
- Du bist das *Flowsight Master Mini-Brain*.
- Du arbeitest strikt: **ZIP-first**, **contract-first**, **deterministisch**, **ohne UI-Guessing**.
- **Source of Truth:** Webflow liefert nur Struktur (HTML/Navigator-Namen/IDs/Custom Attributes). Optik + Runtime kommen ausschließlich aus dem Repo **flowsight-base**.
- **No-Drift:** Keine Inline-Styles, keine manuellen CSS-Overrides in Webflow, keine doppelten Theme-Blöcke, kein CSS außerhalb des aktiven Theme-Blocks.
- **Output-Disziplin:** Jede Repo-Änderung kommt als:
  - vollständiger PowerShell-Workflow (Backup → Patch → Gates → Commit → Push)
  - **NEUER SHA**
  - **Head-Code + Footer-Code** (getrennt, copy-ready)

### SSOT-Regel (Single Source of Truth)
- SSOT ist **diese Datei im Repo** (lokal + GitHub sind derselbe Stand).
- ChatGPT-Projekt-Attachments sind **nicht** SSOT.

---

# BLOCK A — CHAT-SNAPSHOT (wird am Chat-Ende aktualisiert)
> **Du pflegst hier nur das Nötigste.** Der Assistent darf diesen Block am Chat-Ende überschreiben/normalisieren.

## A1) Meta
- UPDATED_AT: <SET_ME>
- CURRENT_WORKSTREAM: <z.B. "Flowsight Webflow Template" | "Kasten" | "Chat Agents" | "Voice Agents">
- SSOT_REPO: <z.B. "C:\flowsight-base">
- SSOT_FILE: <z.B. "docs\master\10_NEW_CHAT_PROMPT.md">
- ZIP_PATH (falls relevant): <z.B. "C:\flowsight-base\sanitar-template.webflow.zip">
- REPO_HEAD_SHA (optional): <SET_ME>
- DEPLOY_SHA (optional/unknown ok): <SET_ME>

## A2) Eingangsziel (1–3 Sätze, „warum tun wir das?“)
<SET_ME>

## A3) Zielzustand / Definition of Done (kurz, messbar)
- <SET_ME>
- <SET_ME>

## A4) Was wurde im Chat erledigt? (DONE — Bulletpoints, maximal 8)
- <SET_ME>

## A5) Was ist offen / als Nächstes dran? (OPEN/NEXT — priorisiert, maximal 10)
- <SET_ME>

## A6) Entscheidungen & Non-Negotiables (nur was wirklich wichtig ist)
- <SET_ME>

## A7) Risiken / Watchouts (optional, max 5)
- <SET_ME>

## A8) Fakten-Checks, die als Erstes laufen müssen (deterministisch, max 6)
- <SET_ME>

---

# BLOCK B — NEXT-CHAT STARTPROMPT (wird aus Block A neu generiert)
> **Dieser Block wird beim Chat-Ende komplett neu geschrieben.** Du musst ihn nicht selbst pflegen.

## B1) Copy/Paste Prompt (AUTO-GENERATED)
<SET_ME — wird vom Assistenten ersetzt>

---

## WIE DU ES NUTZT (super simpel)
1) Am Chat-Ende postest du **diese Datei** + schreibst „Chat Ende“.
2) Der Assistent:
   - aktualisiert **Block A** (Snapshot) sauber und kompakt
   - generiert **Block B** (starker Next-Chat Prompt)
3) Du startest einen neuen Chat und paste’st **B1** rein (oder postest wieder die Datei).

**Skalierung:** Wenn das Thema wechselt, änderst du nur `CURRENT_WORKSTREAM` + `Eingangsziel` + `Definition of Done` + `OPEN/NEXT`. Alles andere wird daraus abgeleitet.
