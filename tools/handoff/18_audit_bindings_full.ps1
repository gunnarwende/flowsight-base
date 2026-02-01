<# 
FlowSight: Full bindings audit (ZIP-first) — Header → Footer
Writes report: handoff_bindings_audit_full.txt (in latest export dir)
Goals:
- list ALL custom data-* binding attributes + where they live (section mapping)
- validate anchor targets exist
- flag placeholder/static copy that likely needs data-bind (heuristic)
- PS 5.1 safe (no ConvertFrom-Json -Depth, no PS7-only features)
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-RepoRoot {
  $here = Split-Path -Parent $PSScriptRoot           # ...\tools\handoff
  $root = Resolve-Path -LiteralPath (Join-Path $here "..\..")
  return $root.Path
}

function Get-LatestExportDir([string]$repo) {
  $exportRoot = Join-Path $repo "docs\import\webflow-export"
  if (-not (Test-Path -LiteralPath $exportRoot)) { throw "Missing export root: $exportRoot" }

  $latest = Join-Path $exportRoot "latest"
  if (Test-Path -LiteralPath $latest) { return (Resolve-Path -LiteralPath $latest).Path }

  $dirs = Get-ChildItem -LiteralPath $exportRoot -Directory | Sort-Object LastWriteTime -Descending
  foreach ($d in $dirs) {
    $idx = Join-Path $d.FullName "index.html"
    if (Test-Path -LiteralPath $idx) { return $d.FullName }
  }
  throw "No export dir with index.html found under: $exportRoot"
}

