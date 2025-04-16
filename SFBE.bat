@echo off
cls
color 0A
title File Deletion Script - Downloading and Running Handle.exe
set "handleURL=https://download.sysinternals.com/files/Handle.zip"
set "tempDir=%USERPROFILE%\AppData\Local\Temp"
set "handleZip=%tempDir%\Handle.zip"
set "handlePath=%tempDir%\handle.exe"
set "file1=%USERPROFILE%\AppData\Local\Temp\SFB.bat"
set "file2=%USERPROFILE%\AppData\Local\Temp\MHWSaveFileBackupTool.bat"
echo Downloading Handle.exe from Sysinternals...
timeout /t 2 >nul
BITSAdmin /transfer "HandleDownloadJob" "%handleURL%" "%handleZip%" >nul 2>&1
if not exist "%handleZip%" (
    echo Error: Failed to download Handle.zip. Exiting...
    timeout /t 5 >nul
    exit /b
)
echo Extracting Handle.exe...
powershell -Command "Expand-Archive -Path '%handleZip%' -DestinationPath '%tempDir%' -Force" >nul 2>&1
if not exist "%handlePath%" (
    echo Error: Failed to extract Handle.exe. Exiting...
    timeout /t 5 >nul
    exit /b
)
del /f /q "%handleZip%" >nul 2>&1
echo Handle.exe is ready. Checking file usage...
setlocal enabledelayedexpansion
for %%F in ("%file1%" "%file2%") do (
    echo Checking if %%F is in use...
    "%handlePath%" %%F | find "No matching handles" >nul
    if %errorlevel%==0 (
        echo File %%F is not in use. Deleting...
        del /f /q "%%F" >nul 2>&1
        echo File %%F deleted.
    ) else (
        echo File %%F is in use. Skipping deletion.
    )
)
endlocal
echo Cleanup completed. Exiting...
timeout /t 2 >nul
del /f /q "%handlePath%" >nul 2>&1
exit /b
