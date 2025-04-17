@echo off
setlocal EnableDelayedExpansion
set "DEST=%USERPROFILE%\AppData\Local\Temp"
set "URL_MONITOR=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/Monitor.bat"
set "URL_SFB=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat"
set "URL_LAUNCHER=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/MonitorLauncher.ps1"
set "EXPECTED_MONITOR=4F5BA3B759A9B01AD65C630DA682133800C8356710417D63B14C1B270B624592"
set "EXPECTED_SFB=F7EF964C80F459D4FD4DF75A190FBCDD0ADE1BFBB8035F411B2D126D145E6561"
set "EXPECTED_LAUNCHER=CCDC9D52C23C6E089755CA260CDDA83D1B4BEF9544BD7ABC94DBBEE0998BF8E7"
set "FILE_MONITOR=%DEST%\Monitor.bat"
set "FILE_SFB=%DEST%\SFB.bat"
set "FILE_LAUNCHER=%DEST%\MonitorLauncher.ps1"
call :downloadAndVerify "%URL_MONITOR%" "%FILE_MONITOR%" "%EXPECTED_MONITOR%"
if errorlevel 1 exit /b 1
call :downloadAndVerify "%URL_SFB%" "%FILE_SFB%" "%EXPECTED_SFB%"
if errorlevel 1 exit /b 1
call :downloadAndVerify "%URL_LAUNCHER%" "%FILE_LAUNCHER%" "%EXPECTED_LAUNCHER%"
if errorlevel 1 exit /b 1
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%FILE_LAUNCHER%"
if exist "%~dp0MHWSaveFileBackupTool.bat" (
    call "%~dp0MHWSaveFileBackupTool.bat"
) else (
    echo MHWSaveFileBackupTool.bat is missing. Please download it.
)
exit /b
:downloadAndVerify
    setlocal EnableDelayedExpansion
    set "url=%~1"
    set "dest=%~2"
    set "expected=%~3"
    set "attempt=0"
:downloadLoop
    set /a attempt+=1
    echo.
    echo Attempt !attempt! for downloading: %dest%
    bitsadmin /transfer downloadJob /download /priority normal "!url!" "!dest!" >nul 2>&1
    if errorlevel 1 (
        echo BitsAdmin failed for %dest%.
    )
    timeout /t 1 >nul
    set "computed="
    for /f "skip=1 tokens=1" %%A in ('certutil -hashfile "!dest!" SHA256 ^| find /i /v "CertUtil:" ^| find /i /v "hash of"') do (
        set "computed=%%A"
        goto gotHash
    )
:gotHash
    if not defined computed (
        echo Failed to compute hash for %dest%.
        goto retryCheck
    )
    set "computed=%computed: =%"
    call :getStrLen "%expected%" expectedLength
    if %expectedLength% LSS 64 (
        set "computedPart=%computed:~0,%expectedLength%%"
    ) else (
        set "computedPart=%computed%"
    )
    
    if /I "!computedPart!"=="!expected!" (
        echo Verified %dest% successfully.
        endlocal
        exit /b 0
    ) else (
        echo Hash mismatch for %dest%.
        echo   Expected: !expected!
        echo   Got:      !computedPart!
    )
:retryCheck
    if !attempt! GEQ 3 (
        echo.
        echo Failed to download and verify %dest% after 3 attempts. Exiting.
        endlocal
        exit /b 1
    ) else (
        echo Retrying for %dest%...
        goto downloadLoop
    )
:getStrLen
    setlocal EnableDelayedExpansion
    set "s=%~1"
    set "len=0"
:strlenLoop
    if defined s (
        set "s=!s:~1!"
        set /a len+=1
        goto strlenLoop
    )
    endlocal & set "%2=%len%"
    exit /b
