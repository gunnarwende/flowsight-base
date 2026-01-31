Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Get-Location).Path
$exportRoot = Join-Path $root "docs\import\webflow-export"
$latest = Join-Path $exportRoot "latest"

# Find newest ZIP in repo root
$zip = Get-ChildItem -LiteralPath $root -File -Filter "*.zip" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

# Fallback: if no ZIP, but latest already exists with index.html -> continue
if (-not $zip) {
  $latestIndex = Join-Path $latest "index.html"
  if (Test-Path -LiteralPath $latestIndex) {
    Write-Host "OK: no ZIP in repo root, using existing latest export:"
    Write-Host ("OK: latest -> " + (Resolve-Path $latest).Path)
    return
  }
  throw "Keine ZIP im Repo-Root gefunden: $root (und latest fehlt)."
}

# Timestamped dest
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$dest = Join-Path $exportRoot $ts
New-Item -ItemType Directory -Force -Path $dest | Out-Null

# Move ZIP into timestamp folder and extract
$zipDest = Join-Path $dest $zip.Name
Move-Item -LiteralPath $zip.FullName -Destination $zipDest -Force
Expand-Archive -LiteralPath $zipDest -DestinationPath $dest -Force
Write-Host "OK: extracted to $dest"

# Ensure latest junction points to this dest
if (Test-Path -LiteralPath $latest) {
  Remove-Item -LiteralPath $latest -Force -Recurse
}

try {
  New-Item -ItemType Junction -Path $latest -Target $dest | Out-Null
} catch {
  cmd /c ("mklink /J `"$latest`" `"$dest`"") | Out-Null
}

Write-Host ("OK: latest -> " + $dest)
