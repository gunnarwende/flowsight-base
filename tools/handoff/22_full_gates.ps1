param(
  [string]$Customer = "template-on"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "== FLOWSIGHT FULL GATES ==" -ForegroundColor Cyan

powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\handoff\19_zip_audit_runner.ps1" | Out-Host
powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\handoff\18_audit_bindings_full.ps1" | Out-Host

powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\handoff\21_drift_gates.ps1" | Out-Host
powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\handoff\20_customer_contract_gate.ps1" -Customer $Customer | Out-Host

Write-Host "ALL OK: full gates pass" -ForegroundColor Green
