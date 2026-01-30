# FlowSight_Analyse_Website_v01

Ziel: Vollumfängliche Analyse einer FlowSight-Webflow-Site (Frontend-Struktur + Runtime-Loading + relevante Webflow-Settings), mit minimalem Datenvolumen und reproduzierbarem Ablauf.

Kontextannahmen:
- Arbeitsverzeichnis lokal: `C:\flowsight-base`
- Webflow Code-Export wird als ZIP heruntergeladen und manuell nach `C:\flowsight-base` gelegt.
- FlowSight Runtime lädt über jsDelivr aus GitHub:
  - `core/core.css`
  - `core/core.js`
  - `customers/<customer>/customer.json`

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

### 2.1 ZIP in Root ablegen
1) Webflow → Export Code → ZIP herunterladen
2) ZIP manuell nach `C:\flowsight-base` verschieben (Root)

### 2.2 Import/Extract (timestamped)
PowerShell:

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
Für die nächste Analyse-Runde reichen typischerweise:

Pflicht:
- `index.html`
- `css/<projektname>.webflow.css`
- `handoff_data-attrs.txt`
- `handoff_classes.txt`
- `handoff_linked-assets.txt`
- `handoff_pages.txt`
- Custom Code (Head/Footer) als Text
- Network Screenshot (Filter: `cdn.jsdelivr`) oder HAR

Nicht nötig (in der Regel):
- `normalize.css`
- `webflow.css`
- `webflow.js`
- `images/*`

---

## 7) Validierung: FlowSight-Bindings „vorhanden“ (Quick Check)
PowerShell:

```powershell
cd C:\flowsight-base
$exportDir = (Get-ChildItem "docs\import\webflow-export" -Directory |
  Sort-Object Name -Descending |
  Select-Object -First 1).FullName

$need = @(
  "data-slot","data-slot-image","data-slot-href","data-href-prefix",
  "data-repeat","data-template","data-bind","data-map-embed","data-cta"
)
$present = Get-Content (Join-Path $exportDir "handoff_data-attrs.txt")

$need | ForEach-Object {
  "{0} : {1}" -f $_, ($(if ($present -contains $_) { "OK" } else { "MISSING" }))
}
```

Soll: alle 9 = OK.
