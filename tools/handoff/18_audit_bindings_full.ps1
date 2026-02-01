param(
  [string]$ZipPath = "",
  [string]$CustomerJsonPath = ""
)

$ErrorActionPreference = "Stop"

function RepoRootFromHere {
  # tools\handoff -> repo root
  return (Resolve-Path (Join-Path $(Split-Path -Parent \) "..")).Path
}

function Get-ByPath($obj, $path) {
  if ([string]::IsNullOrWhiteSpace($path)) { return $null }
  $parts = $path.Split('.') | Where-Object { $_ -and $_ -ne "" }
  $cur = $obj
  foreach ($p in $parts) {
    if ($null -eq $cur) { return $null }

    # array index support: e.g. items.0.title
    if ($p -match '^\d+$') {
      $i = [int]$p
      if ($cur -is [System.Collections.IList] -and $cur.Count -gt $i) { $cur = $cur[$i] } else { return $null }
      continue
    }

    if ($cur -is [System.Collections.IDictionary]) {
      if ($cur.Contains($p)) { $cur = $cur[$p] } else { return $null }
      continue
    }

    $prop = $cur.PSObject.Properties[$p]
    if ($null -eq $prop) { return $null }
    $cur = $prop.Value
  }
  return $cur
}

function Find-AttrValues($html, $attrName) {
  $rx = "(?i)\b" + [regex]::Escape($attrName) + "\s*=\s*['""]([^'""]+)['""]"
  return ([regex]::Matches($html, $rx) | ForEach-Object { $_ .Groups[1].Value } )
}

function Get-SectionChunk($html, $id) {
  $pat1 = "id="$id""
  $pat2 = "id='$id'"
  $pos = $html.IndexOf($pat1)
  if ($pos -lt 0) { $pos = $html.IndexOf($pat2) }
  if ($pos -lt 0) { return $null }

  $start = $html.LastIndexOf("<section", $pos)
  if ($start -lt 0) { return $null }

  $end = $html.IndexOf("</section>", $pos)
  if ($end -lt 0) { return $null }

  return $html.Substring($start, ($end - $start) + 10)
}

