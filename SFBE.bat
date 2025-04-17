@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script - Cleanup

rem Set directories and file paths
set "tempDir=%USERPROFILE%\AppData\Local\Temp"
set "handleZip=%tempDir%\Handle.zip"
set "handlePath=%tempDir%\handle.exe"
set "downloadURL=https://download.sysinternals.com/files/Handle.zip"

rem ====================================================
rem SECTION 1 – Check for handle.exe & Download if Needed
rem ====================================================
if exist "%handlePath%" (
    echo [INFO] handle.exe already exists in %tempDir%. Skipping download.
) else (
    echo [INFO] Downloading Handle.exe from Sysinternals...
    title Monster Hunter Wilds : Save File Backup Script - Downloading Handle.exe...
    rem Using curl to display progress
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

rem ====================================================
rem SECTION 2 – Check if MonsterHunterWilds.exe Is Running
rem ====================================================
:CHECK_MHW
tasklist | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 (
    echo [INFO] MonsterHunterWilds.exe is currently running. Waiting 5 seconds for it to close...
    timeout /t 5 >nul
    goto CHECK_MHW
) else (
    echo [INFO] MonsterHunterWilds.exe is not running. Proceeding with cleanup.
)

rem ====================================================
rem SECTION 3 – Terminate and Delete Files From %tempDir%
rem ====================================================
setlocal EnableDelayedExpansion
set "filesList=handle64a.exe SFB.bat Monitor.bat MHWSaveFileBackupTool.bat Start.bat MonitorLauncher.bat"

for %%F in (%filesList%) do (
    if exist "%tempDir%\%%F" (
        echo.
        echo [INFO] Processing file: %tempDir%\%%F
        rem Check if a process with the file name is running:
        tasklist | findstr /i "%%F" >nul
        if !errorlevel! equ 0 (
            echo [INFO] File %%F is running as a process. Attempting to terminate...
            taskkill /f /im "%%F" >nul 2>&1
            if !errorlevel! neq 0 (
                echo [ERROR] Failed to terminate process for %%F. Skipping deletion.
                timeout /t 5 >nul
                continue
            ) else (
                echo [INFO] Process for %%F terminated successfully.
            )
        )
        rem Attempt to delete the file
        echo [INFO] Deleting file: %%F
        del /f /q "%tempDir%\%%F" >nul 2>&1
        if exist "%tempDir%\%%F" (
            echo [ERROR] Failed to delete %%F. Retrying after 5 seconds...
            timeout /t 5 >nul
            del /f /q "%tempDir%\%%F" >nul 2>&1
        )
        if not exist "%tempDir%\%%F" (
            echo [INFO] File %%F deleted successfully.
        ) else (
            echo [ERROR] Unable to delete %%F. Moving to next file.
        )
    ) else (
        echo [INFO] File %%F does not exist. Skipping...
    )
)
endlocal

rem ====================================================
rem SECTION 4 – Script Completion
rem ====================================================
echo [INFO] Cleanup completed. Exiting...
title Monster Hunter Wilds : Save File Backup Script --- Cleanup completed. Exiting...
timeout /t 2 >nul
exit /b
