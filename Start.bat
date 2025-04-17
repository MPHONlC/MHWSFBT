@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
set "verifiedScriptURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/Start.bat"
set "verifiedScriptPath=%temp%\Start.bat"
set "currentScriptPath=%~f0"
set "verificationPassed=false"
echo Verifying Script...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%verifiedScriptURL%', '%verifiedScriptPath%')" >nul 2>&1
if not exist "%verifiedScriptPath%" (
    color 04
    echo Failed to verify the script. Exiting...
    title Monster Hunter Wilds : Save File Backup Script --- Failed to verify the script. Exiting...
    timeout /t 5 >nul
    exit /b
)
for /f "delims=" %%H in ('certutil -hashfile "%currentScriptPath%" SHA256 ^| findstr /r "[0-9A-F]"') do set "currentHash=%%H"
for /f "delims=" %%H in ('certutil -hashfile "%verifiedScriptPath%" SHA256 ^| findstr /r "[0-9A-F]"') do set "verifiedHash=%%H"
if "%currentHash%" == "%verifiedHash%" (
    set "verificationPassed=true"
)
if not "%verificationPassed%"=="true" (
    title Monster Hunter Wilds : Save File Backup Script --- The script has been modified or out of date. Exiting...
    color 04
    echo Verification failed. The script has been modified or is out of date. Exiting...
    timeout /t 5 >nul
    exit /b
) else (
    color 0A
    echo Verification passed. Continuing...
    title Monster Hunter Wilds : Save File Backup Script --- Verification passed. Continuing...
    timeout /t 5 >nul
    cls
)
set "downloadURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat"
set "savePath=%USERPROFILE%\AppData\Local\Temp\SFB.bat"
set "currentScriptPath=%~dp0MHWSaveFileBackupTool.bat"
echo Loading script...
title Hunter Wilds : Save File Backup Script --- Loading script...
timeout /t 2 >nul
BITSAdmin /transfer "SFBDownloadJob" "%downloadURL%" "%savePath%" >nul 2>&1
if not exist "%savePath%" (
    color 04
    echo Error: Failed to load script. Exiting...
    title Hunter Wilds : Save File Backup Script --- Failed to load script. Exiting...
    timeout /t 5 >nul
    exit /b
)
set "monitorURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/Monitor.bat"
set "monitorLauncherURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/MonitorLauncher.vbs"
set "monitorPath=%USERPROFILE%\AppData\Local\Temp\Monitor.bat"
set "monitorLauncherPath=%USERPROFILE%\AppData\Local\Temp\MonitorLauncher.vbs"
echo Downloading Monitor.bat from GitHub...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%monitorURL%', '%monitorPath%')" >nul 2>&1
if not exist "%monitorPath%" (
    echo Error: Failed to download Monitor.bat. Exiting...
    title Monster Hunter Wilds : Save File Backup Script --- Error: Failed to download Monitor.bat. Exiting...
    timeout /t 5 >nul
    exit /b
)
echo Downloading Monitor Script...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%monitorLauncherURL%', '%monitorLauncherPath%')" >nul 2>&1
if not exist "%monitorLauncherPath%" (
    echo Error: Failed to download Monitor Script. Exiting...
    title Monster Hunter Wilds : Save File Backup Script --- Error: Failed to download Monitor Script.. Exiting...
    timeout /t 5 >nul
    exit /b
)
echo All monitor scripts downloaded successfully.
title Monster Hunter Wilds : Save File Backup Script --- All Monitor Scripts downloaded successfully.
timeout /t 2 >nul
echo Executing script...
title Hunter Wilds : Save File Backup Script --- Executing script...
timeout /t 2 >nul
if exist "%currentScriptPath%" (
    call "%currentScriptPath%"
) else (
    color 04
    echo Error: MHWSaveFileBackupTool.bat not found in the current directory. Exiting...
    title Hunter Wilds : Save File Backup Script --- Error: MHWSaveFileBackupTool.bat not found in the current directory. Exiting...
    timeout /t 5 >nul
    exit /b
)
color 0A
echo Verifying Integrity...
title Hunter Wilds : Save File Backup Script --- Verifying Integrity...
timeout /t 2 >nul
exit /b
