param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ExportRoot {
  $repo = Get-Location

  # Prefer latest *.webflow.zip in repo root
  $zip = Get-ChildItem -LiteralPath $repo -Filter "*.webflow.zip" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

  if ($zip) {
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $dest = Join-Path $repo ".local_artifacts\_wf_zip_latest_$ts"
    New-Item -ItemType Directory -Path $dest | Out-Null
    Expand-Archive -LiteralPath $zip.FullName -DestinationPath $dest -Force
    return @{ mode="zip"; root=$dest; zip=$zip.FullName }
  }

  # Fallback: latest export dir
  $latest = Join-Path $repo "docs\import\webflow-export\latest"
  if (-not (Test-Path -LiteralPath $latest)) { throw "No ZIP in repo root and missing export dir: $latest" }
  return @{ mode="dir"; root=$latest; zip="" }
}

function Resolve-HtmlFile([string]$root){
  $idx = Get-ChildItem -LiteralPath $root -Recurse -Filter "index.html" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($idx) { return $idx.FullName }
  $any = Get-ChildItem -LiteralPath $root -Recurse -Filter "*.html" | Select-Object -First 1
  if ($any) { return $any.FullName }
  throw "No HTML found under: $root"
}

$repo = Get-Location
$outDir = Join-Path $repo "docs\import\webflow-export\latest"
if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$res = Resolve-ExportRoot
$htmlPath = Resolve-HtmlFile $res.root
$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $htmlPath

# extract section ids
$ids = New-Object System.Collections.Generic.HashSet[string]
[regex]::Matches($html, '<section[^>]*\sid\s*=\s*["'']([^"''\s>]+)["'']', [Text.RegularExpressions.RegexOptions]::IgnoreCase) |
  ForEach-Object { [void]$ids.Add($_.Groups[1].Value) }

Write-Host "== SECTION INVENTORY (from export) =="
$ids | Sort-Object | ForEach-Object { Write-Host ("- " + $_) }

$out = Join-Path $outDir "handoff_sections.txt"
($ids | Sort-Object) | Set-Content -Encoding UTF8 -LiteralPath $out
Write-Host ("OK: wrote " + $out)

if ($res.mode -eq "zip") {
  Write-Host ("OK: source zip -> " + $res.zip)
  Write-Host ("OK: extracted -> " + $res.root)
} else {
  Write-Host ("OK: source dir -> " + $res.root)
}
