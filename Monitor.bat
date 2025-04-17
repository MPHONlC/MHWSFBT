@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Monitoring Scripts
set "monitorURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/MonitorLauncher.vbs"
set "monitorPath=%USERPROFILE%\AppData\Local\Temp\MonitorLauncher.vbs"
set "SFBScript=SFB.bat"
set "BackupToolScript=MHWSaveFileBackupTool.bat"
set "StartScript=Start.bat"
set "SFBEPath=%USERPROFILE%\AppData\Local\Temp\SFBE.bat"
if not exist "%monitorPath%" (
    echo Downloading MonitorLauncher.vbs...
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%monitorURL%', '%monitorPath%')" >nul 2>&1
    if not exist "%monitorPath%" (
        echo Error: Failed to download MonitorLauncher.vbs. Exiting...
        title Monster Hunter Wilds : Save File Backup Script --- Error: Failed to download MonitorLauncher.vbs. Exiting...
        timeout /t 5 >nul
        exit /b
    )
)
echo Running MonitorLauncher.vbs in the background...
wscript.exe "%monitorPath%"
:CheckLoop
timeout /t 2 >nul
tasklist | find /i "%SFBScript%" >nul
set "SFBRunning=%errorlevel%"
tasklist | find /i "%BackupToolScript%" >nul
set "BackupToolRunning=%errorlevel%"
tasklist | find /i "%StartScript%" >nul
set "StartScriptRunning=%errorlevel%"
if %SFBRunning% neq 0 if %BackupToolRunning% neq 0 if %StartScriptRunning% neq 0 (
    echo All monitored scripts have been closed. Executing cleanup...
    call "%SFBEPath%"
    echo Cleanup completed.
    timeout /t 2 >nul
    exit /b
)
goto CheckLoop
