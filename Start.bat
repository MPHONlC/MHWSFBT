@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script

REM Define paths and URLs
set "downloadURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat"
set "savePath=%USERPROFILE%\AppData\Local\Temp\SFB.bat"
set "currentScriptPath=%~dp0MHWSaveFileBackupTool.bat"

REM Notify the user
echo Downloading SFB.bat from GitHub using BITSAdmin...
timeout /t 2 >nul

REM Use BITSAdmin to download the file
BITSAdmin /transfer "SFBDownloadJob" "%downloadURL%" "%savePath%" >nul 2>&1

REM Verify if the file was downloaded successfully
if not exist "%savePath%" (
    echo Error: Failed to download SFB.bat. Exiting...
    timeout /t 5 >nul
    exit /b
)

REM Notify the user of success
echo Download complete. Executing MHWSaveFileBackupTool.bat...
timeout /t 2 >nul

REM Execute MHWSaveFileBackupTool.bat
if exist "%currentScriptPath%" (
    call "%currentScriptPath%"
) else (
    echo Error: MHWSaveFileBackupTool.bat not found in the current directory. Exiting...
    timeout /t 5 >nul
    exit /b
)

REM Properly close the script and ensure it doesn't run in the background
echo Cleaning up and exiting...
timeout /t 2 >nul
exit /b
