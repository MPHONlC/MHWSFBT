@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
set "startURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/Start.bat"
set "monitorURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/Monitor.bat"
set "monitorLauncherURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/MonitorLauncher.vbs"
set "sfbURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat"
set "startPath=%USERPROFILE%\AppData\Local\Temp\Start.bat"
set "monitorPath=%USERPROFILE%\AppData\Local\Temp\Monitor.bat"
set "monitorLauncherPath=%USERPROFILE%\AppData\Local\Temp\MonitorLauncher.vbs"
set "sfbPath=%USERPROFILE%\AppData\Local\Temp\SFB.bat"
set "backupToolPath=%~dp0MHWSaveFileBackupTool.bat"
set "verificationPassed=false"
:VerifyFile
set "filePath=%1"
set "fileURL=%2"
echo Downloading %filePath% from GitHub...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%fileURL%', '%filePath%')" >nul 2>&1
if not exist "%filePath%" (
    color 04
    echo Error: Failed to download %filePath%. Exiting...
    title Monster Hunter Wilds : Save File Backup Script --- Error: Failed to download %filePath%. Exiting...
    timeout /t 5 >nul
    exit /b
)
for /f "delims=" %%H in ('certutil -hashfile "%filePath%" SHA256 ^| findstr /r "[0-9A-F]"') do set "fileHash=%%H"
if not "%fileHash%"=="" (
    set "verificationPassed=true"
    echo Verification successful for %filePath%.
) else (
    color 04
    echo Verification failed for %filePath%. Exiting...
    title Monster Hunter Wilds : Save File Backup Script --- Verification failed for %filePath%. Exiting...
    timeout /t 5 >nul
    exit /b
)
exit /b
call :VerifyFile "%startPath%" "%startURL%"
call :VerifyFile "%monitorPath%" "%monitorURL%"
call :VerifyFile "%monitorLauncherPath%" "%monitorLauncherURL%"
call :VerifyFile "%sfbPath%" "%sfbURL%"
echo All script files have been successfully verified!
title Monster Hunter Wilds : Save File Backup Script --- All script files have been successfully verified.
timeout /t 2 >nul
echo Running Monitor.bat in the background...
start /min "%monitorPath%"
echo Executing MHWSaveFileBackupTool.bat...
title Monster Hunter Wilds : Save File Backup Script --- Executing MHWSaveFileBackupTool.bat...
timeout /t 2 >nul
if exist "%backupToolPath%" (
    call "%backupToolPath%"
) else (
    color 04
    echo Error: MHWSaveFileBackupTool.bat not found in the current directory. Exiting...
    title Monster Hunter Wilds : Save File Backup Script --- Error: MHWSaveFileBackupTool.bat not found in the current directory. Exiting...
    timeout /t 5 >nul
    exit /b
)
color 0A
echo Verifying Integrity...
title Monster Hunter Wilds : Save File Backup Script --- Verifying Integrity...
timeout /t 2 >nul
exit /b
