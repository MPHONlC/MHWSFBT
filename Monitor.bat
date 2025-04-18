@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Monitoring Scripts
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
echo Monster Hunter Wilds : Save File Backup Script --- [INFO] Waiting for other proccesses to finish loading...
timeout /t 60 > nul
set "SFBScript=SFB.bat"
set "BackupToolScript=MHWSaveFileBackupTool.bat"
set "StartScript=Start.bat"
set "SFBEPath=%USERPROFILE%\AppData\Local\Temp\SFBE.bat"
set "SFBEUrl=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/SFBE.bat"
if not exist "%SFBEPath%" (
    color 06
    title Monster Hunter Wilds : Save File Backup Script --- [INFO] Script not found in %USERPROFILE%\AppData\Local\Temp.
    echo [INFO] Script not found in %USERPROFILE%\AppData\Local\Temp. Fetching file...
    curl -L --progress-bar "%SFBEUrl%" -o "%SFBEPath%"
    if errorlevel 1 (
	color 04
	title Monster Hunter Wilds : Save File Backup Script --- [ERROR] Failed to load script. Exiting...
        echo [ERROR] Failed to load script. Exiting...
        timeout /t 2 >nul
        exit /b
    )
    color 0A
    title Monster Hunter Wilds : Save File Backup Script --- [INFO] Scriptloaded successfully.
    echo [INFO] Scriptloaded successfully.
    timeout /t 1 >nul
) else (
    echo [INFO] SFBE.bat found in %USERPROFILE%\AppData\Local\Temp. Skipping download.
)
setlocal EnableDelayedExpansion
color 0A
:CheckLoop
timeout /t 2 >nul
set "SFBRunning=0"
set "BackupToolRunning=0"
set "StartScriptRunning=0"
for /f "skip=1 tokens=*" %%A in (
    'wmic process where "Name='cmd.exe' and CommandLine like '%%%SFBScript%%%'" get ProcessId 2^>nul ^| findstr /R "[0-9]"'
) do (
    set "SFBRunning=1"
)
for /f "skip=1 tokens=*" %%A in (
    'wmic process where "Name='cmd.exe' and CommandLine like '%%%BackupToolScript%%%'" get ProcessId 2^>nul ^| findstr /R "[0-9]"'
) do (
    set "BackupToolRunning=1"
)
for /f "skip=1 tokens=*" %%A in (
    'wmic process where "Name='cmd.exe' and CommandLine like '%%%StartScript%%%'" get ProcessId 2^>nul ^| findstr /R "[0-9]"'
) do (
    set "StartScriptRunning=1"
)
if !SFBRunning! EQU 1 goto LoopAgain
if !BackupToolRunning! EQU 1 goto LoopAgain
if !StartScriptRunning! EQU 1 goto LoopAgain
color 06
title Monster Hunter Wilds : Save File Backup Script --- All monitored scripts have been closed. Executing cleanup...
echo All monitored scripts have been closed. Executing cleanup...
call "%SFBEPath%"
title Monster Hunter Wilds : Save File Backup Script --- Cleanup completed.
echo Cleanup completed.
timeout /t 2 >nul
exit /b
:LoopAgain
goto CheckLoop
