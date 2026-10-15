<# : batch
@echo off
set "SELF=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ([IO.File]::ReadAllText($env:SELF))"
echo.
pause
exit /b
#>
# ===== PowerShell section (the batch header above reads and runs this file) =====
$ErrorActionPreference = 'Stop'
try {
  $toolDir = Join-Path $env:LOCALAPPDATA 'OpenInSourcetree'
  $keys = @(
    'HKCU:\Software\Classes\Directory\shell\OpenInSourcetree',
    'HKCU:\Software\Classes\Directory\Background\shell\OpenInSourcetree'
  )
  $removed = 0
  foreach ($k in $keys) {
    if (Test-Path $k) { Remove-Item $k -Recurse -Force; Write-Host "Removed registry key: $k"; $removed++ }
  }
  if (Test-Path $toolDir) { Remove-Item $toolDir -Recurse -Force; Write-Host "Removed launcher folder: $toolDir"; $removed++ }

  if ($removed -eq 0) { Write-Host 'Nothing to remove. Not installed.' -ForegroundColor Yellow }
  else { Write-Host 'Uninstalled.' -ForegroundColor Green }
}
catch {
  Write-Host "Uninstall failed: $($_.Exception.Message)" -ForegroundColor Red
}
