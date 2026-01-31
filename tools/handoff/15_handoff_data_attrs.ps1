Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FlowSightExportDir {
  $latest = Join-Path (Get-Location) "docs\import\webflow-export\latest"
  if (Test-Path -LiteralPath $latest) { return (Resolve-Path $latest).Path }

  $root = Join-Path (Get-Location) "docs\import\webflow-export"
  $d = Get-ChildItem -LiteralPath $root -Directory |
    Where-Object { $_.Name -match '^\d{8}-\d{6}$' } |
    Sort-Object Name -Descending |
    Select-Object -First 1
  if (-not $d) { throw "Kein Export gefunden (kein latest, kein Timestamp)." }
  return $d.FullName
}

$exportDir = Get-FlowSightExportDir
$htmlPath  = Join-Path $exportDir "index.html"
if (-not (Test-Path -LiteralPath $htmlPath)) { throw "index.html fehlt: $htmlPath" }

$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $htmlPath

# Find all data-* attribute names (data-xxx=...) in HTML, unique + sorted
$matches = [regex]::Matches($html, '(?is)\b(data-[a-z0-9\-]+)\s*=')

$attrs = foreach ($m in $matches) {
  $v = $m.Groups[1].Value
  if ($v) { $v.Trim().ToLowerInvariant() }
}

$attrsArr = @($attrs | Where-Object { $_ } | Sort-Object -Unique)

$outPath = Join-Path $exportDir "handoff_data-attrs.txt"
if ($attrsArr.Length -gt 0) {
  $attrsArr | Set-Content -Encoding UTF8 -LiteralPath $outPath
} else {
  "# none" | Set-Content -Encoding UTF8 -LiteralPath $outPath
}

Get-Item -LiteralPath $outPath | Format-Table Name, Length -AutoSize
Write-Host "OK: wrote $outPath"
