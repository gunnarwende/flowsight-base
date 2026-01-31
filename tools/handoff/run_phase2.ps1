Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = (Get-Location).Path

Write-Host "== FlowSight Phase 2 Runner =="
Write-Host "Repo: $repo"

# 1) Extract latest ZIP -> latest
& (Join-Path $here "00_extract_latest_zip.ps1")

# 2) Bindings
& (Join-Path $here "10_handoff_bindings.ps1")

# 3) Verify links/anchors (tel-wired + legal exceptions handled)
& (Join-Path $here "20_verify_links.ps1")

# 4) Verify contact form mapping
& (Join-Path $here "30_verify_contact_form.ps1")

# 5) CSS audit
& (Join-Path $here "40_css_audit.ps1")

Write-Host "== DONE =="
Write-Host "Check reports in: docs\import\webflow-export\latest"
