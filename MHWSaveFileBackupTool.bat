@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script
set "verifiedScriptURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/MHWSaveFileBackupTool.bat"
set "verifiedScriptPath=%temp%\MHWSaveFileBackupTool.bat"
set "currentScriptPath=%~f0"
set "verificationPassed=false"
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Verifying  Script...
echo Verifying  Script...
cls
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%verifiedScriptURL%', '%verifiedScriptPath%')"
if not exist "%verifiedScriptPath%" (
    color 04
    echo Failed to verify the script. Exiting...
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Failed to verify the script. Exiting...
    timeout /t 5 >nul
    exit /b
)
for /f "delims=" %%H in ('certutil -hashfile "%currentScriptPath%" SHA256 ^| find /i /v "hash" ^| findstr /r "[0-9A-F]"') do (
    set "currentHash=%%H"
)
for /f "delims=" %%H in ('certutil -hashfile "%verifiedScriptPath%" SHA256 ^| find /i /v "hash" ^| findstr /r "[0-9A-F]"') do (
    set "verifiedHash=%%H"
)
if "%currentHash%" == "%verifiedHash%" (
    set "verificationPassed=true"
)
if not "%verificationPassed%"=="true" (
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] The script has been modified or out of date. Exiting...
    color 04
    echo Verification failed. The script has been modified or out of date. Exiting...
    timeout /t 5 >nul
    exit /b
) else (
    color 0A
    echo Verification passed. Continuing...
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Verification passed. Continuing...
    timeout /t 5 >nul
    cls
)
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
	color 06
	title Monster Hunter Wilds : Save File Backup Script --- UserID not found, Please Provide UserID.
        echo UserID not found, Please Provide UserID.
        )
    ) else if not defined BackupFolder (
	color 06
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
        color 03
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
set "secondaryScript=%USERPROFILE%\AppData\Local\Temp\SFB.bat"
set "tempScript=%USERPROFILE%\AppData\Local\Temp\SFB.bat"
set "downloadURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat"
if not exist "%tempScript%" (
        color 06
        echo Script not found. Downloading...
        title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Script not found. Downloading...
    BITSAdmin /transfer "SFBDownloadJob" "%downloadURL%" "%tempScript%" >nul 2>&1
    if not exist "%tempScript%" (
        color 04
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Error: Failed to download script. Exiting...
        echo Error: Failed to download script. Exiting...
        timeout /t 5 >nul
        exit /b
    )
    attrib +R "%tempScript%"
        color 06
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] script downloaded and marked as read-only.
        echo script downloaded and marked as read-only.
	timeout /t 2 >nul
) else (
        color 06
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] script already exists. Skipping download.
        echo script already exists. Skipping download.
	timeout /t 2 >nul
)
call "%secondaryScript%"
exit /b
