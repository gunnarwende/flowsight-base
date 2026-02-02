param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail($msg) {
  Write-Host ("FAIL: " + $msg) -ForegroundColor Red
  exit 1
}

Write-Host "== Repo Hygiene Gate ==" -ForegroundColor Cyan

# --- Repo root robust bestimmen ---
$repoRoot = ""
try {
  $repoRoot = (& git rev-parse --show-toplevel 2>$null).Trim()
} catch {}
if (-not $repoRoot) { $repoRoot = (Get-Location).Path }

Write-Host ("FS_HYGIENE repoRoot: " + $repoRoot)

# 1) core/ darf nur core.js + core.css enthalten (keine .bak*)
$coreDir = Join-Path $repoRoot "core"
if (-not (Test-Path $coreDir)) { Fail "Missing core dir: $coreDir" }

$coreFiles = Get-ChildItem -Path $coreDir -File

$forbiddenCore = $coreFiles | Where-Object { $_.Name -match '\.bak' -or $_.Name -match '\.bak_' }
if ($forbiddenCore) {
  $forbiddenCore | ForEach-Object { Write-Host ("FAIL: forbidden core backup file: " + $_.Name) -ForegroundColor Red }
  exit 1
}

$allowed = @("core.js","core.css")
$extra = $coreFiles | Where-Object { $allowed -notcontains $_.Name }
if ($extra) {
  $extra | ForEach-Object { Write-Host ("FAIL: unexpected file in core/: " + $_.Name) -ForegroundColor Red }
  exit 1
}
Write-Host "OK: core/ contains only core.js + core.css" -ForegroundColor Green

# 2) Keine untracked Root-Leichen (alles Untracked muss in erlaubten Artefakt-Ordnern liegen)
$porcelain = & git status --porcelain
if ($LASTEXITCODE -ne 0) { Fail "git status failed" }

# allowlist: .local_artifacts + docs/import (slash + backslash)
$allowPatterns = @(
  '^\?\?\s+\.local_artifacts[\\/]',
  '^\?\?\s+docs[\\/]import[\\/]'
)

$bad = @()
foreach ($line in $porcelain) {
  if ($line -match '^\?\?\s+') {
    $ok = $false
    foreach ($p in $allowPatterns) { if ($line -match $p) { $ok = $true; break } }
    if (-not $ok) { $bad += $line }
  }
}

if ($bad.Count -gt 0) {
  Write-Host "FAIL: untracked files/dirs outside allowlist:" -ForegroundColor Red
  $bad | ForEach-Object { Write-Host $_ -ForegroundColor Red }
  exit 1
}
Write-Host "OK: untracked files are only in allowed artifact folders" -ForegroundColor Green

Write-Host "ALL OK: repo hygiene gate pass" -ForegroundColor Green
exit 0
