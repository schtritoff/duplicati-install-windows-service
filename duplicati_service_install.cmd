@echo off
setlocal EnableDelayedExpansion

:: guide for windows service https://duplicati.readthedocs.io/en/latest/07-other-command-line-utilities/#duplicatiwindowsserviceexe

:: uninstall first
call "%~dp0duplicati_service_uninstall.cmd"

:: make sure there is a folder for "DUPLICATI_HOME" so we dont use default one (C:\Windows\System32\config\systemprofile\AppData\Local\Duplicati) which could get deleted in some cases - https://forum.duplicati.com/t/installed-windows-10-fall-creators-update-now-everything-is-missing-in-duplicati/1073/7
mkdir "C:\ProgramData\Duplicati\home"
mkdir "C:\ProgramData\Duplicati\logs"

:: run installer - msi exit codes https://learn.microsoft.com/en-us/windows/win32/msi/error-codes
if not exist "C:\Program Files\Duplicati 2\Duplicati.WindowsService.exe" (
  msiexec /i "%~dp0duplicati-2.0.7.2_canary_2023-05-25-x64.msi" /l*v "C:\ProgramData\Duplicati\logs\installer.log" /passive /norestart TRANSFORMS="%~dp0duplicati-noshortcuts.mst" FORSERVICE=1
  IF NOT !errorlevel! EQU 0 IF NOT !errorlevel! EQU 1641 IF NOT !errorlevel! EQU 3010 (EXIT /B !errorlevel!)
)

:: remove default shortcuts since it will start server component as user program
del /Q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\Duplicati 2.lnk" 2>nul
del /Q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Duplicati 2.lnk" 2>nul
del /Q "C:\Users\Public\Desktop\Duplicati 2.lnk" 2>nul

:: install service with some default options
:: https://duplicati.readthedocs.io/en/latest/07-other-command-line-utilities/#duplicatiserverexe
"C:\Program Files\Duplicati 2\Duplicati.WindowsService.exe" install --webservice-interface=loopback --log-retention=3M --server-datafolder="C:\ProgramData\Duplicati\home" --unencrypted-database --log-file="C:\ProgramData\Duplicati\logs\duplicati.log" --usage-reporter-level=None
move /y "%~dp0InstallUtil.InstallLog" "C:\ProgramData\Duplicati\logs"
net start duplicati

:: create shortcut for tray icon
powershell -ExecutionPolicy Bypass -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Duplicati-GUI-TrayIcon.lnk'); $Shortcut.TargetPath = 'C:\Program Files\Duplicati 2\Duplicati.GUI.TrayIcon.exe'; $Shortcut.Arguments='--no-hosted-server' ;$Shortcut.Save()"
copy /y "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Duplicati-GUI-TrayIcon.lnk" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Duplicati-GUI-TrayIcon.lnk"

:: run web gui to create or import backup configuration
:: for automating next steps see https://github.com/duplicati/duplicati/pull/3595
