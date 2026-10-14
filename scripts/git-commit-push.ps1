[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Message
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
function Invoke-Git([string[]]$Arguments) {
    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}

Invoke-Git -Arguments @('rev-parse', '--is-inside-work-tree')
Invoke-Git -Arguments @('add', '--all')

# Fail clearly without creating an empty commit when the working tree is clean.
& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host 'No staged changes to commit; nothing was pushed.'
    exit 0
}
if ($LASTEXITCODE -ne 1) {
    throw "Unable to inspect staged changes (git diff --cached --quiet exited $LASTEXITCODE)"
}

Invoke-Git -Arguments @('commit', '-m', $Message)
Invoke-Git -Arguments @('push')
