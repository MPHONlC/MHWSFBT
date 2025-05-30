@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Verifying Script...
echo Verifying Script...
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
set "verifiedScriptURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/SFB.bat"
set "verifiedScriptPath=%temp%\SFB.bat"
set "currentScriptPath=%~f0"
set "verificationPassed=false"
cls
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%verifiedScriptURL%', '%verifiedScriptPath%')"
if not exist "%verifiedScriptPath%" (
    color 04
    echo Failed to verify the script. Exiting...
    title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Failed to verify the script. Exiting...
    timeout /t 5 >nul
    exit /b
)
for /f "delims=" %%H in ('certutil -hashfile "%currentScriptPath%" SHA256 ^| find /i /v "hash" ^| findstr /r "[0-9A-F]"') do (
    set "currentHash=%%H"
)
for /f "delims=" %%H in ('certutil -hashfile "%verifiedScriptPath%" SHA256 ^| find /i /v "hash" ^| findstr /r "[0-9A-F]"') do (
    set "verifiedHash=%%H"
)
if "%currentHash%"=="%verifiedHash%" (
    set "verificationPassed=true"
)
if not "%verificationPassed%"=="true" (
    title Monster Hunter Wilds : Save File Backup Script --- [MAIN] The script has been modified or is out of date. Exiting...
    color 04
    echo ===========================                         ===========================
    echo Verification failed. The script has been modified or is out of date. Exiting...
    echo ===========================                         ===========================
    timeout /t 5 >nul
    exit /b
) else (
    echo ===========================                         ===========================
    echo Verification passed. Continuing...
    echo ===========================                         ===========================
    color 0A
    title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Verification passed. Continuing...
    timeout /t 5 >nul
    cls
)

color 0A
setlocal enabledelayedexpansion
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Loading...
set "SFBEPath=%USERPROFILE%\AppData\Local\Temp\SFBE.bat"
set "downloadURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFBE.bat"
if not exist "%SFBEPath%" (
    color 06
    echo ===========================                         ===========================
    echo Script not found. Downloading...
    echo ===========================                         ===========================
    title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Script not found. Downloading...
    timeout /t 2 >nul
    BITSAdmin /transfer "SFBEDownloadJob" "%downloadURL%" "%SFBEPath%" >nul 2>&1
    if not exist "%SFBEPath%" (
        color 04
        echo ===========================                         ===========================
        echo Error: Failed to download script. Exiting...
        echo ===========================                         ===========================
        title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Error: Failed to download script. Exiting...
        timeout /t 5 >nul
        exit /b
    )
)
color 06
echo ===========================                         ===========================
echo Script is ready. Configuring the script...
echo ===========================                         ===========================
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Script is ready. Configuring the script...
timeout /t 1 >nul
set "configFile=%USERPROFILE%\AppData\Local\Temp\config.txt"
if not exist "%configFile%" (
    color 04
	title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Configuration file not found at %configFile%. Exiting...
    echo Configuration file not found at %configFile%. Exiting...
    timeout /t 5 >nul
    exit /b
)
for /f "tokens=1* delims==" %%I in (%configFile%) do (
    if /i "%%I"=="BackupFolder" set "BackupFolder=%%J"
    if /i "%%I"=="userID" set "UserID=%%J"
)
set "SteamInstallDir=C:\Program Files (x86)\Steam"
set "GameID=2246340"
set "SaveFilePath=%SteamInstallDir%\userdata\%UserID%\%GameID%"
:StartBackup
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Starting Backup Routine...
echo =========================================
echo Starting Backup Routine...
echo =========================================
timeout /t 3 >nul
for /f "tokens=2 delims= " %%A in ('date /t') do set "CurrentDate=%%A"
for /f "tokens=1-4 delims=:. " %%A in ("%time%") do (
    set "hour=%%A"
    set "minutes=%%B"
    set "seconds=%%C"
    if %%A geq 12 (
        set "ampm=PM"
        if %%A gtr 12 set /a hour=%%A-12
    ) else (
        set "ampm=AM"
        if %%A==00 set "hour=12"
    )
)
set "CurrentDate=%CurrentDate:/=-%"
set "DateTime=%CurrentDate%_%hour%-%minutes%-%seconds%_%ampm%"
color 03
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Unique backup folder name: %DateTime%
echo ===========================                         ===========================
echo Unique backup folder name: %DateTime%
echo ===========================                         ===========================
echo.
md "%BackupFolder%\%DateTime%" 2>nul
xcopy "%SaveFilePath%\*" "%BackupFolder%\%DateTime%\" /E /I /Y >nul
if errorlevel 1 (
    color 04
    title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Error: Backup failed.
    echo ===========================                         ===========================
    echo Error: Backup failed.
    echo ===========================                         ===========================
) else (
    color 0A
    title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Backup completed successfully at %DateTime%.
    echo ===========================                         ===========================
    echo Backup completed successfully at %DateTime%.
    echo ===========================                         ===========================
)
echo.
timeout /t 5 >nul

:Countdown
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Starting progress bar...
echo =========================================
echo Starting progress bar...
echo =========================================
set /a total=300
set /a remaining=300
set "bar="

:ProgressLoop
if %remaining% leq 0 goto EndCountdown
set /a percentage=(remaining * 100) / total
set /a minutes=%remaining% / 60
set /a seconds=%remaining% %% 60
set "bar=["
for /l %%A in (1,1,%percentage%) do set "bar=!bar!#"
for /l %%B in (%percentage%,1,100) do set "bar=!bar!."
set "bar=!bar!]"
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] !minutes! minute(s) and !seconds! remaining...
cls
echo !bar! !percentage!%%
echo =========================================
echo Configuration Details:
echo   Steam UserID: %UserID%
echo   Save File Path: %SaveFilePath%
echo   Backup Path: %BackupFolder%
echo =========================================
echo Last Backup Created --- %DateTime%.
echo =========================================
echo.
color 03
echo ===========================                         ===========================
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo PLEASE WAIT FOR THE NEXT BACKUP...PLEASE WAIT FOR THE NEXT BACKUP...
echo ===========================                         ===========================
echo Donate if you like this utility https://buymeacoffee.com/aph0nlc
timeout /t 1 >nul
set /a remaining-=1
goto ProgressLoop

:EndCountdown
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Saving Progress...
echo =========================== Saving Progress...
timeout /t 2 /nobreak >nul
cls
color 05
title Monster Hunter Wilds : Save File Backup Script --- [MAIN] Restarting Script...
echo =========================== Restarting Script...
timeout /t 2 /nobreak >nul
cls
goto StartBackup
