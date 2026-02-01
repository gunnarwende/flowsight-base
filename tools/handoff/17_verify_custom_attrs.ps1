param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-SectionHtml([string]$html, [string]$id){
  $rx = '<section[^>]*\sid\s*=\s*["'']' + [regex]::Escape($id) + '["''][\s\S]*?</section>'
  $m = [regex]::Match($html, $rx, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($m.Success) { return $m.Value }
  return ""
}

$root = (Get-Location)
$latest = Join-Path $root "docs\import\webflow-export\latest"
if (-not (Test-Path -LiteralPath $latest)) { throw "Missing export dir: $latest" }

$htmlFile = Get-ChildItem -LiteralPath $latest -Recurse -Filter "index.html" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $htmlFile){
  $htmlFile = Get-ChildItem -LiteralPath $latest -Recurse -Filter "*.html" | Select-Object -First 1
}
if (-not $htmlFile){ throw "No HTML found in: $latest" }

$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $htmlFile.FullName

$checks = @(
  @{ id="services"; rep='data-repeat\s*=\s*["'']services\.items["'']'; must=@('data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="process";  rep='data-repeat\s*=\s*["'']process\.items["'']';  must=@('data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="areas";    rep='data-repeat\s*=\s*["'']areas\.items["'']';    must=@('data-template','data-bind\s*=\s*["'']title["'']') },
  @{ id="certs";    rep='data-repeat\s*=\s*["'']certs\.items["'']';    must=@('data-template','data-bind\s*=\s*["'']title["'']') },
  @{ id="faq";      rep='data-repeat\s*=\s*["'']faq\.items["'']';      must=@('data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="cases";    rep='data-repeat\s*=\s*["'']cases\.items["'']';    must=@('data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']','data-bind-image\s*=\s*["'']photos\.0\.src["'']') }
)

Write-Host "== VERIFY CUSTOM ATTRIBUTES =="
Write-Host ("HTML: " + $htmlFile.FullName)
Write-Host ""

$passAll = $true
$report = New-Object System.Collections.Generic.List[string]
$report.Add("HTML: " + $htmlFile.FullName)
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
    foreach ($line in $miss){
      Write-Host ("      " + $line)
      $report.Add("      " + $line)
    }
    $passAll = $false
    $report.Add("[FAIL] #" + $c.id)
  }

  Write-Host ""
  $report.Add("")
}

Write-Host ("PASS: " + $passAll)

$out = Join-Path $latest "handoff_verify_custom_attrs.txt"
$report.Add("PASS: " + $passAll)
$report | Set-Content -Encoding UTF8 -LiteralPath $out
Write-Host ("OK: wrote " + $out)

if (-not $passAll){
  exit 1
}
