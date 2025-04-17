@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script - Cleanup

rem Set directories and file paths
set "tempDir=%USERPROFILE%\AppData\Local\Temp"
set "handleZip=%tempDir%\Handle.zip"
set "handlePath=%tempDir%\handle.exe"
set "downloadURL=https://download.sysinternals.com/files/Handle.zip"

if exist "%handlePath%" (
    echo [INFO] handle.exe already exists in %tempDir%. Skipping download.
) else (
    echo [INFO] Downloading Handle.exe from Sysinternals...
    title Monster Hunter Wilds : Save File Backup Script - Downloading Handle.exe...
    rem Using curl so the progress bar displays job progress, transferred bytes, total bytes, and transfer rate.
    curl -L --progress-bar "%downloadURL%" -o "%handleZip%"
    if errorlevel 1 (
        echo [ERROR] Failed to download Handle.zip. Exiting...
        title Monster Hunter Wilds : Save File Backup Script - Error during download.
        timeout /t 5 >nul
        exit /b
    )
    echo [INFO] Extracting Handle.exe...
    powershell -noprofile -command "Expand-Archive -Path '%handleZip%' -DestinationPath '%tempDir%' -Force" >nul 2>&1
    if not exist "%handlePath%" (
        echo [ERROR] Failed to extract Handle.exe. Exiting...
        title Monster Hunter Wilds : Save File Backup Script - Error during extraction.
        timeout /t 5 >nul
        exit /b
    )
    del /f /q "%handleZip%" >nul 2>&1
    echo [INFO] handle.exe is ready.
)

:CHECK_MHW
tasklist | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 (
    echo [INFO] MonsterHunterWilds.exe is currently running. Waiting 5 seconds for it to close...
    timeout /t 5 >nul
    goto CHECK_MHW
) else (
    echo [INFO] MonsterHunterWilds.exe is not running. Proceeding with cleanup.
)

setlocal EnableDelayedExpansion
set "filesList=Start.bat SFB.bat handle.exe handle64a.exe Monitor.bat MonitorLauncher.bat"

for %%F in (%filesList%) do (
    if exist "%tempDir%\%%F" (
        echo.
        echo [INFO] Processing file: %tempDir%\%%F
        rem For handle.exe, skip checking if the file is in use.
        if /I "%%F"=="handle.exe" (
            set "handleResult=0"
        ) else (
            rem Check if the file is in use using handle.exe:
            "%handlePath%" "%tempDir%\%%F" | findstr /i "No matching handles" >nul
            set "handleResult=!errorlevel!"
        )
        
        rem Check if a process with that file name is running:
        tasklist | findstr /i "%%F" >nul
        set "tasklistResult=!errorlevel!"

        if !handleResult! equ 0 if !tasklistResult! equ 1 (
            echo [INFO] File %%F is not in use. Deleting...
            title Monster Hunter Wilds : Save File Backup Script --- File %%F is not in use. Deleting...
            del /f /q "%tempDir%\%%F" >nul 2>&1
            echo [INFO] File %%F deleted.
            timeout /t 5 >nul
        ) else (
            echo [INFO] File %%F is in use. Skipping deletion.
            title Monster Hunter Wilds : Save File Backup Script --- File %%F is in use. Skipping deletion.
            timeout /t 5 >nul
        )
    )
)
endlocal
echo [INFO] Cleanup completed. Exiting...
title Monster Hunter Wilds : Save File Backup Script --- Cleanup completed. Exiting...
timeout /t 2 >nul
del /f /q "%handlePath%" >nul 2>&1
exit /b
