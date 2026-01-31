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
$forms = [regex]::Matches($html,'(?is)<form\b[^>]*>') | ForEach-Object { $_.Value }

$fields = @()
[regex]::Matches($html,'(?is)<input\b[^>]*>') | ForEach-Object {
  $tag  = $_.Value
  $name = ([regex]::Match($tag,'(?is)\bname\s*=\s*"([^"]+)"')).Groups[1].Value
  if (-not $name) { return }
  $type = ([regex]::Match($tag,'(?is)\btype\s*=\s*"([^"]+)"')).Groups[1].Value
  if (-not $type) { $type = "text" }
  $fields += [pscustomobject]@{ name=$name; kind="input"; type=$type }
}
[regex]::Matches($html,'(?is)<textarea\b[^>]*>') | ForEach-Object {
  $tag  = $_.Value
  $name = ([regex]::Match($tag,'(?is)\bname\s*=\s*"([^"]+)"')).Groups[1].Value
  if (-not $name) { return }
  $fields += [pscustomobject]@{ name=$name; kind="textarea"; type="textarea" }
}

$want = @("name","email","phone","message")
$fs = $fields | Where-Object { $want -contains $_.name } | Sort-Object name, kind

$missing = @()
foreach ($w in $want) { if (-not ($fs | Where-Object { $_.name -eq $w })) { $missing += $w } }

$emailOk = [bool]($fs | Where-Object { $_.name -eq "email" -and $_.kind -eq "input" -and $_.type -eq "email" })
$phoneOk = [bool]($fs | Where-Object { $_.name -eq "phone" -and $_.kind -eq "input" -and ($_.type -eq "tel" -or $_.type -eq "text" -or $_.type -eq "phone") })
$messageExists = [bool]($fs | Where-Object { $_.name -eq "message" })
$doneOk = [bool]($html -match '(?is)\bw-form-done\b')
$failOk = [bool]($html -match '(?is)\bw-form-fail\b')

$formNameOk = $false
foreach ($ft in $forms) {
  $n = ""

  $m = [regex]::Match($ft,'(?is)\bdata-name\s*=\s*"([^"]+)"')
  if ($m.Success) { $n = $m.Groups[1].Value.Trim() }

  if (-not $n) {
    $m = [regex]::Match($ft,'(?is)\bdata-name\s*=\s*''([^'']+)''')
    if ($m.Success) { $n = $m.Groups[1].Value.Trim() }
  }

  if (-not $n) {
    $m = [regex]::Match($ft,'(?is)\bname\s*=\s*"([^"]+)"')
    if ($m.Success) { $n = $m.Groups[1].Value.Trim() }
  }

  if ($n -eq "contact-form" -or $n -eq "contact") { $formNameOk = $true; break }
}

$pass = ($missing.Count -eq 0) -and $emailOk -and $phoneOk -and $messageExists -and $doneOk -and $failOk

$out = New-Object System.Collections.Generic.List[string]
$out.Add("OK: exportDir = $exportDir")
$out.Add("---- FORM VERIFY ----")
$out.Add(("PASS: " + $pass))
$out.Add(("missing: " + ($(if ($missing.Count -eq 0) { "none" } else { $missing -join ", " }))))
$out.Add(("email type ok: " + $emailOk))
$out.Add(("phone type ok: " + $phoneOk))
$out.Add(("message exists: " + $messageExists))
$out.Add(("w-form-done present: " + $doneOk))
$out.Add(("w-form-fail present: " + $failOk))
$out.Add(("form name ok (data-name contact-form/contact): " + $formNameOk))
$out.Add("---- FIELDS (found) ----")
foreach ($r in $fs) { $out.Add(("{0} | {1} | {2}" -f $r.name, $r.kind, $r.type)) }

$path = Join-Path $exportDir "handoff_verify_contact_form.txt"
$out | Set-Content -Encoding UTF8 -LiteralPath $path
Get-Content -LiteralPath $path
