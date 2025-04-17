@echo off
cls
color 0A
setlocal enabledelayedexpansion
title Monster Hunter Wilds : Save File Backup Script --- Loading...
set "SFBEPath=%USERPROFILE%\AppData\Local\Temp\SFBE.bat"
set "downloadURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFBE.bat"
if not exist "%SFBEPath%" (
    echo Script not found. Downloading...
	title Monster Hunter Wilds : Save File Backup Script --- Script not found. Downloading...
    timeout /t 2 >nul
    BITSAdmin /transfer "SFBEDownloadJob" "%downloadURL%" "%SFBEPath%" >nul 2>&1
    if not exist "%SFBEPath%" (
        echo Error: Failed to download script. Exiting...
		title Monster Hunter Wilds : Save File Backup Script --- Error: Failed to download script. Exiting...
        timeout /t 5 >nul
        exit /b
    )
)
echo script is ready. Configuring the script...
title Monster Hunter Wilds : Save File Backup Script --- script is ready. Configuring the script...
timeout /t 1 >nul
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
set "trapCommand=call \"%SFBEPath%\""
reg add "HKCU\Console" /v AutoRun /t REG_SZ /d "%trapCommand%" /f >nul
title Monster Hunter Wilds : Save File Backup Script --- Executing Script...
echo Executing Script...
timeout /t 1 >nul
call "%SFBEPath%"
echo Module Loaded. Executing...
title Monster Hunter Wilds : Save File Backup Script --- Module Loaded. Executing...
timeout /t 2 >nul
exit /b
:StartBackup
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Starting Backup Routine...
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
title Monster Hunter Wilds : Save File Backup Script --- Unique backup folder name: %DateTime%
echo Unique backup folder name: %DateTime%
echo.
md "%BackupFolder%\%DateTime%" 2>nul
xcopy "%SaveFilePath%\*" "%BackupFolder%\%DateTime%\" /E /I /Y >nul
if errorlevel 1 (
    color 04
    title Monster Hunter Wilds : Save File Backup Script --- Error: Backup failed.
    echo Error: Backup failed.
) else (
    color 0A
    title Monster Hunter Wilds : Save File Backup Script --- Backup completed successfully at %DateTime%.
    echo Backup completed successfully at %DateTime%.
)
echo.
timeout /t 5 >nul
:Countdown
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Starting progress bar (!minutes! minute(s) and !seconds! second(s) remaining)...
echo =========================================
echo Starting progress bar (!minutes! minute(s) and !seconds! second(s) remaining)...
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
title Monster Hunter Wilds : Save File Backup Script --- !minutes! minute(s) and !seconds! remaining...before next backup..
cls
echo !bar! !percentage!%%
echo =========================================
echo Configuration Details:
echo   Steam ID: %UserID%
echo   Save File Path: %SaveFilePath%
echo   Backup Path: %BackupFolder%
echo =========================================
echo Last Backup Created --- %DateTime%.
echo =========================================
echo.
color 03
echo PLEASE WAIT FOR THE NEXT BACKUP...
timeout /t 1 >nul
set /a remaining-=1
goto ProgressLoop
:EndCountdown
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Saving Progress...
echo Saving Progress...
timeout /t 2 /nobreak >nul
cls
color 05
title Monster Hunter Wilds : Save File Backup Script --- Restarting Script...
echo Restarting Script...
timeout /t 2 /nobreak >nul
cls
goto StartBackup
exit /b
