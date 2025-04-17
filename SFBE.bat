@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script - Cleanup

rem ====================================================
rem SECTION 1 – Setup and Download of handle.exe
rem ====================================================
set "tempDir=%USERPROFILE%\AppData\Local\Temp"
set "handleZip=%tempDir%\Handle.zip"
set "handlePath=%tempDir%\handle.exe"
set "downloadURL=https://download.sysinternals.com/files/Handle.zip"

rem Check if handle.exe exists; if not, download and extract it.
if exist "%handlePath%" (
    echo [INFO] handle.exe already exists in %tempDir%. Skipping download.
) else (
    echo [INFO] Downloading Handle.exe from Sysinternals...
    title Monster Hunter Wilds : Downloading Handle.exe...
    rem Using curl for progress display (job state, bytes transferred, total bytes, transfer rate).
    curl -L --progress-bar "%downloadURL%" -o "%handleZip%"
    if errorlevel 1 (
        echo [ERROR] Failed to download Handle.zip. Exiting...
        title Monster Hunter Wilds : Error: Download failed.
        timeout /t 5 >nul
        exit /b
    )
    echo [INFO] Extracting Handle.exe...
    powershell -noprofile -command "Expand-Archive -Path '%handleZip%' -DestinationPath '%tempDir%' -Force" >nul 2>&1
    if not exist "%handlePath%" (
        echo [ERROR] Failed to extract Handle.exe. Exiting...
        title Monster Hunter Wilds : Error: Extraction failed.
        timeout /t 5 >nul
        exit /b
    )
    del /f /q "%handleZip%" >nul 2>&1
    echo [INFO] handle.exe downloaded and extracted.
)

rem ====================================================
rem SECTION 2 – Wait for MonsterHunterWilds.exe to Close
rem ====================================================
:CHECK_MHW
tasklist | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 (
    echo [INFO] MonsterHunterWilds.exe is running. Waiting 5 seconds...
    timeout /t 5 >nul
    goto CHECK_MHW
) else (
    echo [INFO] MonsterHunterWilds.exe is not running. Proceeding with cleanup.
)

rem ====================================================
rem SECTION 3 – Delete Specified Files from %tempDir%
rem ====================================================
rem Files to delete: Start.bat, SFB.bat, Monitor.bat, MonitorLauncher.bat, MHWSaveFileBackupTool.bat.
rem Note: handle.exe and handle64.exe have been removed from deletion.
setlocal EnableDelayedExpansion
set "filesList=Start.bat SFB.bat Monitor.bat MonitorLauncher.bat MHWSaveFileBackupTool.bat"

for %%F in (%filesList%) do (
    if exist "%tempDir%\%%F" (
        echo.
        echo [INFO] Processing file: %tempDir%\%%F
        rem If the file is a batch file (.bat), use WMIC to find and terminate running instances.
        if /I "%%~xF"==".bat" (
            echo [INFO] %%F is a batch file. Checking for running instances via WMIC...
            for /f "tokens=2 delims==" %%A in ('wmic process where "CommandLine like '%%%F%%'" get ProcessId /value ^| find "="') do (
                set "PID=%%A"
                rem Remove any spaces from the PID value.
                set "PID=!PID: =!"
                if not "!PID!"=="" (
                    echo [INFO] Terminating process with PID !PID! for %%F...
                    taskkill /PID !PID! /F >nul 2>&1
                )
            )
        ) else (
            rem For non-.bat files (if any), use standard tasklist lookup.
            tasklist | findstr /i "%%F" >nul
            if !errorlevel! equ 0 (
                echo [INFO] Process corresponding to %%F is running. Attempting to terminate...
                taskkill /f /im "%%F" >nul 2>&1
            )
        )
        rem Allow a brief moment for processes to terminate.
        timeout /t 1 >nul
        rem Attempt to delete the file.
        echo [INFO] Deleting file %%F...
        del /f /q "%tempDir%\%%F" >nul 2>&1
        if exist "%tempDir%\%%F" (
            echo [ERROR] Unable to delete %%F at first attempt. Retrying in 5 seconds...
            timeout /t 5 >nul
            del /f /q "%tempDir%\%%F" >nul 2>&1
        )
        if not exist "%tempDir%\%%F" (
            echo [INFO] %%F deleted successfully.
        ) else (
            echo [ERROR] Unable to delete %%F.
        )
    ) else (
        echo [INFO] File %%F not found. Skipping...
    )
)
endlocal

rem ====================================================
rem SECTION 4 – Empty the Recycle Bin
rem ====================================================
echo.
echo [INFO] Emptying Recycle Bin...
powershell -noprofile -command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

rem ====================================================
rem SECTION 5 – Completion
rem ====================================================
echo.
echo [INFO] Cleanup completed. Exiting...
title Monster Hunter Wilds : Cleanup completed. Exiting...
timeout /t 2 >nul
exit /b
