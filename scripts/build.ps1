Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Docs = Join-Path $Root "docs\master"

function Assert-FileExists([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { throw ("Missing file: {0}" -f $Path) }
}

function Get-CodeBlocks([string]$Text) {
  $pattern = '(?ms)^[ \t]*```(?<lang>[a-zA-Z0-9_-]+)?[ \t]*\r?\n(?<code>.*?)\r?\n[ \t]*```[ \t]*$'
  return @([regex]::Matches($Text, $pattern))
}

function Extract-CodeBlock([string]$Path, [string[]]$PreferredLangs) {
  Assert-FileExists $Path
  $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  $matches = @(Get-CodeBlocks $text)
  if ($matches.Length -eq 0) { throw ("No fenced code block found in: {0}" -f $Path) }

  if ($PreferredLangs -and $PreferredLangs.Count -gt 0) {
    foreach ($lang in $PreferredLangs) {
      foreach ($m in $matches) {
        $mlang = ($m.Groups["lang"].Value).ToLower()
        if ($mlang -eq $lang.ToLower()) { return $m.Groups["code"].Value }
      }
    }
  }

  return $matches[0].Groups["code"].Value
}

function Write-Atomic([string]$TargetPath, [string]$Content) {
  $dir = Split-Path -Parent $TargetPath
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

  $tmp = "$TargetPath.tmp"
  if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }

  Set-Content -LiteralPath $tmp -Value $Content -Encoding UTF8 -NoNewline
  Move-Item -LiteralPath $tmp -Destination $TargetPath -Force
}

function Assert-NotEmpty([string]$Name, [string]$Content) {
  if ([string]::IsNullOrWhiteSpace($Content)) { throw ("Extracted content is empty: {0}" -f $Name) }
}

function Assert-Json([string]$Name, [string]$JsonText) {
  try { $null = $JsonText | ConvertFrom-Json -ErrorAction Stop }
  catch { throw ("Invalid JSON for {0}: {1}" -f $Name, $_.Exception.Message) }
}

# Inputs
$mdCss  = Join-Path $Docs "05_CORE_CSS_HIGHEND.md"
$mdJs   = Join-Path $Docs "06_CORE_JS_RUNTIME.md"
$mdCust = Join-Path $Docs "07_CUSTOMER_JSON_TEMPLATE.md"

# Outputs
$outCss  = Join-Path $Root "core\core.css"
$outJs   = Join-Path $Root "core\core.js"
$outCust = Join-Path $Root "customers\leuthold-demo\customer.json"
$outSch  = Join-Path $Root "schema\customer.v1.schema.json"

# core.css
$css = Extract-CodeBlock -Path $mdCss -PreferredLangs @("css")
Assert-NotEmpty "core.css" $css
Write-Atomic -TargetPath $outCss -Content $css

# core.js
$js = Extract-CodeBlock -Path $mdJs -PreferredLangs @("js","javascript")
Assert-NotEmpty "core.js" $js
Write-Atomic -TargetPath $outJs -Content $js

# customer.json
$cust = Extract-CodeBlock -Path $mdCust -PreferredLangs @("json")
Assert-NotEmpty "customer.json" $cust
Assert-Json "customer.json" $cust
Write-Atomic -TargetPath $outCust -Content $cust

# Optional: schema (erstes JSON-Codeblock mit "$schema")
$schemaFound = $false
$mdFiles = Get-ChildItem -LiteralPath $Docs -File -Filter "*.md" | Sort-Object Name

foreach ($f in $mdFiles) {
  $text = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $blocks = @(Get-CodeBlocks $text)
  foreach ($b in $blocks) {
    $lang = ($b.Groups["lang"].Value).ToLower()
    if ($lang -ne "json") { continue }
    $code = $b.Groups["code"].Value
    if ($code -match '"\$schema"\s*:') {
      Assert-Json "customer.v1.schema.json" $code
      Write-Atomic -TargetPath $outSch -Content $code
      $schemaFound = $true
      break
    }
  }
  if ($schemaFound) { break }
}

if ($schemaFound) {
  Write-Host ("OK: schema -> {0}" -f $outSch)
} else {
  Write-Host 'SKIP: schema not found in docs\master (no JSON block with "$schema")'
}

Write-Host ("OK: core.css  -> {0}" -f $outCss)
Write-Host ("OK: core.js   -> {0}" -f $outJs)
Write-Host ("OK: customer  -> {0}" -f $outCust)


