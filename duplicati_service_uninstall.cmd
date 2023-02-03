@echo off

net stop duplicati

TASKKILL /F /IM duplicati* /T

"C:\Program Files\Duplicati 2\Duplicati.WindowsService.exe" uninstall

del /Q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Duplicati-GUI-TrayIcon.lnk" 
del /Q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Duplicati-GUI-TrayIcon.lnk"

msiexec /x {0285A68F-7B40-4C20-953B-A7C318BE5518} /passive /norestart

del /Q "%~dp0InstallUtil.InstallLog" 2>nul
