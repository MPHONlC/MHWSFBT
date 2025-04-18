@echo off
title Monster Hunter Wilds : Save File Backup Script --- [PATCH] 
setlocal DisableDelayedExpansion
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
set "GameID=2246340"
set "expectedSteamInstallDir=C:\Program Files (x86)\Steam"
set "configFile=%~dp0config.txt"
set "UserID="
set "actualSteamInstallDir="
if exist "%configFile%" (
    for /f "usebackq tokens=1* delims==" %%A in ("%configFile%") do (
       if /i "%%A"=="UserID" set "UserID=%%B"
       if /i "%%A"=="actualSteamInstallDir" set "actualSteamInstallDir=%%B"
    )
)
if "%UserID%"=="" set /p UserID=Enter UserID: 
if "%actualSteamInstallDir%"=="" set /p actualSteamInstallDir=Enter actual Steam Install Directory: 
endlocal & (
    set "UserID=%UserID%"
    set "actualSteamInstallDir=%actualSteamInstallDir%"
    set "expectedSteamInstallDir=%expectedSteamInstallDir%"
    set "GameID=%GameID%"
    set "configFile=%configFile%"
)
setlocal EnableDelayedExpansion
set "SaveFilePath=!expectedSteamInstallDir!\userdata\!UserID!\!GameID!"
title Monster Hunter Wilds : Save File Backup Script --- [PATCH] Generated SaveFilePath: !SaveFilePath!
echo =========================================
echo Generated SaveFilePath: !SaveFilePath!
echo =========================================
timeout /t 1 >nul
echo.
if exist "!configFile!" (
    set "foundUserID=0"
    set "foundActual=0"
    > "!configFile!.tmp" (
        for /f "usebackq delims=" %%L in ("!configFile!") do (
            set "line=%%L"
            set "skip=0"
            if /i "!line:~0,7!"=="UserID=" (
                set "foundUserID=1"
                if "!line:~7!"=="" (
                    echo UserID=!UserID!
                ) else (
                    echo !line!
                )
                set "skip=1"
            )
            if /i "!line:~0,22!"=="actualSteamInstallDir=" (
                set "foundActual=1"
                if "!line:~22!"=="" (
                    echo actualSteamInstallDir=!actualSteamInstallDir!
                ) else (
                    echo !line!
                )
                set "skip=1"
            )
            if "!skip!"=="0" (
                echo !line!
            )
        )
    )
    if !foundUserID! EQU 0 (
         >> "!configFile!.tmp" echo UserID=!UserID!
    )
    if !foundActual! EQU 0 (
         >> "!configFile!.tmp" echo actualSteamInstallDir=!actualSteamInstallDir!
    )
    move /Y "!configFile!.tmp" "!configFile!" >nul
) else (
    (
      echo UserID=!UserID!
      echo actualSteamInstallDir=!actualSteamInstallDir!
    ) > "!configFile!"
)
if not exist "!SaveFilePath!" (
    title Monster Hunter Wilds : Save File Backup Script --- [PATCH] Attempting to create symbolic link for folder "!GameID!"...
    echo Attempting to create symbolic link for folder "!GameID!"...
	echo.
	echo =========================================
    mklink /D "!SaveFilePath!" "!actualSteamInstallDir!"
	timeout /t 1 >nul
    if errorlevel 1 (
	     title Monster Hunter Wilds : Save File Backup Script --- [PATCH] Failed to create symbolic link.
		 color 04
         echo Failed to create symbolic link.
		 timeout /t 2 >nul
    ) else (
         if exist "!SaveFilePath!" (
		    title Monster Hunter Wilds : Save File Backup Script --- [PATCH] Symbolic link created successfully.
			color 0A
			echo.
			echo =========================================
            echo Symbolic link created successfully.
			echo =========================================
			echo.
			timeout /t 2 >nul
         ) else (
		    title Monster Hunter Wilds : Save File Backup Script --- [PATCH] Symlink verification failed.
			color 04
			echo.
			echo =========================================
            echo Symlink verification failed.
			echo =========================================
			echo.
			timeout /t 2 >nul
         )
    )
) else (
    color 06
    title Monster Hunter Wilds : Save File Backup Script --- [PATCH] 
    echo Folder "!SaveFilePath!" already exists.
	timeout /t 1 >nul
)
echo.
title Monster Hunter Wilds : Save File Backup Script --- [PATCH] All tasks completed.
color 0A
echo ===========================                         ===========================
echo                              All tasks completed.
echo ===========================                         ===========================
pause
exit /b