function Has-Regex($s, $pattern) {
  return [regex]::IsMatch($s, $pattern, [Text.RegularExpressions.RegexOptions]::Singleline -bor [Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

$repo = RepoRootFromHere

# ZIP resolve (ZIP-first)
if ([string]::IsNullOrWhiteSpace($ZipPath)) {
  $zips = Get-ChildItem -LiteralPath $repo -File -Filter "*.webflow.zip" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
  if (-not $zips -or $zips.Count -eq 0) { throw "No *.webflow.zip found in repo root: $repo" }
  $ZipPath = $zips[0].FullName
}
if (-not (Test-Path -LiteralPath $ZipPath)) { throw "ZIP not found: $ZipPath" }

# customer json resolve
if ([string]::IsNullOrWhiteSpace($CustomerJsonPath)) {
  $CustomerJsonPath = Join-Path $repo "customers\template-on\customer.json"
}
if (-not (Test-Path -LiteralPath $CustomerJsonPath)) { throw "customer.json not found: $CustomerJsonPath" }

# extract
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$art = Join-Path $repo ".local_artifacts\_wf_audit_zip_$ts"
New-Item -ItemType Directory -Force -Path $art | Out-Null
Expand-Archive -LiteralPath $ZipPath -DestinationPath $art -Force

# find index.html
$index = Get-ChildItem -LiteralPath $art -Recurse -File -Filter "index.html" | Select-Object -First 1
if (-not $index) { throw "index.html not found in extracted ZIP" }

$html = Get-Content -LiteralPath $index.FullName -Raw -Encoding UTF8

# load customer.json
$raw = Get-Content -LiteralPath $CustomerJsonPath -Raw -Encoding UTF8
try {
  $data = $raw | ConvertFrom-Json
} catch {
  # fallback serializer (rare)
  Add-Type -AssemblyName System.Web.Extensions
  $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
  $ser.MaxJsonLength = 50MB
  $data = $ser.DeserializeObject($raw)
}

$lines = New-Object System.Collections.Generic.List[string]
$pass = $true

function Ok($msg){ $lines.Add("[OK]  " + $msg) | Out-Null }
function Warn($msg){ $lines.Add("[WARN] " + $msg) | Out-Null }
function Fail($msg){ $lines.Add("[FAIL] " + $msg) | Out-Null; $script:pass = $false }

$lines.Add("== FULL BINDINGS AUDIT (ZIP-first) ==") | Out-Null
$lines.Add(("ZIP:  {0}" -f $ZipPath)) | Out-Null
$lines.Add(("HTML: {0}" -f $index.FullName)) | Out-Null
$lines.Add(("JSON: {0}" -f $CustomerJsonPath)) | Out-Null
$lines.Add("") | Out-Null

# Header nav href checks (anchors)
if (Has-Regex $html "href\s*=\s*['""]#hero['""]") { Ok "Header: link -> #hero" } else { Fail "Header: missing href '#hero' (Start)" }
if (Has-Regex $html "href\s*=\s*['""]#services['""]") { Ok "Header: link -> #services" } else { Fail "Header: missing href '#services' (Leistungen)" }
if (Has-Regex $html "href\s*=\s*['""]#process['""]") { Ok "Header: link -> #process" } else { Fail "Header: missing href '#process' (Ablauf)" }
if (Has-Regex $html "href\s*=\s*['""]#contact['""]") { Ok "Header: link -> #contact" } else { Fail "Header: missing href '#contact' (Kontakt)" }

$lines.Add("") | Out-Null

# Contract: required sections + expectations
$contract = @(
  @{ id="hero";        repeat="";                binds=@();                    slots=@("hero.headline","hero.subline"); ctas=@("emergency","normal"); map="" },
  @{ id="services";    repeat="services.items";  binds=@("title","text");      slots=@();                               ctas=@();                    map="" },
  @{ id="process";     repeat="process.items";   binds=@("title","text");      slots=@();                               ctas=@();                    map="" },
  @{ id="areas";       repeat="areas.items";     binds=@("title");             slots=@();                               ctas=@();                    map="" },
  @{ id="trust-badges";repeat="trust_badges.items"; binds=@("title","text");   slots=@();                               ctas=@();                    map="" },
  @{ id="reviews";     repeat="reviews.items";   binds=@("text");              slots=@();                               ctas=@("review");            map="" },
  @{ id="cases";       repeat="cases.items";     binds=@("title","text");      slots=@();                               ctas=@();                    map="" },
  @{ id="certs";       repeat="certs.items";     binds=@("title");             slots=@();                               ctas=@();                    map="" },
  @{ id="faq";         repeat="faq.items";       binds=@("q","a");             slots=@();                               ctas=@();                    map="" },
  @{ id="contact";     repeat="";                binds=@();                    slots=@();                               ctas=@("emergency","normal"); map="contact.map_embed_url" },
  @{ id="footer";      repeat="";                binds=@();                    slots=@();                               ctas=@();                    map="" }
)

foreach ($c in $contract) {
  $id = $c.id
  $chunk = Get-SectionChunk $html $id
  if ($null -eq $chunk) { Fail ("Section missing: #{0}" -f $id); continue } else { Ok ("Section present: #{0}" -f $id) }

  # required slots
  foreach ($sp in $c.slots) {
    if (Has-Regex $chunk ("data-slot\s*=\s*['""]" + [regex]::Escape($sp) + "['""]")) {
      # also validate path exists in JSON
      if ($null -ne (Get-ByPath $data $sp)) { Ok ("#{0}: slot ok + path exists -> {1}" -f $id, $sp) }
      else { Warn ("#{0}: slot present but JSON path missing -> {1}" -f $id, $sp) }
    } else {
      Fail ("#{0}: missing data-slot '{1}'" -f $id, $sp)
    }
  }

  # repeater
  if (-not [string]::IsNullOrWhiteSpace($c.repeat)) {
    $rep = $c.repeat
    if (Has-Regex $chunk ("data-repeat\s*=\s*['""]" + [regex]::Escape($rep) + "['""]")) {
      # validate JSON array exists
      $arr = Get-ByPath $data $rep
      if ($arr -is [System.Collections.IList]) { Ok ("#{0}: repeater ok + array exists -> {1} (count={2})" -f $id, $rep, $arr.Count) }
      else { Warn ("#{0}: repeater present but JSON path is not array -> {1}" -f $id, $rep) }

      if (Has-Regex $chunk "data-template") {
        Ok ("#{0}: template marker present (data-template)" -f $id)
      } else {
        Fail ("#{0}: missing data-template inside repeater host" -f $id)
      }

      # template bind values (syntactic + against first item if available)
      $bindVals = Find-AttrValues $chunk "data-bind" | Select-Object -Unique
      foreach ($b in $c.binds) {
        if ($bindVals -contains $b) { Ok ("#{0}: data-bind present -> {1}" -f $id, $b) }
        else {
          # allow FAQ variant keys if present
          if ($id -eq "faq") {
            # accept either (q/a) or (question/answer)
            if ($b -eq "q" -and ($bindVals -contains "question")) { Ok "#faq: data-bind present -> question (accepted for q)" }
            elseif ($b -eq "a" -and ($bindVals -contains "answer")) { Ok "#faq: data-bind present -> answer (accepted for a)" }
            else { Fail ("#{0}: missing data-bind '{1}'" -f $id, $b) }
          } else {
            Fail ("#{0}: missing data-bind '{1}'" -f $id, $b)
          }
        }
      }

      # validate bind paths against first item (if possible)
      if ($arr -is [System.Collections.IList] -and $arr.Count -gt 0) {
        $item0 = $arr[0]
        foreach ($bv in $bindVals) {
          if ($id -eq "faq") {
            # support q/a or question/answer
            if ($bv -in @("q","a","question","answer")) {
              $v = Get-ByPath $item0 $bv
              if ($null -ne $v) { Ok ("#faq: bind path exists in first item -> {0}" -f $bv) }
              else { Warn ("#faq: bind path missing in first item -> {0}" -f $bv) }
            }
          } else {
            $v = Get-ByPath $item0 $bv
            if ($null -ne $v) { Ok ("#{0}: bind path exists in first item -> {1}" -f $id, $bv) }
            else { Warn ("#{0}: bind path missing in first item -> {1}" -f $id, $bv) }
          }
        }
      }
    } else {
      Fail ("#{0}: missing data-repeat '{1}'" -f $id, $rep)
    }
  }

  # CTAs
  foreach ($cta in $c.ctas) {
    if (Has-Regex $chunk ("data-cta\s*=\s*['""]" + [regex]::Escape($cta) + "['""]")) { Ok ("#{0}: CTA present -> {1}" -f $id, $cta) }
    else { Fail ("#{0}: missing CTA data-cta='{1}'" -f $id, $cta) }
  }

  # map embed
  if (-not [string]::IsNullOrWhiteSpace($c.map)) {
    $mp = $c.map
    if (Has-Regex $chunk ("data-map-embed\s*=\s*['""]" + [regex]::Escape($mp) + "['""]")) {
      if ($null -ne (Get-ByPath $data $mp)) { Ok ("#{0}: map embed ok + path exists -> {1}" -f $id, $mp) }
      else { Warn ("#{0}: map embed present but JSON path missing -> {1}" -f $id, $mp) }
    } else {
      Fail ("#{0}: missing data-map-embed '{1}'" -f $id, $mp)
    }
  }

  $lines.Add("") | Out-Null
}

# Form: ensure message field is textarea somewhere in contact
$contactChunk = Get-SectionChunk $html "contact"
if ($contactChunk) {
  if (Has-Regex $contactChunk "<textarea\b") { Ok "#contact: textarea present" } else { Fail "#contact: textarea missing (message should be textarea)" }
}

# write report next to export reports
$outDir = Join-Path $repo "docs\import\webflow-export\latest"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$outFile = Join-Path $outDir "handoff_bindings_audit_full.txt"
$lines | Set-Content -LiteralPath $outFile -Encoding UTF8

$lines | ForEach-Object { Write-Host $_ }

Write-Host ""
Write-Host ("PASS: {0}" -f $pass)
Write-Host ("OK: wrote {0}" -f $outFile)

if (-not $pass) { exit 2 }
