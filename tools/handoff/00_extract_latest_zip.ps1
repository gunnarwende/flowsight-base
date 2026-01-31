Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  return (Get-Location).Path
}

$root = Get-RepoRoot
$exportRoot = Join-Path $root "docs\import\webflow-export"
$archiveDir = Join-Path $root "docs\import\_zip-archive"
$latest = Join-Path $exportRoot "latest"

New-Item -ItemType Directory -Force -Path $exportRoot | Out-Null
New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null

$zip = Get-ChildItem -LiteralPath $root -File -Filter "*.zip" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $zip) { throw "Keine ZIP im Repo-Root gefunden: $root" }

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$dest = Join-Path $exportRoot $ts
New-Item -ItemType Directory -Force -Path $dest | Out-Null

# Copy ZIP into timestamp dir (safe)
$zipCopy = Join-Path $dest $zip.Name
Copy-Item -LiteralPath $zip.FullName -Destination $zipCopy -Force

# Extract
Expand-Archive -LiteralPath $zipCopy -DestinationPath $dest -Force

# Archive ZIP (copy)
Copy-Item -LiteralPath $zip.FullName -Destination (Join-Path $archiveDir $zip.Name) -Force

# Reset latest junction (safe; removes only the link/folder, not timestamp folders)
if (Test-Path -LiteralPath $latest) { Remove-Item -LiteralPath $latest -Force -Recurse }

try { New-Item -ItemType Junction -Path $latest -Target $dest | Out-Null }
catch { cmd /c ("mklink /J `"$latest`" `"$dest`"") | Out-Null }

Write-Host "OK: extracted to $dest"
Write-Host "OK: latest -> $dest"
