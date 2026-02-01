param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-SectionHtml([string]$html, [string]$id){
  $rx = '<section[^>]*\sid\s*=\s*["'']' + [regex]::Escape($id) + '["''][\s\S]*?</section>'
  $m = [regex]::Match($html, $rx, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($m.Success) { return $m.Value }
  return ""
}

$root = Get-Location
$latest = Join-Path $root "docs\import\webflow-export\latest"
$zip = Get-ChildItem -LiteralPath $root -Filter "*.webflow.zip" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1

$work = $latest
if (-not (Test-Path -LiteralPath $latest) -and $zip){
  # extract to local artifacts
  $art = Join-Path $root ".local_artifacts"
  if (-not (Test-Path -LiteralPath $art)) { New-Item -ItemType Directory -Path $art | Out-Null }
  $ts = Get-Date -Format "yyyyMMdd-HHmmss"
  $work = Join-Path $art ("_verify_export_" + $ts)
  New-Item -ItemType Directory -Path $work | Out-Null
  Expand-Archive -LiteralPath $zip.FullName -DestinationPath $work -Force
}

# pick an HTML file (prefer index.html)
$htmlFile = Get-ChildItem -LiteralPath $work -Recurse -Filter "index.html" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $htmlFile){
  $htmlFile = Get-ChildItem -LiteralPath $work -Recurse -Filter "*.html" | Select-Object -First 1
}
if (-not $htmlFile){ throw "No HTML found in: $work" }

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

foreach ($c in $checks){
  $sec = Get-SectionHtml $html $c.id
  if (-not $sec){
    Write-Host ("[FAIL] section #" + $c.id + " not found as <section id=...>")
    $passAll = $false
    continue
  }

  if (-not ([regex]::IsMatch($sec, $c.rep, [Text.RegularExpressions.RegexOptions]::IgnoreCase))){
    Write-Host ("[FAIL] #" + $c.id + " missing repeater: " + $c.rep)
    $passAll = $false
  } else {
    Write-Host ("[OK]  #" + $c.id + " repeater found")
  }

  foreach ($m in $c.must){
    if (-not ([regex]::IsMatch($sec, $m, [Text.RegularExpressions.RegexOptions]::IgnoreCase))){
      Write-Host ("      [MISS] " + $m)
      $passAll = $false
    }
  }

  if ($passAll){
    Write-Host ("      bindings look OK")
  } else {
    Write-Host ("      bindings need attention (see MISS above)")
  }

  Write-Host ""
}

if ($passAll){
  Write-Host "PASS: All required custom attributes present."
} else {
  Write-Host "FAIL: Missing required custom attributes (see above)."
}

# write report to latest (if exists)
if (Test-Path -LiteralPath $latest){
  $out = Join-Path $latest "handoff_verify_custom_attrs.txt"
  "PASS: " + $passAll | Set-Content -Encoding UTF8 -LiteralPath $out
  Write-Host ("OK: wrote " + $out)
}
