Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ExportDir {
  param([string]$RepoRoot)
  $latest = Join-Path $RepoRoot "docs\import\webflow-export\latest"
  if (Test-Path -LiteralPath $latest) { return (Resolve-Path $latest).Path }

  $root = Join-Path $RepoRoot "docs\import\webflow-export"
  $d = Get-ChildItem -LiteralPath $root -Directory |
    Where-Object { $_.Name -match '^\d{8}-\d{6}$' } |
    Sort-Object Name -Descending |
    Select-Object -First 1
  if (-not $d) { throw "Kein Export gefunden (kein latest, kein Timestamp)." }
  return $d.FullName
}

$repo = (Get-Location).Path
$exportDir = Get-ExportDir -RepoRoot $repo
$htmlPath  = Join-Path $exportDir "index.html"
if (-not (Test-Path -LiteralPath $htmlPath)) { throw "index.html fehlt: $htmlPath" }

$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $htmlPath

$attrs = @(
  "data-slot",
  "data-bind",
  "data-repeat",
  "data-template",
  "data-cta",
  "data-href-prefix",
  "data-slot-href",
  "data-slot-image",
  "data-map-embed"
)

$lines = New-Object System.Collections.Generic.List[string]
foreach ($a in $attrs) {
  $rx = "(?is)\b" + [regex]::Escape($a) + "\s*=\s*(""([^""]*)""|'([^']*)')"
  $ms = [regex]::Matches($html, $rx)
  foreach ($m in $ms) {
    $v = $m.Groups[2].Value
    if (-not $v) { $v = $m.Groups[3].Value }
    if ($null -eq $v) { continue }
    $v = $v.Trim()

    # allow empty data-template
    if ($a -ne "data-template" -and $v -eq "") { continue }

    $lines.Add(("{0}: {1}" -f $a, $v))
  }
}

$out = Join-Path $exportDir "handoff_bindings.txt"
($lines | Sort-Object -Unique) | Set-Content -Encoding UTF8 -LiteralPath $out
Get-Item -LiteralPath $out | Format-Table Name, Length -AutoSize
Write-Host "OK: wrote $out"
