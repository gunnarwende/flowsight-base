# 01_REPO_STRUCTURE_AND_WORKFLOW.md
Version: 1.2 (2026-02-01)

## 1) Repo & Deploy
- Repo: `flowsight-base`
- Deploy: **jsDelivr mit fixer Commit-SHA**
- Jede Änderung braucht: `commit + push + neue SHA`.

## 2) Kern-Dateien & Ordner
- `core/core.css`
  - globale Optik
  - am Dateiende genau ein Override-Block:
    - `/* FS_ACTIVE_THEME_START */`
    - `/* FS_ACTIVE_THEME_END */`
- `core/core.js`
  - Runtime (Slots, Repeaters, CTAs, Nav-Mapping, Map-Embed, `data-if`)
- `customers/<customer>/customer.json`
  - Content + Feature-Toggles pro Betrieb (template-on ist Default)
- `tools/handoff/`
  - QA/Import-Tools (ZIP-first) für Struktur + Bindings
- `docs/import/webflow-export/`
  - Staging der Webflow-Exporte + Reports
- `.local_artifacts/`
  - lokale Extrakte/Backups (muss gitignored bleiben)

## 3) Line Endings (stabil halten)
- Repo soll konsistente Zeilenenden haben (`.gitattributes`).
- Wenn Git warnt (CRLF/LF): nicht ignorieren, sondern normalisieren und committen (einmalig).

## 4) Standard-Workflow für Patches (PowerShell)
Ein Patch ist erst „fertig“, wenn er:
1) **Backup** anlegt (in `.local_artifacts`)
2) robust **replace-or-append** macht (marker-basiert)
3) `git status` zeigt
4) commit + push ausführt
5) am Ende ausgibt:
   - `NEUE HEAD SHA: <sha>`
   - kompletter **Webflow Head-Code** und **Footer-Code** (Copy/Paste)

## 5) Handoff / QA Tools (ZIP-first)
Empfohlene Reihenfolge:
1) `tools/handoff/15_section_inventory.ps1`  
   → welche `section[id]` sind im Export vorhanden
2) `tools/handoff/17_verify_custom_attrs.ps1`  
   → prüft Repeaters (`data-repeat`, `data-template`, `data-bind`) + Contact-Form message textarea
3) `tools/handoff/18_audit_bindings_full.ps1`  
   → Vollaudit Slots/Bindings von Header bis Footer
4) `tools/handoff/19_zip_audit_runner.ps1 -Open`  
   → One-shot ZIP-Audit, schreibt Report und öffnet ihn optional

Wichtig: Tools müssen immer **repo-root sicher** arbeiten (kein `C:\docs\...` hardcode).
