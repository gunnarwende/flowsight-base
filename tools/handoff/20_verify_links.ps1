Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ExportDir {
  param([string]$RepoRoot)
  $latest = Join-Path $RepoRoot "docs\import\webflow-export\latest"
  if (Test-Path -LiteralPath $latest) { return (Resolve-Path $latest).Path }

  $root = Join-Path $RepoRoot "docs\import\webflow-export"
  $d = Get-ChildItem -LiteralPath $root -Directory |
    Where-Object { $_.Name -match '^\d{8}-\d{6}$' } |
    Sort-Object Name -Descending |
    Select-Object -First 1
  if (-not $d) { throw "Kein Export gefunden (kein latest, kein Timestamp)." }
  return $d.FullName
}

$repo = (Get-Location).Path
$exportDir = Get-ExportDir -RepoRoot $repo
$htmlPath  = Join-Path $exportDir "index.html"
if (-not (Test-Path -LiteralPath $htmlPath)) { throw "index.html fehlt: $htmlPath" }

$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $htmlPath

# IDs
$ids = [regex]::Matches($html,'(?is)\bid\s*=\s*"([^"]+)"') |
  ForEach-Object { $_.Groups[1].Value.Trim() } |
  Where-Object { $_ } |
  Sort-Object -Unique

# Links with openTag (to detect tel-wired placeholders)
$links = [regex]::Matches($html,'(?is)(<a\b[^>]*\bhref\s*=\s*"([^"]+)"[^>]*>)(.*?)</a>') | ForEach-Object {
  $open = $_.Groups[1].Value
  $href = $_.Groups[2].Value.Trim()
  $txt  = ($_.Groups[3].Value -replace '(?is)<[^>]+>','').Trim()
  if (-not $txt) { $txt = "(no text)" }
  [pscustomobject]@{ href=$href; text=$txt; openTag=$open }
}

$anchorBroken = @()
$hashNonLegal = @()

foreach ($l in $links) {

  if ($l.href -eq "#") {
    # legal allowed
    if ($l.text -eq "Impressum / Datenschutz") { continue }

    # tel-wired allowed
    $isTel  = ($l.openTag -match '(?is)\bdata-href-prefix\s*=\s*"tel:"')
    $isE164 = ($l.openTag -match '(?is)\bdata-slot-href\s*=\s*"contact\.phones\.(emergency|normal)\.e164"')
    if ($isTel -and $isE164) { continue }

    $hashNonLegal += "PLACEHOLDER #: text='$($l.text)'"
    continue
  }

  if ($l.href -like "#*") {
    $id = $l.href.TrimStart("#")
    if (-not ($ids -contains $id)) {
      $anchorBroken += "BROKEN: $($l.href) missing id='$id' text='$($l.text)'"
    }
  }
}

$pass = ($anchorBroken.Count -eq 0) -and ($hashNonLegal.Count -eq 0)

$out = New-Object System.Collections.Generic.List[string]
$out.Add("OK: exportDir = $exportDir")
$out.Add("---- LINK VERIFY ----")
$out.Add(("PASS: " + $pass))
$out.Add(("ANCHOR broken count: " + $anchorBroken.Count))
$out.Add(("NON-LEGAL '#' count: " + $hashNonLegal.Count))
$out.Add("---- ANCHOR BROKEN ----")
if ($anchorBroken.Count -eq 0) { $out.Add("none") } else { $anchorBroken | ForEach-Object { $out.Add($_) } }
$out.Add("---- HREF '#' (NON-LEGAL) ----")
if ($hashNonLegal.Count -eq 0) { $out.Add("none") } else { $hashNonLegal | ForEach-Object { $out.Add($_) } }

$path = Join-Path $exportDir "handoff_verify_links.txt"
$out | Set-Content -Encoding UTF8 -LiteralPath $path
Get-Content -LiteralPath $path
