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

# RECURSIVE search (Webflow exports CSS under /css)
$cssCandidates = Get-ChildItem -LiteralPath $exportDir -Recurse -File -Filter "*.css" |
  Where-Object { $_.Name -notin @("normalize.css","webflow.css") }

if (-not $cssCandidates) { throw "Keine Projekt-CSS im Export gefunden (außer normalize/webflow.css) in $exportDir" }

# Prefer *.webflow.css that is not webflow.css
$projectCss = $cssCandidates | Where-Object { $_.Name -like "*.webflow.css" -and $_.Name -ne "webflow.css" } |
  Sort-Object Length -Descending |
  Select-Object -First 1
if (-not $projectCss) {
  $projectCss = $cssCandidates | Sort-Object Length -Descending | Select-Object -First 1
}

$cssPath = $projectCss.FullName
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

# Custom class selectors (simple heuristic)
$classes = [regex]::Matches($css,'(?m)^\s*\.(?!w-)([a-zA-Z0-9_-]+)\b') |
  ForEach-Object { $_.Groups[1].Value } |
  Where-Object { $_ } |
  Sort-Object -Unique

$classesOut = Join-Path $exportDir "handoff_css_defined_custom_classes.txt"
if (-not $classes -or $classes.Length -eq 0) { "# none" | Set-Content -Encoding UTF8 -LiteralPath $classesOut }
else { $classes | Set-Content -Encoding UTF8 -LiteralPath $classesOut }

# Bad props sample (heuristic: common override props)
$badProps = @(
  "margin", "padding", "font-size", "line-height", "letter-spacing", "font-family",
  "color", "background", "background-color", "border", "border-radius",
  "box-shadow", "text-align", "text-transform", "text-decoration"
)

$badRx = "(?im)^\s*(?:" + (($badProps | ForEach-Object { [regex]::Escape($_) }) -join "|") + ")\s*:"
$bad = [regex]::Matches($css,$badRx) | ForEach-Object { $_.Value.Trim() }

$badOut = Join-Path $exportDir "handoff_css_badprops_sample.txt"
if (-not $bad -or $bad.Count -eq 0) { "# none" | Set-Content -Encoding UTF8 -LiteralPath $badOut }
else { ($bad | Select-Object -First 80) | Set-Content -Encoding UTF8 -LiteralPath $badOut }

Write-Host "OK: projectCSS = $($projectCss.Name)"
Get-Item -LiteralPath $classesOut,$badOut | Format-Table Name, Length -AutoSize
