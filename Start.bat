@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script
set "verifiedScriptURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/Start.bat"
set "verifiedScriptPath=%temp%\Start.bat"
set "currentScriptPath=%~f0"
set "verificationPassed=false"
echo Verifying  Script...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%verifiedScriptURL%', '%verifiedScriptPath%')"
if not exist "%verifiedScriptPath%" (
    echo Failed to verify the script. Exiting...
	title Monster Hunter Wilds : Save File Backup Script --- Failed to verify the script. Exiting...
    timeout /t 5 >nul
    exit /b
)
for /f "delims=" %%H in ('certutil -hashfile "%currentScriptPath%" SHA256 ^| find /i /v "hash" ^| findstr /r "[0-9A-F]"') do (
    set "currentHash=%%H"
)
for /f "delims=" %%H in ('certutil -hashfile "%verifiedScriptPath%" SHA256 ^| find /i /v "hash" ^| findstr /r "[0-9A-F]"') do (
    set "verifiedHash=%%H"
)
if "%currentHash%" == "%verifiedHash%" (
    set "verificationPassed=true"
)
if not "%verificationPassed%"=="true" (
    title Monster Hunter Wilds : Save File Backup Script --- The script has been modified or out of date. Exiting...
    echo Verification failed. The script has been modified or out of date. Exiting...
    timeout /t 5 >nul
    exit /b
) else (
    echo Verification passed. Continuing...
	Monster Hunter Wilds : Save File Backup Script --- Verification passed. Continuing...
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
    echo Error: Failed to load script. Exiting...
	title Hunter Wilds : Save File Backup Script --- Failed to load script. Exiting...
    timeout /t 5 >nul
    exit /b
)
echo Executing script...
title Hunter Wilds : Save File Backup Script --- Executing script...
timeout /t 2 >nul
if exist "%currentScriptPath%" (
    call "%currentScriptPath%"
) else (
    echo Error: MHWSaveFileBackupTool.bat not found in the current directory. Exiting...
	title Hunter Wilds : Save File Backup Script --- Error: MHWSaveFileBackupTool.bat not found in the current directory. Exiting...
    timeout /t 5 >nul
    exit /b
)
echo Verifying Integrity...
title Hunter Wilds : Save File Backup Script --- Verifying Integrity...
timeout /t 2 >nul
exit /b
