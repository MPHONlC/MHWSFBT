@echo off
cls
color 0A
title Monster Hunter Wilds : Save File Backup Script
set "secondaryScript=%~dp0MHWSaveFileBackupTool.bat"
set "tempScript=%USERPROFILE%\AppData\Local\Temp\MHWSaveFileBackupTool.bat"
if not exist "%tempScript%" (
    copy "%secondaryScript%" "%tempScript%" >nul
    attrib +R "%tempScript%"
)
set "backupScriptURL=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/SFB.bat"
set "backupScriptPath=%temp%\SFB.bat"
set "currentScriptPath=%~f0"
set "verificationPassed=false"
echo Running Backup routine...
powershell -Command "
    try {
        (New-Object System.Net.WebClient).DownloadFile('%backupScriptURL%', '%backupScriptPath%')
    } catch {
        Write-Output 'Error: Failed Execute.'
        exit 1
    }"
if not exist "%backupScriptPath%" (
    echo Error: Cannot Find the script. Exiting...
    timeout /t 5 >nul
    exit /b
)
call "%backupScriptPath%"
del /f /q "%backupScriptPath%" >nul 2>&1
echo @echo off > "%temp%\delete_self.bat"
echo timeout /t 2 >nul >> "%temp%\delete_self.bat"
echo del "%currentScriptPath%" >nul >> "%temp%\delete_self.bat"
echo del "%%~f0" >nul >> "%temp%\delete_self.bat"
start /b "" cmd /c "%temp%\delete_self.bat"
exit /b
call "%secondaryScript%"
exit /b
