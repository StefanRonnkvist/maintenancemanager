[CmdletBinding()]
param(
  [switch]$RunPubGet
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
# Kill only this checkout's Gradle daemons. Never stop a Gradle invocation
# that could currently be performing a build.
$gradleProcesses = @()
if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
  $gradleProcesses = @(Get-CimInstance Win32_Process -Filter "Name = 'java.exe'" -ErrorAction SilentlyContinue |
    Where-Object {
      $_.CommandLine -match 'org\.gradle\.launcher\.daemon\.bootstrap\.GradleDaemon' -and
      $_.CommandLine -match [regex]::Escape($root)
    })
}
foreach ($process in $gradleProcesses) {
  Write-Host "Stopping this checkout's Gradle daemon (PID $($process.ProcessId)) to release Gradle cache locks"
  Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
}

# Clear project-local Gradle lock/cache metadata across versions without
# removing downloaded dependencies or other build outputs.
$gradleMetadataRoot = Join-Path $root 'android/.gradle'
if (Test-Path $gradleMetadataRoot) {
  $metadataPaths = @(Get-ChildItem -Path $gradleMetadataRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('buildOutputCleanup', 'fileHashes', 'checksums', 'executionHistory') -or $_.Name -match '^\d+(\.\d+)+$' } |
    ForEach-Object {
      if ($_.Name -match '^\d+(\.\d+)+$') {
        Get-ChildItem -Path $_.FullName -Directory -ErrorAction SilentlyContinue |
          Where-Object { $_.Name -in @('fileHashes', 'checksums', 'executionHistory') }
      } else {
        $_
      }
    } | Select-Object -ExpandProperty FullName -Unique)

  foreach ($path in $metadataPaths) {
    attrib -R $path /S /D | Out-Null
    Remove-Item $path -Recurse -Force
    Write-Host "Reset Gradle lock/cache state: $path"
  }
} else {
  Write-Host 'Android Gradle metadata directory not found; nothing to reset.'
}

$appleEphemeralPaths = @(
  'ios/Flutter/ephemeral/Packages',
  'macos/Flutter/ephemeral/Packages'
)
foreach ($path in $appleEphemeralPaths) {
  if (Test-Path $path) {
    attrib -R $path /S /D | Out-Null
    Remove-Item $path -Recurse -Force
    Write-Host "Removed stale Flutter ephemeral package cache: $path"
  }
}

if ($RunPubGet) {
  Write-Host 'Running: flutter pub get'
  flutter pub get
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}
