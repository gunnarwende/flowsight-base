param(
  [string]$Customer = "template-on"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function RunGate([string]$label, [string]$file, [string[]]$args = @()) {
  Write-Host ""
  Write-Host ("== " + $label + " ==") -ForegroundColor Cyan

  $cmd = @("-NoProfile","-ExecutionPolicy","Bypass","-File",$file) + $args
  & powershell @cmd

  if ($LASTEXITCODE -ne 0) {
    throw ("Gate failed: " + $label + " (exit " + $LASTEXITCODE + ")")
  }
}

RunGate "ZIP audit"      ".\tools\handoff\19_zip_audit_runner.ps1"
RunGate "Bindings audit" ".\tools\handoff\18_audit_bindings_full.ps1"
RunGate "Drift gates"    ".\tools\handoff\21_drift_gates.ps1"
RunGate "Repo hygiene gate" ".\tools\handoff\23_repo_hygiene_gate.ps1"
RunGate "Customer gate"  ".\tools\handoff\20_customer_contract_gate.ps1" @("-Customer",$Customer)

Write-Host ""
Write-Host "ALL OK: full gates pass" -ForegroundColor Green
