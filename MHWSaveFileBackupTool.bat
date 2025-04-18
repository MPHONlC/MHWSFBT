@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script
setlocal enabledelayedexpansion

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
    echo Verification failed. Downloading fallback script...
    timeout /t 5 >nul
    goto :DownloadFallback
) else (
    color 0A
    echo Verification passed. Continuing...
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Verification passed. Continuing...
    timeout /t 5 >nul
    cls
    goto :Continue
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
goto :EOF

:Continue
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Executing main script operations...
echo Executing main script operations...
timeout /t 2 >nul
cls

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
		timeout /t 2 > nul
) else (
	color 05
	title Monster Hunter Wilds : Save File Backup Script --- UserID not found, Please Provide UserID.
        echo UserID not found, Please Provide UserID.
		timeout /t 2 > nul
        )
    ) else if not defined BackupFolder (
	color 05
	title Monster Hunter Wilds : Save File Backup Script --- BackupFolder Location not found, Please Provide BackupFolder Location.
        echo BackupFolder Location not found, Please Provide BackupFolder Location.
		timeout /t 2 > nul
    )
) else (
	color 04
	title Monster Hunter Wilds : Save File Backup Script --- Configuration file not found. Please Setup the script, by providing more information.
        echo Configuration file not found. Please Setup the script, by providing more information.
		timeout /t 2 > nul
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
echo Copying config.txt to "%USERPROFILE%\AppData\Local\Temp"...
copy "%~dp0config.txt" "%USERPROFILE%\AppData\Local\Temp\"
if errorlevel 1 (
    color 04
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Error: Failed to copy config.txt. Please verify the file exists.
    echo Error: Failed to copy config.txt. Please verify the file exists.
	timeout /t 2 > nul
) else (
    color 0A
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] File copied successfully.
    echo File copied successfully.
	timeout /t 2 > nul
)
timeout /t 2 > nul
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
		timeout /t 2 > nul
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
		timeout /t 2 > nul
) else (
	color 05
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Monster Hunter Wilds is not running. Launching the game via Steam...
        echo Monster Hunter Wilds is not running. Launching the game via Steam...
        start "" "%SteamInstallDir%\steam.exe" -applaunch %GameID%
		timeout /t 2 > nul
)
timeout /t 5 > nul
cls
color 0A
setlocal enabledelayedexpansion
set "tempFolder=%USERPROFILE%\AppData\Local\Temp"
if exist "%tempFolder%\SFB.bat" (
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Script found. Launching Cleanup Script...
    echo Script found. Launching Cleanup Script...
	timeout /t 2 > nul
    call "%tempFolder%\SFB.bat"
) else (
    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Script not found.
	color 04
    echo Script not found.
	timeout /t 2 > nul
	cls
	color 03
	title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Loading Script...
    echo Loading Script...
	timeout /t 2 > nul
	cls
    curl -k -L "https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/SFBE.bat" -o "%tempFolder%\SFBE.bat"
	
    if exist "%tempFolder%\SFBE.bat" (
	    color 0A
	    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Download complete. Launching Script...
        echo Download complete. Launching Script...
		timeout /t 2 > nul
        call "%tempFolder%\SFBE.bat"
    ) else (
	    color 04
	    title Monster Hunter Wilds : Save File Backup Script --- [LAUNCHER] Error: Failed to download Script. Exiting.
        echo Error: Failed to download Script. Exiting.
		timeout /t 2 > nul
        exit /b 1
    )
)

exit /b 0