function Ensure-Dir([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

function Get-LineNumber([string]$s, [int]$idx) {
  if ($idx -le 0) { return 1 }
  $pre = $s.Substring(0, [Math]::Min($idx, $s.Length))
  return ($pre -split "`n").Count
}

function Clean-Text([string]$htmlInner) {
  $t = [regex]::Replace($htmlInner, "<[^>]+>", " ")
  $t = $t -replace "\s+", " "
  try { $t = [System.Net.WebUtility]::HtmlDecode($t) } catch {}
  return $t.Trim()
}

$repo = Get-RepoRoot

$zip = Join-Path $repo "sanitar-template.webflow.zip"
$exportDir = Get-LatestExportDir $repo

$artifacts = Join-Path $repo ".local_artifacts"
Ensure-Dir $artifacts

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$stage = Join-Path $artifacts ("_wf_audit_zip_{0}" -f $ts)

$indexPath = $null
$sourceLabel = $null

if (Test-Path -LiteralPath $zip) {
  Ensure-Dir $stage
  Expand-Archive -LiteralPath $zip -DestinationPath $stage -Force
  $candidate = Join-Path $stage "index.html"
  if (-not (Test-Path -LiteralPath $candidate)) {
    # try: sometimes zip has a single top folder
    $candidate = Get-ChildItem -LiteralPath $stage -Recurse -File -Filter "index.html" | Select-Object -First 1
    if ($null -eq $candidate) { throw "index.html not found after zip extract: $zip" }
    $indexPath = $candidate.FullName
  } else {
    $indexPath = $candidate
  }
  $sourceLabel = "ZIP"
} else {
  $candidate = Join-Path $exportDir "index.html"
  if (-not (Test-Path -LiteralPath $candidate)) { throw "Missing index.html in export dir: $exportDir" }
  $indexPath = $candidate
  $sourceLabel = "EXPORT"
}

$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $indexPath

# --- section mapping (by nearest preceding section/div id) ---
$secRx = [regex]::new("<(section|div)\b[^>]*\sid\s*=\s*[""']([^""']+)[""'][^>]*>", [Text.RegularExpressions.RegexOptions]::IgnoreCase)
$secMatches = $secRx.Matches($html)

$sections = @()
foreach ($m in $secMatches) {
  $sections += [pscustomobject]@{
    Id    = $m.Groups[2].Value
    Index = $m.Index
  }
}
$sections = $sections | Sort-Object Index

function Get-SectionForIndex([int]$i, $sections) {
  $current = "__header"
  foreach ($s in $sections) {
    if ($s.Index -le $i) { $current = $s.Id } else { break }
  }
  return $current
}

# expected top-level section IDs (contract)
$expected = @("hero","services","process","areas","trust-badges","reviews","cases","certs","faq","contact","footer")
$foundIds = @($sections | Select-Object -ExpandProperty Id -Unique)

$missingExpected = @()
foreach ($e in $expected) { if ($foundIds -notcontains $e) { $missingExpected += $e } }

# --- custom attribute audit ---
$attrRx = [regex]::new("\s(data-(?:bind|if|repeat|href|src|text|html|attr|class|style))\s*=\s*[""']([^""']+)[""']",
  [Text.RegularExpressions.RegexOptions]::IgnoreCase)

$attrMatches = $attrRx.Matches($html)

$attrRows = New-Object System.Collections.Generic.List[object]
foreach ($m in $attrMatches) {
  $idx = $m.Index
  $sec = Get-SectionForIndex $idx $sections
  $line = Get-LineNumber $html $idx

  $snipStart = [Math]::Max(0, $idx - 80)
  $snipLen = [Math]::Min(220, $html.Length - $snipStart)
  $snip = $html.Substring($snipStart, $snipLen) -replace "(\r?\n)+", " "
  $snip = ($snip -replace "\s+", " ").Trim()

  $attrRows.Add([pscustomobject]@{
    Section = $sec
    Line    = $line
    Attr    = $m.Groups[1].Value
    Value   = $m.Groups[2].Value
    Snip    = $snip
  })
}

# --- anchor audit (href="#...") ---
$anchorRx = [regex]::new("<a\b[^>]*\shref\s*=\s*[""']#([^""']+)[""'][^>]*>", [Text.RegularExpressions.RegexOptions]::IgnoreCase)
$anchorMatches = $anchorRx.Matches($html)

$brokenAnchors = New-Object System.Collections.Generic.List[object]
foreach ($m in $anchorMatches) {
  $id = $m.Groups[1].Value.Trim()
  if ([string]::IsNullOrWhiteSpace($id)) { continue }
  if ($foundIds -notcontains $id) {
    $idx = $m.Index
    $sec = Get-SectionForIndex $idx $sections
    $line = Get-LineNumber $html $idx
    $brokenAnchors.Add([pscustomobject]@{ Section=$sec; Line=$line; Target=$id })
  }
}

# --- placeholder/static copy heuristic (only "suspicious" strings) ---
$textRx = [regex]::new("<(h1|h2|h3|p|a|button|label)\b([^>]*)>(.*?)</\1>",
  [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::Singleline)

$textMatches = $textRx.Matches($html)

$badTokens = @("lorem","ipsum","item","button text","about","services2","process step","areas item","faq item","cert item")
$staticFlags = New-Object System.Collections.Generic.List[object]

foreach ($m in $textMatches) {
  $tag = $m.Groups[1].Value.ToLowerInvariant()
  $attrs = $m.Groups[2].Value
  $inner = $m.Groups[3].Value

  $text = Clean-Text $inner
  if ($text.Length -lt 3) { continue }

  $hasBind = ($attrs -match "data-(bind|href|src|text|html)\s*=")
  if ($hasBind) { continue }

  $lt = $text.ToLowerInvariant()
  $hit = $false
  foreach ($t in $badTokens) {
    if ($lt -like "*$t*") { $hit = $true; break }
  }
  if (-not $hit) { continue }

  $idx = $m.Index
  $sec = Get-SectionForIndex $idx $sections
  $line = Get-LineNumber $html $idx

  $staticFlags.Add([pscustomobject]@{
    Section = $sec
    Line    = $line
    Tag     = $tag
    Text    = $text
  })
}

# --- form audit (message field) ---
$formNotes = @()
if ($html -match "<textarea\b[^>]*\bname\s*=\s*[""']message[""']") {
  $formNotes += "OK: message field is textarea"
} elseif ($html -match "<input\b[^>]*\bname\s*=\s*[""']message[""']") {
  $formNotes += "WARN: message field is input (should be textarea)"
} else {
  $formNotes += "WARN: message field not found by name='message'"
}

# --- report build ---
$report = New-Object System.Collections.Generic.List[string]
$report.Add("== BINDINGS AUDIT (ZIP-first) ==")
$report.Add(("Run: {0}" -f (Get-Date)))
$report.Add(("Source: {0}" -f $sourceLabel))
$report.Add(("ZIP:    {0}" -f $zip))
$report.Add(("Index:  {0}" -f $indexPath))
$report.Add(("Export: {0}" -f $exportDir))
$report.Add("")

$report.Add("---- SECTION IDS (found) ----")
$report.Add(($foundIds | Sort-Object | ForEach-Object { "- " + $_ }) -join "`r`n")
$report.Add("")

$report.Add("---- EXPECTED IDS (missing) ----")
if ($missingExpected.Count -eq 0) { $report.Add("none") }
else { $report.Add(($missingExpected | ForEach-Object { "- " + $_ }) -join "`r`n") }
$report.Add("")

$report.Add("---- FORM CHECKS ----")
$report.Add(($formNotes -join "`r`n"))
$report.Add("")

$report.Add("---- BROKEN ANCHORS (href '#...') ----")
if ($brokenAnchors.Count -eq 0) {
  $report.Add("none")
} else {
  foreach ($b in $brokenAnchors) {
    $report.Add(("{0}:{1} -> #{2}" -f $b.Section, $b.Line, $b.Target))
  }
}
$report.Add("")

$report.Add("---- CUSTOM ATTRIBUTES (all) ----")
if ($attrRows.Count -eq 0) {
  $report.Add("none found")
} else {
  $grouped = $attrRows | Group-Object Section
  foreach ($g in ($grouped | Sort-Object Name)) {
    $report.Add(("## {0} ({1})" -f $g.Name, $g.Count))
    foreach ($r in ($g.Group | Sort-Object Line)) {
      $report.Add(("{0,5} | {1}=""{2}"" | {3}" -f $r.Line, $r.Attr, $r.Value, $r.Snip))
    }
    $report.Add("")
  }
}

$report.Add("---- STATIC/PLACEHOLDER COPY (heuristic) ----")
if ($staticFlags.Count -eq 0) {
  $report.Add("none flagged")
} else {
  $sg = $staticFlags | Group-Object Section
  foreach ($g in ($sg | Sort-Object Name)) {
    $report.Add(("## {0} ({1})" -f $g.Name, $g.Count))
    foreach ($r in ($g.Group | Sort-Object Line)) {
      $report.Add(("{0,5} | <{1}> {2}" -f $r.Line, $r.Tag, $r.Text))
    }
    $report.Add("")
  }
}

# write report into export dir (and ensure it exists)
Ensure-Dir $exportDir
$out = Join-Path $exportDir "handoff_bindings_audit_full.txt"
Set-Content -Encoding UTF8 -LiteralPath $out -Value ($report -join "`r`n")

Write-Host ("OK: wrote {0}" -f $out)

# also write a copy into staging dir if we used ZIP
if ($sourceLabel -eq "ZIP") {
  $out2 = Join-Path $stage "handoff_bindings_audit_full.txt"
  Set-Content -Encoding UTF8 -LiteralPath $out2 -Value ($report -join "`r`n")
  Write-Host ("OK: wrote {0}" -f $out2)
}
