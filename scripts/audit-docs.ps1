param(
    [switch]$OpenReport
)

# Audits the user-facing documentation against the app it describes:
#   store_listing/google_play_short_description.txt
#   store_listing/google_play_full_description.txt
#   lib/tabs/help_tab.dart  (the in-app Help tab)
#   README.md
#
# The facts are read out of the source so the docs can never quietly drift from
# the app. Every check writes a PASS or FAIL line; the script exits 1 if any
# check failed, so it can gate a build.

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

function Get-RequiredFile([string]$relative) {
    $path = Join-Path $root $relative
    if (-not (Test-Path $path)) {
        throw "$relative was not found at $path"
    }
    return $path
}

function Get-DocText([string]$relative) {
    return (Get-Content -Path (Get-RequiredFile $relative) -Raw)
}

$pubspecPath = Get-RequiredFile 'pubspec.yaml'
$readmePath = Get-RequiredFile 'README.md'
$shortPath = Get-RequiredFile 'store_listing/google_play_short_description.txt'
$fullPath = Get-RequiredFile 'store_listing/google_play_full_description.txt'
$helpPath = Get-RequiredFile 'lib/tabs/help_tab.dart'
$appTabsPath = Get-RequiredFile 'lib/models/app_tab.dart'

$pubspec = Get-Content -Path $pubspecPath -Raw
$readme = Get-Content -Path $readmePath -Raw
$short = Get-Content -Path $shortPath -Raw
$full = Get-Content -Path $fullPath -Raw
$help = Get-Content -Path $helpPath -Raw
$appTabDefinitions = Get-Content -Path $appTabsPath -Raw

$failures = New-Object System.Collections.Generic.List[string]
$checks = New-Object System.Collections.Generic.List[string]

function Add-Check([string]$name, [bool]$passed, [string]$detail) {
    $status = if ($passed) { 'PASS' } else { 'FAIL' }
    $checks.Add("[$status] $name -- $detail")
    if (-not $passed) {
        $failures.Add("$name -- $detail")
    }
}

# --- The app's own facts, read from source -----------------------------------

if ($pubspec -match '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+)\s*$') {
    $appVersion = $Matches[1]
} else {
    throw 'Could not read the version from pubspec.yaml'
}

# Navigation labels are mapped from the AppTab enum's presentation extension.
# Settings is an action in the app bar rather than a navigation tab.
$appTabs = [regex]::Matches(
    $appTabDefinitions,
    "AppTab\.\w+\s*=>\s*'(?<label>[^']+)'"
) | ForEach-Object { $_.Groups['label'].Value }

# --- 1. Every navigation tab is documented in the README ---------------------

# The README may cover a tab either on its own (`- **Fleet**`) or grouped with a
# neighbour (`- **Help / Information**`), so a bullet counts as covering a tab
# when it names it among the labels it joins with slashes.
function Get-BulletForTab([string]$tab) {
    $escaped = [regex]::Escape($tab)
    return "(?m)^- \*\*[^*]*\b$escaped\b[^*]*\*\*"
}

$missingInReadme = @($appTabs | Where-Object { $readme -notmatch (Get-BulletForTab $_) })
$readmeDetail = if ($missingInReadme.Count -eq 0) {
    "all $($appTabs.Count) tabs are described"
} else {
    "missing: $($missingInReadme -join ', ')"
}
Add-Check -name 'README documents every tab' -passed ($missingInReadme.Count -eq 0) -detail $readmeDetail

# --- 2. Every navigation tab is named in the store listing -------------------

$missingInStore = @($appTabs | Where-Object { $full -notmatch [regex]::Escape($_) })
$storeDetail = if ($missingInStore.Count -eq 0) {
    "all $($appTabs.Count) tabs appear in the full description"
} else {
    "missing: $($missingInStore -join ', ')"
}
Add-Check -name 'Store listing names every tab' -passed ($missingInStore.Count -eq 0) -detail $storeDetail

# --- 3. Help guidance covers all navigation topics ----------------------------

$helpSectionTitles = [regex]::Matches($help, "title:\s*'(?<title>[^']+)'") |
    ForEach-Object { $_.Groups['title'].Value }
