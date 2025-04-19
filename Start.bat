@echo off
setlocal
color 0A
setlocal EnableDelayedExpansion
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v InstallPath 2^>nul') do (
    set "steamPath=%%B"
)

if not defined steamPath (
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Steam installation not found in the registry.
    color 06
    echo Steam installation not found in the registry.
    pause
    exit /b 1
)

if "%steamPath:~-1%"=="\" set "steamPath=%steamPath:~0,-1%"

color 0A
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Found Steam installed at: %steamPath%
echo Found Steam installed at: %steamPath%
timeout /t 1 >nul

tasklist /fi "imagename eq MonsterHunterWilds.exe" | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 (
    echo Game process is already running. Skipping launch logic.
	timeout /t 1 >nul
    goto Continue
)

echo Game process not detected. Launching game using working directory method...
start "" /d "%steamPath%" steam.exe -applaunch 2246340

timeout /t 5 >nul

tasklist /fi "imagename eq MonsterHunterWilds.exe" | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 goto Continue

echo First launch method appears to have failed.
echo Attempting fallback with Steam protocol URL...
start "" "steam://rungameid/2246340"
timeout /t 5 >nul

tasklist /fi "imagename eq MonsterHunterWilds.exe" | findstr /i "MonsterHunterWilds.exe" >nul
if %errorlevel%==0 goto Continue

echo Steam launch options might be interfering.
echo Attempting to locate the game executable directly...
timeout /t 1 >nul
set "gameExe="

for /f "delims=" %%G in ('dir /s /b "%steamPath%\steamapps\common\*MonsterHunterWilds.exe" 2^>nul') do (
    set "gameExe=%%G"
    goto FoundExe
)

if not defined gameExe if exist "%steamPath%\steamapps\libraryfolders.vdf" (
    for /f "usebackq delims=" %%L in ("%steamPath%\steamapps\libraryfolders.vdf") do (
        echo %%L | findstr /r "^\"[0-9][0-9]*\"" >nul
        if not errorlevel 1 (
            for /f "tokens=4 delims=\" %%I in ("%%L") do (
                set "libFolder=%%I"
                if exist "!libFolder!\steamapps\common" (
                    for /f "delims=" %%J in ('dir /s /b "!libFolder!\steamapps\common\*MonsterHunterWilds.exe" 2^>nul') do (
                        set "gameExe=%%J"
                        goto FoundExe
                    )
                )
            )
        )
    )
)

:FoundExe
if defined gameExe (
    echo Game executable found at: !gameExe!
    start "" "!gameExe!"
    timeout /t 5 >nul
) else (
    echo Direct game executable not found in any Steam library folder.
    echo Cannot bypass Steam launch options.
	echo Forcing game launch on the scripts current directory.
	timeout /t 5 >nul
)

:Continue
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Game launched successfully.
echo Game launched successfully.
echo Continuing with the rest of the script...
timeout /t 1 >nul
cls

endlocal
start "" "%~dp0MonsterHunterWilds.exe"
title MHWSaveFileBackupScript : WINDOW 24592
taskkill /F /FI "WINDOWTITLE ne MHWSaveFileBackupScript : WINDOW 24592" /IM cmd.exe >nul 2>&1
taskkill /F /IM powershell.exe >nul 2>&1
echo Loading...
cls
timeout /t 10 > nul
setlocal enabledelayedexpansion

for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do (
    reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
)

set "downloadDir=%USERPROFILE%\AppData\Local\Temp"
set "MonitorURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/Monitor.bat"
set "SFBURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat"
set "SFBEURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/SFBE.bat"
set "ExpectedMonitorHash=0EBB9F738B9F640628BFB489401D9FF7C6F21F93742697A5C079DA03F42074B9"
set "ExpectedSFBHash=E5009B3330E2419B5FBE89077CCA97358845884141E029231D919FAC09CEDF5C"

call :DownloadWithRetry "%MonitorURL%" "Monitor.bat"
if errorlevel 1 goto FallbackSFBE
call :DownloadWithRetry "%SFBURL%" "SFB.bat"
if errorlevel 1 goto FallbackSFBE
call :VerifyHash "%downloadDir%\Monitor.bat" "%ExpectedMonitorHash%"
if errorlevel 1 goto FallbackSFBE
call :VerifyHash "%downloadDir%\SFB.bat" "%ExpectedSFBHash%"
if errorlevel 1 goto FallbackSFBE

