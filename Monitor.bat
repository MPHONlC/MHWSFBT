@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Monitoring Scripts

:: Removed the MonitorLauncher.vbs download and execution since it is no longer needed.
set "SFBScript=SFB.bat"
set "BackupToolScript=MHWSaveFileBackupTool.bat"
set "StartScript=Start.bat"
set "SFBEPath=%USERPROFILE%\AppData\Local\Temp\SFBE.bat"

:CheckLoop
timeout /t 2 >nul

:: Check if SFB.bat is running
tasklist | find /i "%SFBScript%" >nul
set "SFBRunning=%errorlevel%"

:: Check if MHWSaveFileBackupTool.bat is running
tasklist | find /i "%BackupToolScript%" >nul
set "BackupToolRunning=%errorlevel%"

:: Check if Start.bat is running
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
