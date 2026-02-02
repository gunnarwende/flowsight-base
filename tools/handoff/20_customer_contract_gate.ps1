param(
  [string]$Customer = "template-on"
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

function GetObj($o, $prop) {
  if ($null -eq $o) { return $null }
  try { return $o.$prop } catch { return $null }
}

function AssertNonEmptyString($val, $path) {
  if ($null -eq $val -or -not ($val -is [string]) -or $val.Trim().Length -lt 1) { Fail("$path must be non-empty string"); return }
  Ok($path)
}

function AssertArrayMin($val, $path, $min) {
  if ($null -eq $val -or -not ($val -is [System.Collections.IEnumerable])) { Fail("$path must be array"); return }
  $arr = @($val)
  if ($arr.Count -lt $min) { Fail("$path must have >= $min items"); return }
  Ok("$path (count=$($arr.Count))")
  return $arr
}

function AssertE164($val, $path) {
  if ($null -eq $val -or -not ($val -is [string]) -or $val -notmatch '^\+[0-9]{6,}$') { Fail("$path must be e164 like +4144..."); return }
  Ok($path)
}

$script:hasFail = $false

$path = Join-Path (Join-Path $PSScriptRoot "..\..\customers") $Customer
$jsonPath = Join-Path $path "customer.json"

if (-not (Test-Path $jsonPath)) {
  throw "customer.json not found: $jsonPath"
}

$j = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

# business
AssertNonEmptyString (GetObj $j.business "name") "business.name"
AssertNonEmptyString (GetObj $j.business "region_label") "business.region_label"
AssertNonEmptyString (GetObj (GetObj (GetObj $j.business "brand") "logo") "src") "business.brand.logo.src"

# hero
AssertNonEmptyString (GetObj $j.hero "headline") "hero.headline"
AssertNonEmptyString (GetObj $j.hero "subline") "hero.subline"

# services (max 6 enforced here until core.js has hard cap)
$svc = AssertArrayMin (GetObj $j.services "items") "services.items" 1
if ($svc -and $svc.Count -gt 6) { Fail("services.items must be <= 6 (currently $($svc.Count))") }
if ($svc) {
  foreach ($it in $svc) {
    AssertNonEmptyString (GetObj $it "title") "services.items[].title"
    AssertNonEmptyString (GetObj $it "text")  "services.items[].text"
  }
}

# process
$proc = AssertArrayMin (GetObj $j.process "items") "process.items" 1
if ($proc) {
  foreach ($it in $proc) {
    AssertNonEmptyString (GetObj $it "title") "process.items[].title"
    AssertNonEmptyString (GetObj $it "text")  "process.items[].text"
  }
}

# areas
$areas = AssertArrayMin (GetObj $j.areas "items") "areas.items" 1
if ($areas) {
  foreach ($it in $areas) { AssertNonEmptyString (GetObj $it "title") "areas.items[].title" }
}

# trustBadges
$tb = AssertArrayMin (GetObj $j.trustBadges "items") "trustBadges.items" 1
if ($tb) {
  foreach ($it in $tb) {
    AssertNonEmptyString (GetObj $it "title") "trustBadges.items[].title"
    AssertNonEmptyString (GetObj $it "text")  "trustBadges.items[].text"
  }
}

# trust.reviews
$rv = AssertArrayMin (GetObj (GetObj $j.trust "reviews") "items") "trust.reviews.items" 1
if ($rv) {
  foreach ($it in $rv) {
    AssertNonEmptyString (GetObj $it "author") "trust.reviews.items[].author"
    AssertNonEmptyString (GetObj $it "text")   "trust.reviews.items[].text"
  }
}

# cases (photos >= 3)
$cs = AssertArrayMin (GetObj $j.cases "items") "cases.items" 1
if ($cs) {
  foreach ($it in $cs) {
    AssertNonEmptyString (GetObj $it "title") "cases.items[].title"
    AssertNonEmptyString (GetObj $it "text")  "cases.items[].text"
    $photos = AssertArrayMin (GetObj $it "photos") "cases.items[].photos" 3
    if ($photos) {
      for ($i=0; $i -lt 3; $i++) {
        AssertNonEmptyString (GetObj $photos[$i] "src") "cases.items[].photos[$i].src"
      }
    }
  }
}

# certs
$certs = AssertArrayMin (GetObj $j.certs "items") "certs.items" 1
if ($certs) { foreach ($it in $certs) { AssertNonEmptyString (GetObj $it "title") "certs.items[].title" } }

# faq
$fq = AssertArrayMin (GetObj $j.faq "items") "faq.items" 1
if ($fq) {
  foreach ($it in $fq) {
    AssertNonEmptyString (GetObj $it "title") "faq.items[].title"
    AssertNonEmptyString (GetObj $it "text")  "faq.items[].text"
  }
}

# contact
AssertNonEmptyString (GetObj (GetObj (GetObj $j.contact "phones") "emergency") "display") "contact.phones.emergency.display"
AssertE164          (GetObj (GetObj (GetObj $j.contact "phones") "emergency") "e164")    "contact.phones.emergency.e164"
AssertNonEmptyString (GetObj (GetObj (GetObj $j.contact "phones") "normal") "display")   "contact.phones.normal.display"
AssertE164          (GetObj (GetObj (GetObj $j.contact "phones") "normal") "e164")       "contact.phones.normal.e164"
AssertNonEmptyString (GetObj (GetObj $j.contact "address") "street")                     "contact.address.street"
AssertNonEmptyString (GetObj (GetObj $j.contact "opening_hours") "label")                "contact.opening_hours.label"
AssertNonEmptyString (GetObj (GetObj $j.contact "map") "embed_url")                      "contact.map.embed_url"
AssertNonEmptyString (GetObj (GetObj $j.contact "form") "headline")                      "contact.form.headline"

# cta labels
AssertNonEmptyString (GetObj (GetObj $j.cta "labels") "emergency") "cta.labels.emergency"
AssertNonEmptyString (GetObj (GetObj $j.cta "labels") "normal")    "cta.labels.normal"
AssertNonEmptyString (GetObj (GetObj $j.cta "labels") "review")    "cta.labels.review"

# links
AssertNonEmptyString (GetObj $j.links "google_review") "links.google_review"
AssertNonEmptyString (GetObj (GetObj $j.links "legal") "impressum_url") "links.legal.impressum_url"
AssertNonEmptyString (GetObj (GetObj $j.links "legal") "privacy_url")   "links.legal.privacy_url"

if ($script:hasFail) { exit 1 }
Write-Host "ALL OK: customer contract passes ($Customer)" -ForegroundColor Green
exit 0
