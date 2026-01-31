# FlowSight_Analyse_Website_v03
Ziel: Vollumfängliche Analyse einer FlowSight-Webflow-Site (Frontend-Struktur + Runtime-Loading + relevante Webflow-Settings), mit minimalem Datenvolumen und reproduzierbarem Ablauf.

Kontextannahmen:
- Arbeitsverzeichnis lokal: `C:\flowsight-base`
- Webflow Code-Export wird als ZIP heruntergeladen und manuell nach `C:\flowsight-base` gelegt.
- FlowSight Runtime lädt über jsDelivr aus GitHub:
  - `core/core.css`
  - `core/core.js`
  - `customers/<customer>/customer.json`

Arbeitsmodus/SSO/Kommunikationsregeln: siehe `docs/master/01_REPO_STRUCTURE_AND_WORKFLOW.md` → Abschnitt **8. Working Agreement (Chat-übergreifend)**.

---

## 1) Was für eine „vollumfängliche Analyse“ benötigt wird

### 1.1 Pflicht-Artefakte (minimal, effizient)
A) Export (Frontend-Source-of-Truth)
- `index.html` (aus dem Webflow-Export)
- Projekt-CSS (eine Datei, z.B. `css/<projektname>.webflow.css`)

B) Handoff-Reports (aus `index.html` automatisch erzeugt)
- `handoff_data-attrs.txt` (Liste aller `data-*` Attribute im HTML)
- `handoff_classes.txt` (Liste aller Klassen-Tokens im HTML)
- `handoff_linked-assets.txt` (alle `<link href=...>` und `<script src=...>` im HTML)
- `handoff_pages.txt` (Liste der exportierten `*.html` Dateien)

C) Runtime-Live-Nachweis (einfachster Beleg)
- Screenshot DevTools Network, gefiltert auf `cdn.jsdelivr`
  - muss die 3 Requests zeigen: `core.css`, `core.js`, `customer.json`

D) Webflow Custom Code (als Text oder Screenshot)
- Head Code (CSS CDN)
- Footer Code (Customer URL + core.js)

### 1.2 Optional (nur wenn vorhanden / relevant)
- HAR-File (statt Screenshot), falls gewünscht: `*.har`
- Publishing/Site Access Screenshots (nur wenn Domain/Passwortschutz unklar)
- Forms Settings Screenshots (Project Settings → Forms), nur wenn Webflow-Form-Processing/Notifications geprüft werden sollen
- CMS/Collections Screenshots, nur wenn CMS genutzt wird
- Interactions Panel Screenshot, nur wenn Interactions genutzt werden

---

## 2) Standard-Workflow: Export-ZIP → Import → Reports

### 2.0 Preferred: One-Command Runner (SSO)
Primärer, kanonischer Ablauf (reproduzierbar, ohne Copy/Paste-Snippets):

```powershell
cd C:\flowsight-base
powershell -ExecutionPolicy Bypass -File .\tools\handoff\run_phase2.ps1
```

Ergebnis-Ordner (immer):
- `docs\import\webflow-export\latest\`

Hinweis:
- Die folgenden Einzel-Snippets sind Referenz/Debug.
- Der Runner ist die SSO-Quelle für Checks/Reports.

### 2.1 ZIP in Root ablegen
1) Webflow → Export Code → ZIP herunterladen  
2) ZIP manuell nach `C:\flowsight-base` verschieben (Repo-Root)

### 2.2 Import/Extract (timestamped) – Referenz/Debug
Wenn du **nicht** den Runner nutzt, ist das hier der manuelle Referenzweg (timestamped Extract).

```powershell
cd C:\flowsight-base
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$dest = "docs\import\webflow-export\$ts"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$zip = Get-ChildItem -Path . -File -Filter "*.zip" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1
if (-not $zip) { throw "Keine ZIP im Root gefunden. Lege die Webflow-Export-ZIP in C:\flowsight-base." }

