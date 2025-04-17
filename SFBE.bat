@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Cleanup
set "tempDir=%USERPROFILE%\AppData\Local\Temp"
set "handleZip=%tempDir%\Handle.zip"
set "handlePath=%tempDir%\handle.exe"
set "downloadURL=https://download.sysinternals.com/files/Handle.zip"
if exist "%handlePath%" (
    color 06
	title Monster Hunter Wilds : Save File Backup Script --- [INFO] handle.exe already exists in %tempDir%. Skipping download.
    echo [INFO] handle.exe already exists in %tempDir%. Skipping download.
	timeout /t 2 >nul
) else (
    color 03
    echo [INFO] Downloading Handle.exe from Sysinternals...
    title Monster Hunter Wilds : Downloading Handle.exe...
    curl -L --progress-bar "%downloadURL%" -o "%handleZip%"
    if errorlevel 1 (
	    color 04
        echo [ERROR] Failed to download Handle.zip. Exiting...
        title Monster Hunter Wilds : Save File Backup Script --- Error: Download failed. Exiting...
        timeout /t 2 >nul
        exit /b
    )
	color 03
    echo [INFO] Extracting Handle.exe...
    powershell -noprofile -command "Expand-Archive -Path '%handleZip%' -DestinationPath '%tempDir%' -Force" >nul 2>&1
    if not exist "%handlePath%" (
	    color 04
        echo [ERROR] Failed to extract Handle.exe. Exiting...
        title Monster Hunter Wilds : Save File Backup Script --- Error: Extraction failed. Exiting...
        timeout /t 2 >nul
        exit /b
    )
    del /f /q "%handleZip%" >nul 2>&1
	color 0A
	title Monster Hunter Wilds : Save File Backup Script --- handle.exe downloaded and extracted.
    echo [INFO] handle.exe downloaded and extracted.
	cls
)
color 0A
:CHECK_MHW
tasklist | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 (
    color 06
    echo [INFO] MonsterHunterWilds.exe is running. Waiting for proccess to close...
	title Monster Hunter Wilds : Save File Backup Script --- [INFO] MonsterHunterWilds.exe is running. Waiting for proccess to close...
    timeout /t 5 >nul
    goto CHECK_MHW
) else (
    color 0A
    title Monster Hunter Wilds : Save File Backup Script --- [INFO] MonsterHunterWilds.exe is not running. Proceeding with cleanup.
    echo [INFO] MonsterHunterWilds.exe is not running. Proceeding with cleanup.
)
setlocal EnableDelayedExpansion
set "filesList=Start.bat SFB.bat Monitor.bat MonitorLauncher.bat MHWSaveFileBackupTool.bat"
for %%F in (%filesList%) do (
    if exist "%tempDir%\%%F" (
        echo.
        echo [INFO] Processing file: %tempDir%\%%F
        if /I "%%~xF"==".bat" (
		    color 03
		    title Monster Hunter Wilds : Save File Backup Script --- [INFO] %%F is a batch file. Checking for running instances via WMIC...
            echo [INFO] Checking for running instances via WMIC...
            for /f "tokens=2 delims==" %%A in ('wmic process where "CommandLine like '%%%F%%'" get ProcessId /value ^| find "="') do (
                set "PID=%%A"
                set "PID=!PID: =!"
                if not "!PID!"=="" (
				    color 05
				    title Monster Hunter Wilds : Save File Backup Script --- [INFO] Terminating process with PID !PID! for %%F...
                    echo [INFO] Terminating process with PID !PID! for %%F...
                    taskkill /PID !PID! /F >nul 2>&1
                )
            )
        ) else (
            tasklist | findstr /i "%%F" >nul
            if !errorlevel! equ 0 (
			    color 06
				title Monster Hunter Wilds : Save File Backup Script --- [INFO] Process corresponding to %%F is running. Attempting to terminate...
                echo [INFO] Process corresponding to %%F is running. Attempting to terminate...
                taskkill /f /im "%%F" >nul 2>&1
            )
        )
        timeout /t 1 >nul
        echo [INFO] Deleting file %%F...
        del /f /q "%tempDir%\%%F" >nul 2>&1
        if exist "%tempDir%\%%F" (
		    title Monster Hunter Wilds : Save File Backup Script --- [ERROR] Unable to delete %%F at first attempt. Retrying in 5 seconds...
            echo [ERROR] Unable to delete %%F at first attempt. Retrying in 5 seconds...
            timeout /t 2 >nul
            del /f /q "%tempDir%\%%F" >nul 2>&1
        )
        if not exist "%tempDir%\%%F" (
		    color 0A
		    title Monster Hunter Wilds : Save File Backup Script --- [INFO] %%F deleted successfully.
            echo [INFO] %%F deleted successfully.
			timeout /t 2 >nul
        ) else (
		    color 04
		    title Monster Hunter Wilds : Save File Backup Script --- [ERROR] Unable to delete %%F.
            echo [ERROR] Unable to delete %%F.
			timeout /t 2 >nul
        )
    ) else (
	    color 06
	    title Monster Hunter Wilds : Save File Backup Script --- [INFO] File %%F not found. Skipping...
        echo [INFO] File %%F not found. Skipping...
		timeout /t 2 >nul
    )
)
endlocal
echo.
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Loading...
echo [INFO] Emptying Recycle Bin...
cls
powershell -noprofile -command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo.
title Monster Hunter Wilds : Save File Backup Script --- [INFO] Cleanup completed. Exiting...
echo [INFO] Cleanup completed. Exiting...
timeout /t 2 >nul
exit /b
