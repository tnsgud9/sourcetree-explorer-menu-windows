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
  $st      = Join-Path $env:LOCALAPPDATA 'SourceTree\SourceTree.exe'
  $toolDir = Join-Path $env:LOCALAPPDATA 'OpenInSourcetree'
  $vbs     = Join-Path $toolDir 'open-sourcetree.vbs'
  $keys = @(
    'HKCU:\Software\Classes\Directory\shell\OpenInSourcetree',            # right-click on a folder
    'HKCU:\Software\Classes\Directory\Background\shell\OpenInSourcetree'  # right-click inside a folder
  )

  if (-not (Test-Path $st)) { throw "SourceTree.exe not found: $st" }

  New-Item -ItemType Directory -Force -Path $toolDir | Out-Null

  # Launcher: walks up from the clicked path to find .git (folder or file)
  # and opens the repository root in Sourcetree.
  $vbsCode = @'
Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")
If WScript.Arguments.Count = 0 Then WScript.Quit
st = "__ST__"
p = WScript.Arguments(0)
If fso.FileExists(p) Then p = fso.GetParentFolderName(p)
d = p
If Right(d, 1) = "\" Then d = Left(d, Len(d) - 1)
Do While d <> ""
  If fso.FolderExists(d & "\.git") Or fso.FileExists(d & "\.git") Then
    sh.Run """" & st & """ -f """ & d & """", 1, False
    WScript.Quit
  End If
  d = fso.GetParentFolderName(d)
Loop
MsgBox "Not a Git repository." & vbCrLf & p, 48, "Open in Sourcetree"
'@
  Set-Content -Path $vbs -Value $vbsCode.Replace('__ST__', $st) -Encoding Unicode

  foreach ($k in $keys) {
    New-Item -Path $k -Force | Out-Null
    Set-ItemProperty -Path $k -Name '(default)' -Value 'Open in Sourcetree'
    Set-ItemProperty -Path $k -Name 'Icon' -Value "`"$st`",0"
    New-Item -Path "$k\command" -Force | Out-Null
    Set-ItemProperty -Path "$k\command" -Name '(default)' -Value "wscript.exe `"$vbs`" `"%V`""
  }
  Write-Host 'Installed. Right-click a folder and choose "Open in Sourcetree".' -ForegroundColor Green
}
catch {
  Write-Host "Install failed: $($_.Exception.Message)" -ForegroundColor Red
}