echo.
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [START] All files downloaded and verified successfully.
echo =========================== All files downloaded and verified successfully.
timeout /t 5 > nul
cls

title Monster Hunter Wilds : Save File Backup Script --- [START] Running Monitor script ...
color 03
echo Running Monitor script ...
timeout /t 5 > nul
cls
start /min "" "%downloadDir%\Monitor.bat"

set "BackupTool=%~dp0MHWSaveFileBackupTool.bat"
if exist "%BackupTool%" (
    title Monster Hunter Wilds : Save File Backup Script --- [START] Running MHWSaveFileBackupTool.bat...
    color 03
    echo Running MHWSaveFileBackupTool.bat...
    timeout /t 5 > nul
    cls
    call "%BackupTool%"
    title Monster Hunter Wilds : Save File Backup Script --- [START] MHWSaveFileBackupTool.bat executed successfully.
    color 0A
    echo MHWSaveFileBackupTool.bat executed successfully.
    timeout /t 5 > nul
    cls
    exit /b 0
) else (
    title Monster Hunter Wilds : Save File Backup Script --- [START] ERROR: MHWSaveFileBackupTool.bat is missing.
    color 04
    echo ERROR: MHWSaveFileBackupTool.bat is missing. Please download it.
    echo LINK: https://www.nexusmods.com/monsterhunterwilds/mods/1874
    timeout /t 10 > nul
)

goto :EOF

:FallbackSFBE
echo.
color 03
title Monster Hunter Wilds : Save File Backup Script --- [START] Running Cleanup script as fallback...
echo Running Cleanup script as fallback...
timeout /t 5 > nul
cls
curl --progress-bar -o "%downloadDir%\SFBE.bat" "%SFBEURL%"
color 05
title Monster Hunter Wilds : Save File Backup Script --- [START] Executing Cleanup script...
echo Executing Cleanup script...
timeout /t 5 > nul
cls
start /min "" "%downloadDir%\SFBE.bat"
exit /b 0

:DownloadWithRetry
setlocal enabledelayedexpansion
set "URL=%~1"
set "Filename=%~2"
set /a Attempts=1

:DownloadRetryLoop
echo.
title Monster Hunter Wilds : Save File Backup Script --- [START] Loading Scripts (Attempt !Attempts! of 3)...
color 03
echo Loading Scripts (Attempt !Attempts! of 3)...
timeout /t 5 > nul
cls
curl --progress-bar -o "%downloadDir%\!Filename!" "!URL!"
if errorlevel 1 (
    if !Attempts! lss 3 (
        set /a Attempts+=1
        color 06
        title Monster Hunter Wilds : Save File Backup Script --- [START] load failed. Retrying...
        echo ===========================
        echo load failed. Retrying...
        echo ===========================
        timeout /t 5 > nul
        goto DownloadRetryLoop
    ) else (
        color 04
        title Monster Hunter Wilds : Save File Backup Script --- [START] Failed to load Scripts after 3 attempts.
        echo ===========================
        echo Failed to load Scripts after 3 attempts.
        echo ===========================
        timeout /t 5 > nul
        endlocal
        exit /b 1
    )
)
endlocal
exit /b 0

:VerifyHash
setlocal enabledelayedexpansion
set "FilePath=%~1"
set "Expected=%~2"
echo.
title Monster Hunter Wilds : Save File Backup Script --- [START] Verifying script hash...
color 03
echo =========================== Verifying script hash... ===========================
timeout /t 5 > nul
for /f "tokens=*" %%A in ('certutil -hashfile "%FilePath%" SHA256 ^| findstr /i /r "^[0-9a-f]"') do (
    set "Actual=%%A"
    set "Actual=!Actual: =!"
    goto GotHash
)
:GotHash
echo ===========================                         ===========================
echo Expected Hash: %Expected%
echo Actual   Hash: !Actual!
echo ===========================                         ===========================
if /I "!Actual!" neq "%Expected%" (
    title Monster Hunter Wilds : Save File Backup Script --- [START] Script Hash verification failed.
    color 04
    echo Script Hash verification failed.
    timeout /t 5 > nul
    endlocal
    exit /b 1
)
title Monster Hunter Wilds : Save File Backup Script --- [START] Script Hash verified.
color 0A
echo =========================== Script Hash verified. ===========================
timeout /t 5 > nul
cls
endlocal
exit /b 0
