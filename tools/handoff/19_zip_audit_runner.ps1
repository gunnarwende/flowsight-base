param(
  [string]$ZipPath = "",
  [switch]$Open
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Ensure-Dir([string]$p){
  if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}
function ReadAll([string]$p){ Get-Content -LiteralPath $p -Raw -Encoding UTF8 }
function WriteUtf8([string]$p, [string]$s){ Set-Content -LiteralPath $p -Value $s -Encoding UTF8 }
function Has([string]$s, [string]$pattern){
  [regex]::IsMatch($s, $pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..") | Select-Object -ExpandProperty Path

# pick ZIP (default: repo root sanitar-template.webflow.zip, else newest *.webflow.zip)
if ([string]::IsNullOrWhiteSpace($ZipPath)) {
  $cand = Join-Path $repoRoot "sanitar-template.webflow.zip"
  if (Test-Path -LiteralPath $cand) {
    $ZipPath = $cand
  } else {
    $latest = Get-ChildItem -LiteralPath $repoRoot -File -Filter "*.webflow.zip" |
      Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { throw "No *.webflow.zip found in repo root: $repoRoot" }
    $ZipPath = $latest.FullName
  }
}
if (-not (Test-Path -LiteralPath $ZipPath)) { throw "Missing ZIP: $ZipPath" }

# extract
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$localArtifacts = Join-Path $repoRoot ".local_artifacts"
Ensure-Dir $localArtifacts
$extractDir = Join-Path $localArtifacts ("_wf_zip_audit_{0}" -f $ts)
Ensure-Dir $extractDir
Expand-Archive -LiteralPath $ZipPath -DestinationPath $extractDir -Force

# find index.html
$index = Get-ChildItem -LiteralPath $extractDir -Recurse -File -Filter "index.html" | Select-Object -First 1
if (-not $index) { throw "index.html not found in extracted ZIP: $extractDir" }

$html = ReadAll $index.FullName

# output locations
$exportRoot = Join-Path $repoRoot "docs\import\webflow-export"
Ensure-Dir $exportRoot
Ensure-Dir (Join-Path $exportRoot "latest")
$reportTsDir = Join-Path $exportRoot ("zip-audit\{0}" -f $ts)
Ensure-Dir $reportTsDir

$reportName = "handoff_zip_audit_report.txt"
$reportLatest = Join-Path (Join-Path $exportRoot "latest") $reportName
$reportStamped = Join-Path $reportTsDir $reportName

# collect section ids
$secRx = '<section\b[^>]*\bid\s*=\s*["'']([^"''\s>]+)["''][^>]*>'
$secMatches = [regex]::Matches($html, $secRx, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
$sections = @()
foreach ($m in $secMatches) { $sections += $m.Groups[1].Value }
$sections = $sections | Where-Object { $_ } | Sort-Object -Unique

# duplicate IDs (any element id=)
$idRx = '\bid\s*=\s*["'']([^"''\s>]+)["'']'
$idMatches = [regex]::Matches($html, $idRx, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
$idCounts = @{}
foreach ($m in $idMatches) {
  $k = $m.Groups[1].Value
  if (-not $idCounts.ContainsKey($k)) { $idCounts[$k] = 0 }
  $idCounts[$k]++
}
$dupIds = $idCounts.GetEnumerator() | Where-Object { $_.Value -gt 1 } | Sort-Object Name

# contract checks (minimal + high-signal)
$needSections = @("hero","services","process","areas","trust-badges","reviews","cases","certs","faq","contact","footer")
$needNavKeys  = @("start","services","process","contact")

# simple helpers to slice a section block
function GetSectionSlice([string]$doc, [string]$id){
  $rx = '<section\b[^>]*\bid\s*=\s*["'']' + [regex]::Escape($id) + '["''][^>]*>.*?</section>'
  $m = [regex]::Match($doc, $rx, [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::Singleline)
  if ($m.Success) { return $m.Value }
  return ""
}

# section binding requirements (your current contract)
$checks = @(
  @{ id="services"; must=@('data-repeat\s*=\s*["'']services\.items["'']','data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="process";  must=@('data-repeat\s*=\s*["'']process\.items["'']','data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="areas";    must=@('data-repeat\s*=\s*["'']areas\.items["'']','data-template','data-bind\s*=\s*["'']title["'']') },
  @{ id="cases";    must=@('data-repeat\s*=\s*["'']cases\.items["'']','data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') },
  @{ id="certs";    must=@('data-repeat\s*=\s*["'']certs\.items["'']','data-template','data-bind\s*=\s*["'']title["'']') },
  @{ id="faq";      must=@('data-repeat\s*=\s*["'']faq\.items["'']','data-template','data-bind\s*=\s*["'']title["'']','data-bind\s*=\s*["'']text["'']') }
)

$lines = New-Object System.Collections.Generic.List[string]
$fail = $false

$lines.Add("== ZIP AUDIT (ZIP-first) ==")
$lines.Add(("ZIP:       {0}" -f $ZipPath))
$lines.Add(("Extracted: {0}" -f $extractDir))
$lines.Add(("HTML:      {0}" -f $index.FullName))
$lines.Add("")

$lines.Add("== SECTIONS FOUND (section[id]) ==")
foreach ($s in $sections) { $lines.Add("- " + $s) }
$lines.Add("")

$lines.Add("== REQUIRED SECTIONS (contract) ==")
foreach ($s in $needSections) {
  $ok = $sections -contains $s
  $lines.Add(("{0}: {1}" -f $s, ($(if($ok){"OK"}else{"MISS"}))))
  if (-not $ok) { $fail = $true }
}
$lines.Add("")

$lines.Add("== DUPLICATE IDs (any element) ==")
if ($dupIds.Count -eq 0) { $lines.Add("none") } else {
  $fail = $true
  foreach ($d in $dupIds) { $lines.Add(("{0} x{1}" -f $d.Name, $d.Value)) }
}
$lines.Add("")

$lines.Add("== HEADER NAV KEYS (data-nav) ==")
foreach ($k in $needNavKeys) {
  $ok = Has $html ('data-nav\s*=\s*["'']' + [regex]::Escape($k) + '["'']')
  $lines.Add(("{0}: {1}" -f $k, ($(if($ok){"OK"}else{"MISS"}))))
  if (-not $ok) { $fail = $true }
}
$lines.Add("")

$lines.Add("== FORM (contact) ==")
$hasTextareaMsg = Has $html '<textarea[^>]*\bname\s*=\s*["'']message["'']'
$hasInputMsg    = Has $html '<input[^>]*\bname\s*=\s*["'']message["'']'
$lines.Add(("message textarea: {0}" -f $(if($hasTextareaMsg){"OK"}else{"MISS"})))
if ($hasInputMsg -and -not $hasTextareaMsg) { $lines.Add("WARN: message is input (should be textarea)"); $fail = $true }
$lines.Add("")

$lines.Add("== SECTION BINDINGS (repeat/template/binds) ==")
foreach ($c in $checks) {
  $slice = GetSectionSlice $html $c.id
  if ([string]::IsNullOrWhiteSpace($slice)) {
    $lines.Add(("[FAIL] #{0}: missing section block" -f $c.id))
    $fail = $true
    continue
  }
  $lines.Add(("#" + $c.id))
  foreach ($p in $c.must) {
    $ok = Has $slice $p
    $lines.Add(("  {0}: {1}" -f $p, ($(if($ok){"OK"}else{"MISS"}))))
    if (-not $ok) { $fail = $true }
  }
  $lines.Add("")
}

# bad tel export pattern
if (Has $html 'href\s*=\s*["'']https?://tel\.:') {
  $lines.Add("WARN: found href='https://tel.:' (fix Webflow phone link settings)")
  $lines.Add("")
  $fail = $true
}

WriteUtf8 $reportStamped ($lines -join "`r`n")
WriteUtf8 $reportLatest  ($lines -join "`r`n")

Write-Host ("OK: wrote -> {0}" -f $reportStamped)
Write-Host ("OK: wrote -> {0}" -f $reportLatest)

if ($Open) { notepad $reportLatest | Out-Null }

if ($fail) { exit 2 } else { exit 0 }
