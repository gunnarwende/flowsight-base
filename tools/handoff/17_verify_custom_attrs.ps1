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
    $dest = Join-Path $repo ".local_artifacts\_wf_verify_zip_$ts"
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

function Get-SectionHtml([string]$html, [string]$id){
  $rx = '<section[^>]*\sid\s*=\s*["'']' + [regex]::Escape($id) + '["''][\s\S]*?</section>'
  $m = [regex]::Match($html, $rx, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($m.Success) { return $m.Value }
  return ""
}

$repo = Get-Location
$outDir = Join-Path $repo "docs\import\webflow-export\latest"
if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$res = Resolve-ExportRoot
$htmlPath = Resolve-HtmlFile $res.root
$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $htmlPath

$checks = @(
  @{ id="services"; rep='data-repeat\s*=\s*["'']services\.items["'']'; must=@('data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="process";  rep='data-repeat\s*=\s*["'']process\.items["'']';  must=@('data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="areas";    rep='data-repeat\s*=\s*["'']areas\.items["'']';    must=@('data-template','data-bind\s*=\s*["'']title["'']') },
  @{ id="certs";    rep='data-repeat\s*=\s*["'']certs\.items["'']';    must=@('data-template','data-bind\s*=\s*["'']title["'']') },
  @{ id="faq";      rep='data-repeat\s*=\s*["'']faq\.items["'']';      must=@('data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="cases";    rep='data-repeat\s*=\s*["'']cases\.items["'']';    must=@('data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']','data-bind-image\s*=\s*["'']photos\.0\.src["'']') }
)

Write-Host "== VERIFY CUSTOM ATTRIBUTES (ZIP-first) =="
Write-Host ("HTML: " + $htmlPath)
if ($res.mode -eq "zip") { Write-Host ("ZIP:  " + $res.zip) }
Write-Host ""

$passAll = $true
$report = New-Object System.Collections.Generic.List[string]
$report.Add("HTML: " + $htmlPath)
if ($res.mode -eq "zip") { $report.Add("ZIP:  " + $res.zip) }
$report.Add("")

foreach ($c in $checks){
  $secPass = $true
  $miss = New-Object System.Collections.Generic.List[string]

  $sec = Get-SectionHtml $html $c.id
  if (-not $sec){
    Write-Host ("[FAIL] section #" + $c.id + " not found as <section id=...>")
    $report.Add("[FAIL] #" + $c.id + " section not found")
    $passAll = $false
    continue
  }

  if (-not ([regex]::IsMatch($sec, $c.rep, [Text.RegularExpressions.RegexOptions]::IgnoreCase))){
    $miss.Add("missing repeater: " + $c.rep)
    $secPass = $false
  }

  foreach ($m in $c.must){
    if (-not ([regex]::IsMatch($sec, $m, [Text.RegularExpressions.RegexOptions]::IgnoreCase))){
      $miss.Add("MISS: " + $m)
      $secPass = $false
    }
  }

  if ($secPass){
    Write-Host ("[OK]  #" + $c.id + " (repeater + required binds present)")
    $report.Add("[OK]  #" + $c.id)
  } else {
    Write-Host ("[FAIL] #" + $c.id)
    $report.Add("[FAIL] #" + $c.id)
    foreach ($line in $miss){
      Write-Host ("      " + $line)
      $report.Add("      " + $line)
    }
    $passAll = $false
  }

  Write-Host ""
  $report.Add("")
}

Write-Host ("PASS: " + $passAll)

$out = Join-Path $outDir "handoff_verify_custom_attrs.txt"
$report.Add("PASS: " + $passAll)
$report | Set-Content -Encoding UTF8 -LiteralPath $out
Write-Host ("OK: wrote " + $out)

if (-not $passAll){
  exit 1
}
