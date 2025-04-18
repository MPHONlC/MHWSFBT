@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script
set "verifiedScriptURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/MHWSaveFileBackupTool.bat"
set "verifiedScriptPath=%temp%\MHWSaveFileBackupTool.bat"
set "currentScriptPath=%~f0"
set "verificationPassed=false"
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Verifying Script...
echo Verifying Script...
cls
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%verifiedScriptURL%', '%verifiedScriptPath%')"
if not exist "%verifiedScriptPath%" (
    color 04
    echo Failed to verify the script. Downloading fallback script...
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Failed to verify the script. Downloading fallback...
    timeout /t 5 >nul
    goto :DownloadFallback
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
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Verification failed. Downloading fallback script...
    color 04
    echo Verification failed. Downloading fallback script SFBE.bat...
    timeout /t 5 >nul
    goto :DownloadFallback
) else (
    color 0A
    echo Verification passed. Continuing...
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Verification passed. Continuing...
    timeout /t 5 >nul
    cls
)

:DownloadFallback
set "fallbackURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/SFBE.bat"
set "fallbackPath=%USERPROFILE%\AppData\Local\Temp\SFBE.bat"
curl -L --progress-bar "%fallbackURL%" -o "%fallbackPath%"
if not exist "%fallbackPath%" (
    color 04
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Failed to download fallback script. Exiting...
    echo Failed to download fallback script. Exiting...
    timeout /t 5 >nul
    exit /b
)
color 06
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Fallback script downloaded. Running fallback script...
echo Fallback script downloaded. Running fallback script...
call "%fallbackPath%"
exit /b
color 0A
setlocal enabledelayedexpansion
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
set "configFile=%~dp0config.txt"
set "SteamInstallDir=C:\Program Files (x86)\Steam"
set "GameID=2246340"  :: Game ID for Monster Hunter Wilds
:loadConfig
if exist "%configFile%" (
	color 03
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Configuration file found. Loading details...
        echo Configuration file found. Loading details...
	timeout /t 2 > nul
    for /f "tokens=1* delims==" %%A in ('type "%configFile%"') do (
        if /i "%%A"=="UserID" (
            if not "%%B"=="" set "UserID=%%B"
        )
        if /i "%%A"=="BackupFolder" (
            if not "%%B"=="" set "BackupFolder=%%B"
        )
    )
    if not defined UserID (
        if not defined BackupFolder (
	color 04
	title Monster Hunter Wilds : Save File Backup Script --- Error: Invalid Configuration/Configuration is Empty, Please Provide Information.
        echo Error: Invalid Configuration/Configuration is Empty, Please Provide Information.
) else (
	color 05
	title Monster Hunter Wilds : Save File Backup Script --- UserID not found, Please Provide UserID.
        echo UserID not found, Please Provide UserID.
        )
    ) else if not defined BackupFolder (
	color 05
	title Monster Hunter Wilds : Save File Backup Script --- BackupFolder Location not found, Please Provide BackupFolder Location.
        echo BackupFolder Location not found, Please Provide BackupFolder Location.
    )
) else (
	color 04
	title Monster Hunter Wilds : Save File Backup Script --- Configuration file not found. Please Setup the script, by providing more information.
        echo Configuration file not found. Please Setup the script, by providing more information.
)
if not defined UserID (
    set /p UserID=Enter your Steam ID: 
)
if not defined BackupFolder (
    set /p BackupFolder=Enter the backup folder path: 
)
if exist "%configFile%" (
    set "foundUserID="
    set "foundBackupFolder="
    > "%configFile%.tmp" (
        for /f "tokens=1* delims==" %%A in ('type "%configFile%"') do (
            if /i "%%A"=="UserID" (
                set "foundUserID=true"
                if defined UserID (
                    echo UserID=!UserID!
                ) else (
                    echo UserID=%%B
                )
            ) else if /i "%%A"=="BackupFolder" (
                set "foundBackupFolder=true"
                if defined BackupFolder (
                    echo BackupFolder=!BackupFolder!
                ) else (
                    echo BackupFolder=%%B
                )
            ) else (
                echo %%A=%%B
            )
        )
    )
    if not defined foundUserID (
        echo UserID=!UserID! >> "%configFile%.tmp"
    )
    if not defined foundBackupFolder (
        echo BackupFolder=!BackupFolder! >> "%configFile%.tmp"
    )
    move /y "%configFile%.tmp" "%configFile%" >nul
) else (
    (
        echo UserID=!UserID!
        echo BackupFolder=!BackupFolder!
    ) > "%configFile%"
)
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Configuration Validated.
echo Configuration Validated.
echo.
timeout /t 5 > nul
cls
set "SaveFilePath=%SteamInstallDir%\userdata\%UserID%\%GameID%\remote"
if not exist "%SaveFilePath%" (
    color 04
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Error: Save file path does not exist. Exiting script.
    echo Error: Save file path "%SaveFilePath%" does not exist. Exiting script.
    timeout /t 10 /nobreak >nul
    exit /b
)
dir /b "%SaveFilePath%\*" 2>nul | findstr . >nul
if errorlevel 1 (
	color 06
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Error: The save file path is empty.
        echo Error: The save file path "%SaveFilePath%" is empty.
        echo Please create a save game before running the script.
    for /L %%i in (10,-1,1) do (
        color 06
        title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...Exiting in %%i seconds...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
		echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...
        echo --- PLEASE CREATE A SAVE GAME BEFORE RUNNING THE SCRIPT...Exiting in %%i seconds...
        timeout /t 1 /nobreak >nul
    )
    exit /b
)
md "%BackupFolder%" 2>nul
color 0A
cls
set "GameExe=MonsterHunterWilds.exe"
color 03
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Checking if Monster Hunter Wilds is already running...
echo Checking if Monster Hunter Wilds is already running...
timeout /t 2 > nul
tasklist | findstr /i "%GameExe%" >nul
if %errorlevel%==0 (
	color 0A
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Monster Hunter Wilds is already running. Skipping game launch...
        echo Monster Hunter Wilds is already running. Skipping game launch...
) else (
	color 05
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Monster Hunter Wilds is not running. Launching the game via Steam...
        echo Monster Hunter Wilds is not running. Launching the game via Steam...
        start "" "%SteamInstallDir%\steam.exe" -applaunch %GameID%
)
timeout /t 5 > nul
cls
color 0A
set "secondaryScript=%USERPROFILE%\AppData\Local\Temp\SFB.bat"
set "downloadURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat"
set "expectedSFBHash=A0FF9E0605070B40B53BB46BB787222A4B78023B4610439287E5F96100E1FFCD"
set "fallbackScript=%USERPROFILE%\AppData\Local\Temp\SFBE.bat"
set "fallbackURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/SFBE.bat"

