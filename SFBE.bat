@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Starting Cleanup...

rem --- Disable QuickEdit for reliability ---
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do (
    reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
)

rem --- Set up Temp directory and download details ---
set "tempDir=%USERPROFILE%\AppData\Local\Temp"
set "handleZip=%tempDir%\Handle.zip"
set "handlePath=%tempDir%\handle.exe"
set "downloadURL=https://download.sysinternals.com/files/Handle.zip"

rem --- Download and extract handle.exe if not already present ---
if exist "%handlePath%" (
    color 06
    title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] handle.exe already exists in %tempDir%. Skipping download.
    echo [INFO] handle.exe already exists in %tempDir%. Skipping download.
    timeout /t 2 >nul
    cls
) else (
    color 03
    echo [INFO] Downloading Handle.exe from Sysinternals...
    title Monster Hunter Wilds : [CLEANUP] Downloading Handle.exe...
    curl -L --progress-bar "%downloadURL%" -o "%handleZip%"
    if errorlevel 1 (
        color 04
        echo [ERROR] Failed to download Handle.zip. Exiting...
        title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Error: Download failed. Exiting...
        timeout /t 2 >nul
        cls
        exit
    )
    color 03
    echo [INFO] Extracting Handle.exe...
    powershell -noprofile -command "Expand-Archive -Path '%handleZip%' -DestinationPath '%tempDir%' -Force" >nul 2>&1
    if not exist "%handlePath%" (
        color 04
        echo [ERROR] Failed to extract Handle.exe. Exiting...
        title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Error: Extraction failed. Exiting...
        timeout /t 2 >nul
        cls
        exit
    )
    del /f /q "%handleZip%" >nul 2>&1
    color 0A
    title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] handle.exe downloaded and extracted.
    echo [INFO] handle.exe downloaded and extracted.
    cls
)

rem --- Wait until MonsterHunterWilds.exe is no longer running ---
color 0A
:CHECK_MHW
tasklist | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 (
    color 06
    echo [INFO] MonsterHunterWilds.exe is running. Waiting for process to close...
    title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] MonsterHunterWilds.exe is running. Waiting for process to close...
    timeout /t 5 >nul
    cls
    goto CHECK_MHW
) else (
    color 0A
    title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] MonsterHunterWilds.exe is not running. Preparing termination and deletion.
    echo [INFO] MonsterHunterWilds.exe is not running. Preparing termination and deletion procedures.
    cls
)

rem --- Double-check that the game has not restarted ---
:WAIT_FOR_TERMINATION
tasklist | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 (
    echo [INFO] MonsterHunterWilds.exe restarted. Postponing termination and deletion procedures...
    timeout /t 5 >nul
    goto WAIT_FOR_TERMINATION
)

rem --- Define list of files to be terminated and deleted ---
set "filesList=Start.bat SFB.bat Monitor.bat MonitorLauncher.bat MHWSaveFileBackupTool.bat SFBE.bat hash_Monitor.txt hash_SFB.txt hash_Monitor.bat.txt hash_SFB.bat.txt SFB Monitor hashtemp.tmp handle.exe handle64.exe handle64a.exe handle.zip"

rem --- Enable delayed variable expansion for inner loops ---
setlocal EnableDelayedExpansion

echo.
echo [INFO] Attempting to terminate processes associated with files in list...
for %%F in (%filesList%) do (
    set "currentFile=%%F"
    rem Use PowerShell to retrieve process IDs of any process whose CommandLine contains the file name.
    for /f "delims=" %%A in ('powershell -noprofile -command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match '!currentFile!' } | ForEach-Object { $_.ProcessId }"') do (
         echo [INFO] Terminating process with PID %%A for !currentFile!...
         taskkill /PID %%A /F >nul 2>&1
    )
    rem If the file is an executable, also attempt termination by image name.
    echo !currentFile! | findstr /i "\.exe$" >nul
    if !errorlevel! equ 0 (
         echo [INFO] Attempting to terminate process image !currentFile!...
         taskkill /f /im "!currentFile!" >nul 2>&1
    )
    timeout /t 1 >nul
)

echo.
echo [INFO] Proceeding to delete files from %tempDir%...
for %%F in (%filesList%) do (
    if exist "%tempDir%\%%F" (
       echo [INFO] Deleting file %%F...
       del /f /q "%tempDir%\%%F" >nul 2>&1
       if exist "%tempDir%\%%F" (
           echo [ERROR] Unable to delete %%F.
       ) else (
           echo [INFO] %%F deleted successfully.
       )
    ) else (
       echo [INFO] %%F not found in %tempDir%. Skipping...
    )
    timeout /t 1 >nul
)
endlocal

rem --- Empty the Recycle Bin and exit ---
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Emptying Recycle Bin...
echo [INFO] Emptying Recycle Bin...
powershell -noprofile -command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo.
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Cleanup completed. Exiting...
echo [INFO] Cleanup completed. Exiting...
timeout /t 2 >nul
exit
