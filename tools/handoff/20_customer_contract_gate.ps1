param(
  [string]$Customer = "template-on"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:Failed = $false
function OKLine([string]$m)   { Write-Host ("OK:   " + $m) -ForegroundColor Green }
function FAILLine([string]$m) { Write-Host ("FAIL: " + $m) -ForegroundColor Red; $script:Failed = $true }

# repo root = /tools/handoff -> up 2
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$customerPath = Join-Path (Join-Path (Join-Path $repoRoot "customers") $Customer) "customer.json"

Write-Host ("FS_GATE repoRoot:    " + $repoRoot) -ForegroundColor DarkGray
Write-Host ("FS_GATE customerPath:" + $customerPath) -ForegroundColor DarkGray

if (!(Test-Path $customerPath)) { throw "Missing customer.json: $customerPath" }

# --- RAW-first: cases.items MUST be JSON array ---
$raw = Get-Content $customerPath -Raw -Encoding UTF8
if ($raw -match '(?s)"cases"\s*:\s*\{.*?"items"\s*:\s*(\[|\{)') {
  $op = $Matches[1]
  Write-Host ("FS_GATE RAW cases.items opener: " + $op) -ForegroundColor DarkGray
  if ($op -ne "[") { FAILLine "cases.items must be JSON array (RAW opener=$op)" } else { OKLine "cases.items (RAW array)" }
} else {
  FAILLine "cases.items not found in RAW JSON"
}

# Parse object
$j = $raw | ConvertFrom-Json

# helper
function ReqStr($label, $val) {
  if ($null -eq $val -or ("" + $val).Trim().Length -eq 0) { FAILLine "$label missing/empty" } else { OKLine $label }
}
function ReqArr($label, $val) {
  if ($null -eq $val) { FAILLine "$label missing (null)"; return @() }
  # normalize: ALWAYS array in PS, even if 1 element got unwrapped somewhere
  $arr = @($val)
  OKLine ("$label (count=" + $arr.Count + ")")
  return $arr
}

# Required fields (same set wie vorher)
ReqStr "business.name" $j.business.name
ReqStr "business.region_label" $j.business.region_label
ReqStr "business.brand.logo.src" $j.business.brand.logo.src

ReqStr "hero.headline" $j.hero.headline
ReqStr "hero.subline"  $j.hero.subline

$services = ReqArr "services.items" $j.services.items
foreach ($it in $services) { ReqStr "services.items[].title" $it.title; ReqStr "services.items[].text" $it.text }

$proc = ReqArr "process.items" $j.process.items
foreach ($it in $proc) { ReqStr "process.items[].title" $it.title; ReqStr "process.items[].text" $it.text }

$areas = ReqArr "areas.items" $j.areas.items
foreach ($it in $areas) { ReqStr "areas.items[].title" $it.title }

$tb = ReqArr "trustBadges.items" $j.trustBadges.items
foreach ($it in $tb) { ReqStr "trustBadges.items[].title" $it.title; ReqStr "trustBadges.items[].text" $it.text }

$rev = ReqArr "trust.reviews.items" $j.trust.reviews.items
foreach ($it in $rev) { ReqStr "trust.reviews.items[].author" $it.author; ReqStr "trust.reviews.items[].text" $it.text }

# cases: normalize ALWAYS to array in PS (no type check anymore)
$casesItems = @()
if ($j.cases -and $null -ne $j.cases.items) { $casesItems = @($j.cases.items) }
if ($casesItems.Count -gt 0) {
  foreach ($it in $casesItems) { ReqStr "cases.items[].title" $it.title; ReqStr "cases.items[].text" $it.text }
}

$certs = ReqArr "certs.items" $j.certs.items
foreach ($it in $certs) { ReqStr "certs.items[].title" $it.title }

$faq = ReqArr "faq.items" $j.faq.items
foreach ($it in $faq) { ReqStr "faq.items[].title" $it.title; ReqStr "faq.items[].text" $it.text }

ReqStr "contact.phones.emergency.display" $j.contact.phones.emergency.display
ReqStr "contact.phones.emergency.e164"    $j.contact.phones.emergency.e164
ReqStr "contact.phones.normal.display"    $j.contact.phones.normal.display
ReqStr "contact.phones.normal.e164"       $j.contact.phones.normal.e164
ReqStr "contact.address.street"           $j.contact.address.street
ReqStr "contact.opening_hours.label"      $j.contact.opening_hours.label
ReqStr "contact.map.embed_url"            $j.contact.map.embed_url
ReqStr "contact.form.headline"            $j.contact.form.headline

ReqStr "cta.labels.emergency" $j.cta.labels.emergency
ReqStr "cta.labels.normal"    $j.cta.labels.normal
ReqStr "cta.labels.review"    $j.cta.labels.review

ReqStr "links.google_review"       $j.links.google_review
ReqStr "links.legal.impressum_url" $j.links.legal.impressum_url
ReqStr "links.legal.privacy_url"   $j.links.legal.privacy_url

if ($script:Failed) { exit 1 } else { exit 0 }

