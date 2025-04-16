@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script
set "downloadURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat"
set "savePath=%USERPROFILE%\AppData\Local\Temp\SFB.bat"
set "currentScriptPath=%~dp0MHWSaveFileBackupTool.bat"
echo Downloading SFB.bat from GitHub using BITSAdmin...
timeout /t 2 >nul
BITSAdmin /transfer "SFBDownloadJob" "%downloadURL%" "%savePath%" >nul 2>&1
if not exist "%savePath%" (
    echo Error: Failed to download SFB.bat. Exiting...
    timeout /t 5 >nul
    exit /b
)
echo Download complete. Executing MHWSaveFileBackupTool.bat...
timeout /t 2 >nul
if exist "%currentScriptPath%" (
    call "%currentScriptPath%"
) else (
    echo Error: MHWSaveFileBackupTool.bat not found in the current directory. Exiting...
    timeout /t 5 >nul
    exit /b
)
echo Cleaning up and exiting...
timeout /t 2 >nul
exit /b
