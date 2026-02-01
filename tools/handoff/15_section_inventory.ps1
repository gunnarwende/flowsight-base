param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Get-Location)
$latest = Join-Path $root "docs\import\webflow-export\latest"
if (-not (Test-Path -LiteralPath $latest)) { throw "Missing export dir: $latest" }

$html = Get-ChildItem -LiteralPath $latest -Recurse -Filter "*.html" | Select-Object -First 25
if (-not $html) { throw "No HTML files found under: $latest" }

$ids = New-Object System.Collections.Generic.HashSet[string]

foreach ($f in $html){
  $raw = Get-Content -Raw -Encoding UTF8 -LiteralPath $f.FullName
  # collect: <section ... id="...">
  [regex]::Matches($raw, '<section[^>]*\sid\s*=\s*["'']([^"''\s>]+)["'']', 'IgnoreCase') | ForEach-Object {
    [void]$ids.Add($_.Groups[1].Value)
  }
}

$list = $ids | Sort-Object
Write-Host "== SECTION INVENTORY (from export) =="
$list | ForEach-Object { Write-Host ("- " + $_) }

# write report (local)
$out = Join-Path $latest "handoff_sections.txt"
$list | Set-Content -Encoding UTF8 -LiteralPath $out
Write-Host ("OK: wrote " + $out)
