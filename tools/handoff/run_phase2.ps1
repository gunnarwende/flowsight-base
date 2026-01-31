Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "== FlowSight Phase 2 Runner =="

# resolve repo root from this script location (tools/handoff)
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $repoRoot
Write-Host ("Repo: " + (Get-Location).Path)

function Invoke-Step($relPath) {
  $p = Join-Path $PSScriptRoot $relPath
  if (-not (Test-Path -LiteralPath $p)) { throw "Missing script: $p" }
  & $p
}

# 0) Extract latest ZIP + set latest junction
Invoke-Step "00_extract_latest_zip.ps1"

# 1) Bindings
Invoke-Step "10_handoff_bindings.ps1"

# 1.5) Data-Attrs inventory (NEW)
Invoke-Step "15_handoff_data_attrs.ps1"

# 2) Links verify
Invoke-Step "20_verify_links.ps1"

# 3) Contact form verify
Invoke-Step "30_verify_contact_form.ps1"

# 4) CSS audit
Invoke-Step "40_css_audit.ps1"

Write-Host ""
Write-Host "== DONE =="
Write-Host "Check reports in: docs\import\webflow-export\latest"
