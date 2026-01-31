# 01_REPO_STRUCTURE_AND_WORKFLOW.md
Version: 1.0 (2026-01-30)

## 1. Ziel
GitHub ist **Single Source of Truth**. Webflow ist nur das “HTML-Skelett” + Publishing-Host.  
Assets (core.css/core.js/customer.json) werden über CDN eingebunden.

## 2. Repo-Struktur (verbindlich)
```
flowsight-base/
  .gitignore
  README.md
  core/
    core.css
    core.js
  schema/
    customer.v1.schema.json
  customers/
    leuthold-demo/
      customer.json
  docs/
    master/
      00_FLOWSIGHT_MASTER_CONTEXT.md
      01_REPO_STRUCTURE_AND_WORKFLOW.md
      02_DATA_MODEL_AND_SLOTS.md
      03_WEBFLOW_PHASE1_BLUEPRINT.md
      04_CORE_RUNTIME_RULES.md
      05_CORE_CSS_HIGHEND.md
      06_CORE_JS_RUNTIME.md
      07_CUSTOMER_JSON_TEMPLATE.md
      08_QA_DEBUG_CHECKLIST.md
      09_ANALYSE_WEBSITE_v03.md
    import/
      .gitkeep
  scripts/
    push.ps1
    lint.ps1
  tools/
    handoff/
      00_extract_latest_zip.ps1
      10_handoff_bindings.ps1
      20_verify_links.ps1
      30_verify_contact_form.ps1
      40_css_audit.ps1
      run_phase2.ps1

```

## 3. Lokales Setup (PowerShell)
1) Repo clonen:
```
cd C:\
git clone https://github.com/gunnarwende/flowsight-base.git
cd flowsight-base
```

2) Basis-Ordner sicherstellen:
```
mkdir docs -ErrorAction SilentlyContinue
mkdir docs\master -ErrorAction SilentlyContinue
mkdir scripts -ErrorAction SilentlyContinue
```

## 4. Git Push Standard (push.ps1)
Datei `scripts/push.ps1`:
```
param([string]$Message = "update")
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

git add .
git commit -m $Message
git push
```

Aufruf:
```
powershell -ExecutionPolicy Bypass -File .\scripts\push.ps1 -Message "docs: update master set"
```

## 5. Webflow Einbindung (Header/Footer Custom Code)
### 5.1 Customer JSON URL (CDN)
In Footer-Code (vor core.js):
```
<script>
window.FLOWSIGHT_CUSTOMER_URL =
  "https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/customers/leuthold-demo/customer.json";
</script>
```

### 5.2 core.js + core.css
Footer (oder Head für CSS):
```
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/core/core.css" />
<script src="https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/core/core.js" defer></script>
```

## 6. Release/Cache Regeln (wichtig)
jsDelivr cached aggressiv. Für “hard refresh” ohne Versioning:
- Nutze Git tag oder Commit-SHA im CDN-Link:
```
...@<commit-sha>/core/core.css
```
Für Demo reicht `@main`, für produktiv: **Versionierung**.

## 7. Dokumente pflegen (No-Drift)
- `docs/master/*` sind “System-Doku”
- Änderungen an Architektur/Phasen nur über Pull-Request-Style Änderung:
  - Was ändert sich?
  - Warum ist es systemisch?
  - Welche Auswirkungen auf core.css/core.js/schema?

## 8. Working Agreement (Chat-übergreifend)
Ziel: Gleicher, effizienter Arbeitsmodus über alle Chats hinweg (No-Drift / Repro).

### 8.1 Arbeitsmodus (hart)
- Kurz, präzise, reproduzierbar.
- Keine Rediskussion bereits erledigter Punkte (SSO = Repo + docs/master).
- Immer **vollständige** PowerShell-Blöcke (Windows PowerShell 5.1 kompatibel):
  - `Set-StrictMode -Version Latest`
  - `$ErrorActionPreference = "Stop"`
- Keine Deletes/Restructures ohne klare Ansage und (wenn sinnvoll) Dry-Run.

### 8.2 Single Source of Truth (SSO)
- GitHub/Repo `main` ist SSO für:
  - `core/` (Runtime)
  - `customers/` (Customer JSON)
  - `docs/master/` (Specs/Prozess/Checklisten)
  - `tools/` (Automatisierung/Verifikation)
- Webflow ist Editor/Publishing-Host; Verifikation erfolgt über Export + Reports.
- `docs/import/**` ist **lokal** (Exports, ZIP-Archive, Audits) und wird nicht versioniert.

### 8.3 Tooling / Standard-Loop
- Webflow Export ZIP → Repo-Root `C:\\flowsight-base\\`
- Ein Einstiegspunkt für Phase-Checks (Runner):
```powershell
cd C:\\flowsight-base
powershell -ExecutionPolicy Bypass -File .\\tools\\handoff\\run_phase2.ps1
```
- Reports liegen immer unter:
  - `docs\\import\\webflow-export\\latest\\`
- Wenn ein Check fehlschlägt: nur Konsolenoutput + relevante `handoff_*.txt` posten.

### 8.4 Kommunikation (Input/Output-Disziplin)
- Anfragen immer als: „poste Datei X“ oder „poste Konsolenoutput von Command Y“.
- Keine Vermutungen; nur belegbare Outputs (Export/Reports/Webflow Navigator-Pfad).

### 8.5 Git Hygiene (skalierbar)
- `docs/import/**` bleibt lokal (via `.gitignore`), nur `docs/import/.gitkeep` ist im Repo.
- Commits sind klein und thematisch (1 Änderung = 1 Commit), z.B.:
  - `tools/handoff/*` (Runner/Checks)
  - `docs/master/*` (SSO-Doku)
  - `core/*`, `customers/*`, `schema/*`, `scripts/*`