Move-Item -LiteralPath $zip.FullName -Destination (Join-Path $dest $zip.Name) -Force
Expand-Archive -LiteralPath (Join-Path $dest $zip.Name) -DestinationPath $dest -Force

Write-Host "OK: extracted to $dest"
```

### 2.3 Reports/Verify (SSO)
Die Reports/Checks werden kanonisch über den Runner erzeugt. Artefakte liegen unter:
- `docs\import\webflow-export\latest\`

Pflicht-Outputs (Phase 2 Wiring/Verification):
- `handoff_bindings.txt`
- `handoff_link_report.txt` (Anchor/Placeholder-Check)
- `handoff_verify_contact_form.txt` (Form-Mapping + States)
- `handoff_css_badprops_sample.txt`
- `handoff_css_defined_custom_classes.txt`

Optional (Debug):
- `handoff_link_locator.txt`
- `handoff_hash_notext_locator.txt`

### 2.4 Repo Hygiene
- `docs/import/**` ist lokal (Artefakte) und wird nicht committet.
- SSO-Änderungen passieren nur in: `tools/`, `docs/master/`, `core/`, `customers/`, `schema/`, `scripts/`.


---

## 3) Reports erzeugen (Handoff)

### 3.1 data-attrs / classes / linked-assets
PowerShell:

```powershell
cd C:\flowsight-base
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exportDir = (Get-ChildItem "docs\import\webflow-export" -Directory |
  Sort-Object Name -Descending |
  Select-Object -First 1).FullName

$htmlPath = Join-Path $exportDir "index.html"
if (-not (Test-Path -LiteralPath $htmlPath)) { throw "index.html fehlt in $exportDir" }

$html = Get-Content -Raw -Encoding UTF8 $htmlPath

# data-* attribute names
$attrs = [regex]::Matches($html, '(?i)\s(data-[a-z0-9_-]+)\s*=') |
  ForEach-Object { $_.Groups[1].Value.ToLower() } |
  Sort-Object -Unique
$attrs | Set-Content -Encoding UTF8 (Join-Path $exportDir "handoff_data-attrs.txt")

# class tokens
$classes = [regex]::Matches($html, '(?i)\bclass\s*=\s*"([^"]+)"') |
  ForEach-Object { $_.Groups[1].Value } |
  ForEach-Object { $_ -split '\s+' } |
  Where-Object { $_ -and $_.Trim() -ne "" } |
  Sort-Object -Unique
$classes | Set-Content -Encoding UTF8 (Join-Path $exportDir "handoff_classes.txt")

# linked assets
$links = [regex]::Matches($html, '(?i)(<link[^>]+href="[^"]+"|<script[^>]+src="[^"]+")') |
  ForEach-Object { $_.Value }
$links | Set-Content -Encoding UTF8 (Join-Path $exportDir "handoff_linked-assets.txt")

Get-Item (Join-Path $exportDir "handoff_data-attrs.txt"),
        (Join-Path $exportDir "handoff_classes.txt"),
        (Join-Path $exportDir "handoff_linked-assets.txt") |
  Format-Table Name, Length -AutoSize
```

### 3.2 Pages-Liste ohne Screenshot
PowerShell:

```powershell
cd C:\flowsight-base
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exportDir = (Get-ChildItem "docs\import\webflow-export" -Directory |
  Sort-Object Name -Descending |
  Select-Object -First 1).FullName

Get-ChildItem -LiteralPath $exportDir -File -Filter "*.html" |
  Sort-Object Name |
  Select-Object -ExpandProperty Name |
  Set-Content -Encoding UTF8 (Join-Path $exportDir "handoff_pages.txt")

Get-Content (Join-Path $exportDir "handoff_pages.txt")
```

### 3.3 Form-Felder + Success/Error States (ableitbar aus Export)
PowerShell:

```powershell
cd C:\flowsight-base
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exportDir = (Get-ChildItem "docs\import\webflow-export" -Directory |
  Sort-Object Name -Descending | Select-Object -First 1).FullName
$htmlPath  = Join-Path $exportDir "index.html"
if (-not (Test-Path -LiteralPath $htmlPath)) { throw "index.html fehlt in $exportDir" }

$html = Get-Content -Raw -Encoding UTF8 $htmlPath

$tags = [regex]::Matches($html, '(?is)<(input|textarea|select)\b[^>]*>') |
  ForEach-Object { $_.Value }

$fields = foreach ($t in $tags) {
  $name = ([regex]::Match($t,'(?is)\bname\s*=\s*"([^"]+)"').Groups[1].Value)
  if (-not $name) { continue }

  $type = ([regex]::Match($t,'(?is)\btype\s*=\s*"([^"]+)"').Groups[1].Value)
  if (-not $type) {
    if ($t -match '(?is)^<textarea') { $type = 'textarea' }
    elseif ($t -match '(?is)^<select') { $type = 'select' }
    else { $type = 'text' }
  }

  $id  = ([regex]::Match($t,'(?is)\bid\s*=\s*"([^"]+)"').Groups[1].Value)
  $ph  = ([regex]::Match($t,'(?is)\bplaceholder\s*=\s*"([^"]*)"').Groups[1].Value)

  $req = 'false'
  if ($t -match '(?is)\brequired\b') { $req = 'true' }

  [pscustomobject]@{ name=$name; type=$type; required=$req; id=$id; placeholder=$ph }
}

$fields | Sort-Object name | Format-Table -AutoSize | Out-String |
  Set-Content -Encoding UTF8 (Join-Path $exportDir "handoff_form_fields.txt")

$hasDone = ($html -match '(?is)\bw-form-done\b')
$hasFail = ($html -match '(?is)\bw-form-fail\b')
@("w-form-done: $hasDone","w-form-fail: $hasFail") |
  Set-Content -Encoding UTF8 (Join-Path $exportDir "handoff_form_states.txt")

Get-Item (Join-Path $exportDir "handoff_form_fields.txt"),
        (Join-Path $exportDir "handoff_form_states.txt") |
  Format-Table Name, Length -AutoSize

```


---

#### 3.3.1 FlowSight Form-Verify (Standard: name/email/phone/message)
Ziel: Harte DoD-Prüfung für das Kontaktformular ohne Screenshots.

**PASS-Kriterien**
- Felder vorhanden: `name`, `email`, `phone`, `message` (HTML `name="..."`)
- `email` ist `type="email"`
- `phone` ist `type="tel"` (oder `text`, falls Webflow kein `tel` ausgibt)
- Success/Error States vorhanden (`w-form-done`, `w-form-fail`)
- Form ist als `data-name="contact-form"` (oder `contact`) im `<form ...>` erkennbar *(Info; kann als Warnung behandelt werden, wenn Webflow es nicht sauber exportiert).*

PowerShell (PS 5.1 kompatibel, schreibt Report-Datei):

```powershell
cd C:\flowsight-base
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FlowSightExportDir {
  $latest = Join-Path (Get-Location) "docs\import\webflow-export\latest"
  if (Test-Path -LiteralPath $latest) { return (Resolve-Path $latest).Path }

  $root = Join-Path (Get-Location) "docs\import\webflow-export"
  $d = Get-ChildItem -LiteralPath $root -Directory |
    Where-Object { $_.Name -match '^\d{8}-\d{6}$' } |
    Sort-Object Name -Descending |
    Select-Object -First 1
  if (-not $d) { throw "Kein Export gefunden (kein latest, kein Timestamp)." }
  return $d.FullName
}

$exportDir = Get-FlowSightExportDir
$htmlPath  = Join-Path $exportDir "index.html"
if (-not (Test-Path -LiteralPath $htmlPath)) { throw "index.html fehlt in $exportDir" }

$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $htmlPath

# --- form tags (für data-name/name) ---
$forms = [regex]::Matches($html,'(?is)<form\b[^>]*>') | ForEach-Object { $_.Value }

# --- fields: inputs + textareas ---
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

# Form-Name: Webflow exportiert i.d.R. data-name="contact-form" am <form ...>
$formNameOk = $false
foreach ($ft in $forms) {
  $n = ""

  $m = [regex]::Match($ft,'(?is)\bdata-name\s*=\s*"([^"]+)"')
  if ($m.Success) { $n = $m.Groups[1].Value.Trim() }

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

$reportPath = Join-Path $exportDir "handoff_verify_contact_form.txt"
$out | Set-Content -Encoding UTF8 -LiteralPath $reportPath
Get-Content -LiteralPath $reportPath
```


---


### 3.4 CSS-Audit (No-Drift: keine Designer-Overrides)
Ziel: Feststellen, ob das Projekt-CSS (`css/<projektname>.webflow.css`) Custom-Classes definiert oder harte Overrides enthält.

PowerShell (PS 5.1 kompatibel, schreibt immer beide Dateien):

```powershell
cd C:\flowsight-base
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FlowSightExportDir {
  $latest = Join-Path (Get-Location) "docs\import\webflow-export\latest"
  if (Test-Path -LiteralPath $latest) { return (Resolve-Path $latest).Path }

  $root = Join-Path (Get-Location) "docs\import\webflow-export"
  $d = Get-ChildItem -LiteralPath $root -Directory |
    Where-Object { $_.Name -match '^\d{8}-\d{6}$' } |
    Sort-Object Name -Descending |
    Select-Object -First 1
  if (-not $d) { throw "Kein Export gefunden (kein latest, kein Timestamp)." }
  return $d.FullName
}

$exportDir = Get-FlowSightExportDir

# Projekt-CSS automatisch finden (nicht normalize/webflow.css)
$cssCandidates = Get-ChildItem -LiteralPath (Join-Path $exportDir "css") -File -Filter "*.css" |
  Where-Object { $_.Name -notin @("normalize.css","webflow.css") } |
  Sort-Object LastWriteTime -Descending

if (-not $cssCandidates -or $cssCandidates.Length -eq 0) {
  throw "Keine Projekt-CSS im Export gefunden (außer normalize/webflow.css) in $exportDir"
}

$cssPath = $cssCandidates[0].FullName
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

$outDefined = Join-Path $exportDir "handoff_css_defined_custom_classes.txt"
$outBad     = Join-Path $exportDir "handoff_css_badprops_sample.txt"

# 1) Welche Custom-Classes werden im Projekt-CSS definiert?
$classesPath = Join-Path $exportDir "handoff_classes.txt"
if (-not (Test-Path -LiteralPath $classesPath)) { throw "handoff_classes.txt fehlt: $classesPath" }

$classes = Get-Content -Encoding UTF8 -LiteralPath $classesPath |
  Where-Object { $_ -and ($_ -notmatch '^w-') }

$defined = foreach ($c in $classes) {
  if ($css -match ("(?m)^\s*\." + [regex]::Escape($c) + "\b")) { $c }
}

$definedArr = @($defined)
if ($definedArr.Length -gt 0) {
  $definedArr | Sort-Object | Set-Content -Encoding UTF8 -LiteralPath $outDefined
} else {
  "# none" | Set-Content -Encoding UTF8 -LiteralPath $outDefined
}

# 2) Harte Overrides (Spacing/Typo/Colors etc.) als Sample
$rxBad = '(?im)^\s*[^}]*\b(margin|padding|font|line-height|letter-spacing|text-transform|color|background|border|box-shadow)\b\s*:'
$badHits = [regex]::Matches($css, $rxBad) | ForEach-Object { $_.Value.Trim() }

$badArr = @($badHits)
if ($badArr.Length -gt 0) {
  $badArr | Select-Object -First 300 | Set-Content -Encoding UTF8 -LiteralPath $outBad
} else {
  "# none" | Set-Content -Encoding UTF8 -LiteralPath $outBad
}

Write-Host "OK: projectCSS = $([IO.Path]::GetFileName($cssPath))"
Get-Item -LiteralPath $outDefined, $outBad | Format-Table Name, Length -AutoSize


### 3.5 Backend-Settings Snapshot (nicht im ZIP enthalten)
Hinweis: Webflow Export ZIP enthält Frontend-Dateien, aber keine zuverlässige Konfiguration für Publishing/Site password/Spam/Uploads/Integrations.
Um das reproduzierbar und ohne Screenshots zu liefern, wird eine kleine JSON-Datei per Prompt erzeugt.

PowerShell (PS 5.1):

```powershell
cd C:\flowsight-base
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exportDir = (Get-ChildItem "docs\import\webflow-export" -Directory | Sort-Object Name -Descending | Select-Object -First 1).FullName
$out = Join-Path $exportDir "handoff_backend_settings.json"

$backend = [ordered]@{
  captured_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  publishing = [ordered]@{
    staging_domain   = (Read-Host "Publishing: staging domain (z.B. sanitar-template.webflow.io)")
    staging_published = (Read-Host "Publishing: staging published? (true/false)")
    custom_domains   = (Read-Host "Publishing: custom domains (comma oder leer)")
  }
  access = [ordered]@{
    password_protection = (Read-Host "Site password protection (on/off/n-a)")
  }
  forms = [ordered]@{
    form_names = (Read-Host "Forms: form names (comma, z.B. Email Form 2)")
    turnstile_bots_blocked  = (Read-Host "Forms: Turnstile bots blocked (on/off/n-a)")
    turnstile_spam_filtered = (Read-Host "Forms: Turnstile spam filtered (on/off/n-a)")
    recaptcha_enabled       = (Read-Host "Forms: reCAPTCHA enabled (on/off/n-a)")
    restrict_upload_access  = (Read-Host "Forms: restrict uploaded file access (on/off/n-a)")
    connected_apps          = (Read-Host "Apps: connected apps (none oder liste)")
    form_integrations       = (Read-Host "Apps: form integrations (none oder liste)")
  }
}

($backend | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $out -Encoding UTF8
Get-Item $out | Format-Table Name, Length -AutoSize
```

Soll:
- `handoff_backend_settings.json` existiert im aktuellen Export-Ordner.


## 4) Runtime-Check (Live) – Network Screenshot oder HAR

### 4.1 Schnellster Nachweis: Network Screenshot (Filter: cdn.jsdelivr)
DevTools (Chrome/Edge):
1) Öffne die Live-URL (z.B. `https://<projekt>.webflow.io/`)
2) `F12`
3) Tab **Network**
4) Haken: **Preserve log**
5) Haken: **Disable cache**
6) Hard reload: `Ctrl+Shift+R`
7) Ins Filterfeld tippen: `cdn.jsdelivr`
8) Screenshot erstellen, der folgende 3 Requests zeigt:
   - `core.css` (Status 200/304)
   - `core.js` (Status 200/304)
   - `customer.json` (Status 200/304)

Hinweis: In dieser Doku nur den Filter `cdn.jsdelivr` verwenden (zeigt alle drei relevanten Requests in einem Blick).

### 4.2 HAR Export (optional, statt Screenshot)
1) Schritte 1–6 wie oben
2) Rechtsklick in die Request-Liste → **Save all as HAR with content**
3) Speichern als `sanitar-template_network.har`
4) Datei in `C:\flowsight-base` ablegen und bereitstellen

---

## 5) Custom Code (Webflow Settings)

### 5.1 Head Code (CSS)
Soll (Beispiel):
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/core/core.css">
```

### 5.2 Footer Code (Customer + JS)
Soll (Beispiel):
```html
<script>
  window.FLOWSIGHT_CUSTOMER_URL =
    "https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/customers/leuthold-demo/customer.json";
</script>
<script src="https://cdn.jsdelivr.net/gh/gunnarwende/flowsight-base@main/core/core.js" defer></script>
```

Wichtig: Keine äußeren Anführungszeichen um den Footer-Code im Webflow UI.

---

## 6) Minimaler „Upload/Handoff“ an den Analysten (Datensparen)
Ziel: Beim nächsten Analyse-Run nur PowerShell ausführen und dann nur kleine Artefakte teilen.

Pflicht (aus Export-Ordner):
- `handoff_pages.txt`
- `handoff_linked-assets.txt`
- `handoff_classes.txt`
- `handoff_data-attrs.txt`
- `handoff_form_fields.txt`
- `handoff_form_states.txt`
- `handoff_css_defined_custom_classes.txt`
- `handoff_css_badprops_sample.txt`
- `handoff_backend_settings.json` (einmal pro Analyse-Run per Prompt erzeugt; ersetzt Screenshots für Publishing/Access/Forms)

Pflicht (ein Beleg „Runtime live“):
- DevTools Network Screenshot, Filter `cdn.jsdelivr` (muss `core.css`, `core.js`, `customer.json` zeigen)
  - alternativ HAR-Export (siehe 4.2)

Optional (nur wenn unklar / bei Debug):
- `index.html` (nur wenn Repeater/Template/Slots nicht eindeutig sind)
- `css/<projektname>.webflow.css` (nur wenn CSS-Audit Treffer hat und Details gebraucht werden)

Nicht nötig (in der Regel):
- `normalize.css`
- `webflow.css`
- `webflow.js`
- `images/*`

---

## 6.1 Was außerhalb von PowerShell einmalig nötig ist
Diese Informationen können nicht aus dem ZIP extrahiert werden. Beim nächsten Analyse-Run sollen sie nicht per Chat erklärt werden, sondern nur in `handoff_backend_settings.json` eingetragen werden (3.5).

Außerhalb von PowerShell ist nur nötig:
- Webflow UI kurz öffnen, Werte ablesen:
  - Publishing: Staging Domain + Published (true/false), ggf. Custom Domains
  - Site password protection: on/off
  - Forms/Spam/Uploads: Turnstile toggles, reCAPTCHA enabled, Restrict upload access
  - Apps/Integrations: Connected Apps / Form integrations (none oder Liste)
- Danach PowerShell 3.5 ausführen und die JSON-Datei teilen.

Wenn Live-Network-Screenshot nicht möglich ist:
- HAR-Export (4.2) statt Screenshot.

---
## 7) Validierung: FlowSight-Bindings „vorhanden“ (Quick Check)
PowerShell:

```powershell
cd C:\flowsight-base
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FlowSightExportDir {
  $latest = Join-Path (Get-Location) "docs\import\webflow-export\latest"
  if (Test-Path -LiteralPath $latest) { return (Resolve-Path $latest).Path }

  $root = Join-Path (Get-Location) "docs\import\webflow-export"
  $d = Get-ChildItem -LiteralPath $root -Directory |
    Where-Object { $_.Name -match '^\d{8}-\d{6}$' } |
    Sort-Object Name -Descending |
    Select-Object -First 1
  if (-not $d) { throw "Kein Export gefunden (kein latest, kein Timestamp)." }
  return $d.FullName
}

$exportDir = Get-FlowSightExportDir

$need = @(
  "data-slot","data-slot-image","data-slot-href","data-href-prefix",
  "data-repeat","data-template","data-bind","data-map-embed","data-cta"
)

$present = Get-Content -Encoding UTF8 -LiteralPath (Join-Path $exportDir "handoff_data-attrs.txt")

$need | ForEach-Object {
  "{0} : {1}" -f $_, ($(if ($present -contains $_) { "OK" } else { "MISSING" }))
}

```

Soll: alle 9 = OK.
