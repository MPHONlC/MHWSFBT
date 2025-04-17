@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Monitoring Scripts
set "SFBScript=SFB.bat"
set "BackupToolScript=MHWSaveFileBackupTool.bat"
set "StartScript=Start.bat"
set "SFBEPath=%USERPROFILE%\AppData\Local\Temp\SFBE.bat"
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