$missingHelpTopics = @($appTabs | Where-Object {
    $tab = $_
    $help -notmatch [regex]::Escape($tab) -and
    -not ($tab -eq 'People' -and $help -match 'People and Business')
})
$helpDetail = if ($missingHelpTopics.Count -eq 0) {
    "help text covers all $($appTabs.Count) tabs; $($helpSectionTitles.Count) expandable sections"
} else {
    "missing help topics: $($missingHelpTopics -join ', ')"
}
Add-Check -name 'Help tab covers every navigation topic' -passed ($missingHelpTopics.Count -eq 0) -detail $helpDetail

# --- 4. The README names the store listing folder and the version ------------

Add-Check -name 'README points at the store listing copy' -passed ($readme -match 'store_listing/') `
    -detail 'README should name the store_listing/ folder'
Add-Check -name 'README names the app version' -passed ($readme -match [regex]::Escape($appVersion)) `
    -detail "README should mention pubspec version $appVersion"

# --- 6. Google Play field limits ---------------------------------------------

$shortText = $short.Trim()
Add-Check -name 'Short description fits Google Play' `
    -passed ($shortText.Length -le 80) `
    -detail "$($shortText.Length) of 80 characters used"
Add-Check -name 'Full description fits Google Play' `
    -passed ($full.Trim().Length -le 4000) `
    -detail "$($full.Trim().Length) of 4000 characters used"
Add-Check -name 'Store listing copy is not empty' `
    -passed ($shortText.Length -gt 0 -and $full.Trim().Length -gt 0) `
    -detail 'both store listing files carry copy'

# --- 7. The store listing must not contradict the app ------------------------

# A stock Flutter project carries an android/, ios/, web/ and windows/ folder out
# of the box, whether or not the app ships there. The platforms this app actually
# releases to are the ones the build tasks in .vscode/tasks.json produce, so that
# is what the README has to describe.
$tasksPath = Join-Path $root '.vscode\tasks.json'
$builtPlatforms = @()
if (Test-Path $tasksPath) {
    $tasksText = (Get-Content -Path $tasksPath -Raw) -replace ',(\s*[}\]])', '$1'
    $tasks = ($tasksText | ConvertFrom-Json).tasks
    if ($null -eq $tasks) { $tasks = @() }
    $taskLines = ($tasks | ForEach-Object { "$($_.label) $($_.command) $($_.args -join ' ')" }) -join "`n"
    $builtPlatforms = @()
    foreach ($rule in @(
            @('Android', 'apk|appbundle'),
            @('Web', 'build web'),
            @('Windows', 'build windows|msix')
        )) {
        if ($taskLines -match $rule[1]) {
            $builtPlatforms += $rule[0]
        }
    }
}
if ($builtPlatforms.Count -eq 0) {
    $checks.Add('[SKIP] README names every platform it ships to -- no release platforms found in .vscode/tasks.json')
} else {
    $missingPlatforms = @($builtPlatforms | Where-Object { $readme -notmatch [regex]::Escape($_) })
    $platformDetail = if ($missingPlatforms.Count -eq 0) {
        "platforms: $($builtPlatforms -join ', ')"
    } else {
        "missing: $($missingPlatforms -join ', ')"
    }
    Add-Check -name 'README names every platform it ships to' `
        -passed ($missingPlatforms.Count -eq 0) `
        -detail $platformDetail
}

# --- Report ------------------------------------------------------------------

$reportPath = Join-Path $root 'build\docs-audit.txt'
$reportDirectory = Split-Path -Parent $reportPath
if (-not (Test-Path $reportDirectory)) {
    New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
}
$report = @(
    "Maintenance Manager documentation audit"
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    "App version: $appVersion"
    ''
) + $checks
Set-Content -Path $reportPath -Value $report

$checks | ForEach-Object { Write-Host $_ }
Write-Host ''
Write-Host "Report written to $reportPath"

if ($OpenReport) {
    Start-Process notepad.exe -ArgumentList $reportPath
}

if ($failures.Count -gt 0) {
    Write-Host ''
    Write-Host "Documentation is out of step with the app in $($failures.Count) place(s):" -ForegroundColor Yellow
    $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    exit 1
}

Write-Host 'Documentation matches the app.' -ForegroundColor Green