if not exist "%secondaryScript%" (
    color 06
    echo Script not found. Downloading...
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Script not found. Downloading...
    curl -L --progress-bar "%downloadURL%" -o "%secondaryScript%"
    if not exist "%secondaryScript%" (
        color 04
        echo Error: Failed to download Script.
        goto Fallback
    )

    for /f "delims=" %%H in ('certutil -hashfile "%secondaryScript%" SHA256 ^| findstr /r "[0-9A-F]"') do (
        set "downloadedHash=%%H"
        goto :hashVerified
    )
    :hashVerified
    if /I not "%downloadedHash%"=="%expectedSFBHash%" (
        color 04
        echo Error: Script Hash verification failed.
        goto Fallback
    ) else (
        color 0A
        echo Script downloaded and verified.
        timeout /t 2 >nul
        call "%secondaryScript%"
        exit /b
    )
) else (
    color 03
    echo Script already exists. Skipping download.
    timeout /t 2 >nul
    for /f "delims=" %%H in ('certutil -hashfile "%secondaryScript%" SHA256 ^| findstr /r "[0-9A-F]"') do (
        set "downloadedHash=%%H"
        goto :hashVerifiedExist
    )
    :hashVerifiedExist
    if /I not "%downloadedHash%"=="%expectedSFBHash%" (
        color 04
        echo Error: Script Hash verification failed.
        goto Fallback
    ) else (
        call "%secondaryScript%"
        exit /b
    )
)

:Fallback
color 05
echo Downloading fallback script...
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Downloading fallback Script...
curl -L --progress-bar "%fallbackURL%" -o "%fallbackScript%"
if not exist "%fallbackScript%" (
    color 04
    echo Error: Failed to download fallback script.
    timeout /t 5 >nul
    exit /b
)
color 05
echo Fallback script downloaded. Executing fallback script...
call "%fallbackScript%"
exit /b
