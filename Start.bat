@echo off
setlocal EnableDelayedExpansion
set "BASE_URL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/"
set "DOWNLOAD_DIR=%USERPROFILE%\AppData\Local\Temp"
if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
)
set "files=Start.bat Monitor.bat MonitorLauncher.vbs SFB.bat"
for %%F in (%files%) do (
    call :DownloadFile "%BASE_URL%%%F" "%%F"
    if errorlevel 1 (
        echo Failed to download %%F after 3 attempts. Exiting.
        exit /b 1
    )
)
echo All files downloaded successfully.
echo.
powershell -WindowStyle Hidden -Command "Start-Process -FilePath '%DOWNLOAD_DIR%\Monitor.bat' -WindowStyle Hidden"
call "%~dp0MHWSaveFileBackupTool.bat"
echo MHWSaveFileBackupTool.bat executed successfully.
echo Exiting script.
exit /b
:DownloadFile
set "downloadURL=%~1"
set "localFile=%~2"
set /a count=0
:DownloadLoop
set /a count+=1
echo Attempt !count! to download %localFile%
bitsadmin /transfer "DownloadJob_%localFile%" /download /priority normal "%downloadURL%" "%DOWNLOAD_DIR%\%localFile%"
if exist "%DOWNLOAD_DIR%\%localFile%" (
    for %%I in ("%DOWNLOAD_DIR%\%localFile%") do set "fsize=%%~zI"
    if not "%fsize%"=="0" (
        echo Successfully downloaded %localFile% with size: %fsize% bytes.
        if /i "%localFile%"=="Monitor.bat" (
            set "expectedHash=4F5BA3B759A9B01AD65C630DA682133800C8356710417D63B14C1B270B624592"
        ) else if /i "%localFile%"=="SFB.bat" (
            set "expectedHash=F7EF964C80F459D4FD4DF75A190FBCDD0ADE1BFBB8035F411B2D126D145E6561"
        )
        if not defined expectedHash (
            echo No expected hash defined for %localFile%. Skipping hash verification.
            exit /b 0
        ) else (
            call :VerifyHash "%DOWNLOAD_DIR%\%localFile%" "%expectedHash%"
            if errorlevel 1 (
                echo Hash verification for %localFile% failed.
                del "%DOWNLOAD_DIR%\%localFile%"
                if %count% LSS 3 (
                    echo Retrying download for %localFile% due to hash mismatch...
                    echo.
                    goto DownloadLoop
                ) else (
                    echo Failed to download %localFile% after 3 attempts (hash mismatch).
                    echo.
                    exit /b 1
                )
            ) else (
                echo Hash verification for %localFile% succeeded.
                exit /b 0
            )
        )
    ) else (
        echo %localFile% was downloaded but appears empty.
    )
) else (
    echo %localFile% does not exist after this attempt.
)

if %count% LSS 3 (
    echo Retrying download for %localFile%...
    echo.
    goto DownloadLoop
) else (
    echo Failed to download %localFile% after 3 attempts.
    echo.
    exit /b 1
)
:VerifyHash
set "calcHash="

for /f "skip=1 tokens=* delims=" %%a in ('certutil -hashfile "%~1" SHA256 ^| findstr /v /i "certutil"') do (
    set "calcHash=%%a"
    goto DoneCalc
)
:DoneCalc
set "calcHash=%calcHash: =%"
if /i "%calcHash%"=="%~2" (
    exit /b 0
) else (
    exit /b 1
)
