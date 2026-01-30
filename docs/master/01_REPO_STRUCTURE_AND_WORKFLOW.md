# 01_REPO_STRUCTURE_AND_WORKFLOW.md
Version: 1.0 (2026-01-30)

## 1. Ziel
GitHub ist **Single Source of Truth**. Webflow ist nur das “HTML-Skelett” + Publishing-Host.  
Assets (core.css/core.js/customer.json) werden über CDN eingebunden.

## 2. Repo-Struktur (verbindlich)
```
flowsight-base/
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
  scripts/
    push.ps1
    lint.ps1
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
