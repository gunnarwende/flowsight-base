# FlowSight Base

Single Source of Truth Repo for FlowSight Webflow container wiring.

## Runtime (jsDelivr)
- core CSS: https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/core/core.css
- core JS:  https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/core/core.js
- customer (example): https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/customers/leuthold-demo/customer.json

## Local Workflow

### 1) Webflow Export
Download export ZIP and place it into repo root:
C:\flowsight-base\

### 2) Phase 2 Verification Runner
Runs extract + handoffs + verifies (links, form, css):
powershell -ExecutionPolicy Bypass -File .\tools\handoff\run_phase2.ps1

Artifacts are written to:
docs\import\webflow-export\latest\

## Repo Hygiene
docs/import/** contains local artifacts (exports, archives, audits) and is ignored by git.
