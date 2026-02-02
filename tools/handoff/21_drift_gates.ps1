param(
  [string]$ZipAuditDirPattern = "_wf_zip_audit_*"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail($msg) {
  Write-Host "FAIL: $msg" -ForegroundColor Red
  $script:hasFail = $true
}

function Ok($msg) {
  Write-Host "OK:   $msg" -ForegroundColor Green
}

$script:hasFail = $false

# pick latest extracted index.html from zip-audit runner
$zipDir = Get-ChildItem ".\.local_artifacts" -Directory |
  Where-Object { $_.Name -like $ZipAuditDirPattern } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $zipDir) { throw "No zip audit dir found in .local_artifacts (run 19_zip_audit_runner.ps1 first)" }

$index = Join-Path $zipDir.FullName "index.html"
if (-not (Test-Path $index)) { throw "index.html missing: $index" }

$raw = Get-Content $index -Raw -Encoding UTF8

# A) Forbidden custom attrs
$forbidden = @(
  'data-bind-image=',
  'data-bind-alt=',
  'data-slot-link=',
  'data-slot-map=',
  'data-slot-='
)
foreach ($f in $forbidden) {
  if ($raw -match [regex]::Escape($f)) { Fail("forbidden attr found: $f") } else { Ok("no forbidden attr: $f") }
}

# B) Known drift typos / form drift
$drifts = @(
  'process.itmens',
  'id="field"',
  'name="field"',
  'name="Field"'
)
foreach ($d in $drifts) {
  if ($raw -match [regex]::Escape($d)) { Fail("drift found: $d") } else { Ok("no drift: $d") }
}

# C) Placeholder copy (hard fail)
$place = @('Button Text','Example Text')
foreach ($p in $place) {
  if ($raw -match [regex]::Escape($p)) { Fail("placeholder found: $p") } else { Ok("no placeholder: $p") }
}

# D) href="#" without router (data-cta|data-nav|data-slot-href)
# (quick heuristic; keeps you from shipping dead buttons)
$badHref = Select-String -Path $index -Pattern '<a[^>]+href="#"[^>]*>' -AllMatches
if ($badHref) {
  foreach ($m in $badHref.Matches) {
    $tag = $m.Value
    if (($tag -notmatch 'data-cta=') -and ($tag -notmatch 'data-nav=') -and ($tag -notmatch 'data-slot-href=')) {
      Fail("dead href='#' anchor without router attr: $tag")
      break
    }
  }
  if (-not $script:hasFail) { Ok("href='#' anchors are routed (data-cta/nav/slot-href)") }
} else {
  Ok("no href='#' anchors")
}

# E) inline style in exported HTML (should be none)
if ($raw -match ' style="') { Fail("inline style attribute found in HTML export") } else { Ok("no inline styles") }

if ($script:hasFail) { exit 1 }
Write-Host "ALL OK: drift gates pass (ZIP-first)" -ForegroundColor Green
exit 0
