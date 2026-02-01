param()
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Get-Location)
$latest = Join-Path $root "docs\import\webflow-export\latest"
if (-not (Test-Path -LiteralPath $latest)) { throw "Missing export dir: $latest" }

$htmlFiles = Get-ChildItem -LiteralPath $latest -Recurse -Filter "*.html"
if (-not $htmlFiles) { throw "No HTML files found under: $latest" }

$attrs = @(
  "data-slot","data-slot-href","data-slot-image","data-repeat","data-bind","data-template","data-map-embed","data-cta","data-if"
)

$map = @{}
foreach ($a in $attrs){ $map[$a] = New-Object System.Collections.Generic.HashSet[string] }

foreach ($f in $htmlFiles){
  $raw = Get-Content -Raw -Encoding UTF8 -LiteralPath $f.FullName
  foreach ($a in $attrs){
    [regex]::Matches($raw, ($a + '\s*=\s*["'']([^"''>]+)["'']'), 'IgnoreCase') | ForEach-Object {
      [void]$map[$a].Add($_.Groups[2].Value.Trim())
    }
  }
}

Write-Host "== BINDING INVENTORY (from export) =="
foreach ($a in $attrs){
  Write-Host ""
  Write-Host ("-- " + $a + " --")
  ($map[$a] | Sort-Object) | ForEach-Object { Write-Host ("- " + $_) }
}

$out = Join-Path $latest "handoff_binding_inventory.txt"
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("== BINDING INVENTORY (from export) ==")
foreach ($a in $attrs){
  $lines.Add("")
  $lines.Add("-- " + $a + " --")
  foreach ($v in ($map[$a] | Sort-Object)){ $lines.Add("- " + $v) }
}
$lines | Set-Content -Encoding UTF8 -LiteralPath $out
Write-Host ""
Write-Host ("OK: wrote " + $out)
