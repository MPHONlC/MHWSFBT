@echo off
setlocal
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
set "dest=%USERPROFILE%\AppData\Local\Temp"

title Monster Hunter Wilds : Save File Backup Script --- Loading Scripts...
echo ============================================================
echo Loading Scripts...
echo ============================================================
echo.

call :DownloadAndVerify "Monitor.bat" "https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/Monitor.bat" "4F5BA3B759A9B01AD65C630DA682133800C8356710417D63B14C1B270B624592"
if errorlevel 1 goto error_exit

call :DownloadAndVerify "SFB.bat" "https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat" "F7EF964C80F459D4FD4DF75A190FBCDD0ADE1BFBB8035F411B2D126D145E6561"
if errorlevel 1 goto error_exit

echo.
title Monster Hunter Wilds : Save File Backup Script --- All files loaded and verified successfully.
echo ============================================================
echo All files loaded and verified successfully.
echo ============================================================
echo.
echo.
timeout /t 5 >nul

echo Executing MHWSaveFileBackupTool.bat...
if exist "%~dp0MHWSaveFileBackupTool.bat" (
    call "%~dp0MHWSaveFileBackupTool.bat"
) else (
    title Monster Hunter Wilds : Save File Backup Script --- [!] MHWSaveFileBackupTool.bat is missing. Please download it.
    echo [!] MHWSaveFileBackupTool.bat is missing. Please download it.
)

start "" /min "%USERPROFILE%\AppData\Local\Temp\Monitor.bat"
echo Monitor.bat has been launched in a minimized window.
echo Now continuing with the rest of the script...
cls
timeout /t 1 >nul

goto end_script

:error_exit
echo.
echo Exiting script due to errors.
timeout /t 5 >nul

:end_script
exit /b

:DownloadAndVerify
setlocal EnableDelayedExpansion
set "filename=%~1"
set "url=%~2"
set "expected=%~3"
set "file=%dest%\%filename%"
set count=0

:download_loop
   set /a count+=1
   if exist "!file!" del /f /q "!file!"
   echo.
   echo Loading script (Attempt !count! of 3)...
   title Monster Hunter Wilds : Save File Backup Script --- Loading script (Attempt !count! of 3)...
   curl -L "!url!" -o "!file!" >nul 2>&1
   if not exist "!file!" (
       echo Failed to load script.
       title Monster Hunter Wilds : Save File Backup Script --- Failed to load script.
       if !count! lss 3 (
           echo Retrying to load script...
           title Monster Hunter Wilds : Save File Backup Script --- Retrying to load script...
           timeout /t 2 >nul
           goto download_loop
       ) else (
           echo [!] Failed to load script after 3 attempts.
           title Monster Hunter Wilds : Save File Backup Script --- [!] Failed to load script after 3 attempts.
           endlocal
           exit /b 1
       )
   )
   echo Script Loaded.
   title Monster Hunter Wilds : Save File Backup Script --- Script Loaded.
   echo.
   title Monster Hunter Wilds : Save File Backup Script --- Verifying...
   echo Verifying...
   cls
   del "%temp%\hash_!filename!.txt" 2>nul
   start /b "" certutil -hashfile "!file!" SHA256 > "%temp%\hash_!filename!.txt"
   set progress=0

:wait_for_certutil
   tasklist /FI "IMAGENAME eq certutil.exe" | findstr /i "certutil.exe" >nul
   if not errorlevel 1 (
      set /a progress+=10
      if !progress! gtr 100 set progress=100
      title Monster Hunter Wilds : Save File Backup Script --- Verification Progress: !progress!%%
      echo Verification Progress: !progress!%%
      timeout /t 1 >nul
      goto wait_for_certutil
   )
   set "calculated="
   for /f "usebackq skip=1 tokens=*" %%H in ("%temp%\hash_!filename!.txt") do (
       set "line=%%H"
       echo !line! | findstr /R "^[0-9A-F]" >nul
       if not errorlevel 1 (
           set "calculated=!line!"
           goto afterhash
       )
   )

:afterhash
   set "calculated=!calculated: =!"
   echo.
   echo Calculated Hash: !calculated!
   echo Expected Hash:   !expected!
   echo.
   if /i "!calculated!"=="!expected!" (
       title Monster Hunter Wilds : Save File Backup Script --- Script Verification SUCCESSFUL.
       echo Script Verification SUCCESSFUL.
       timeout /t 2 >nul
       endlocal & exit /b 0
   ) else (
       title Monster Hunter Wilds : Save File Backup Script --- Script Verification FAILED.
       echo Script Verification FAILED.
       if !count! lss 3 (
           title Monster Hunter Wilds : Save File Backup Script --- Retrying to load...
           echo Retrying to load...
           timeout /t 2 >nul
           goto download_loop
       ) else (
           title Monster Hunter Wilds : Save File Backup Script --- [!] Failed to load and verify script after 3 attempts.
           echo [!] Failed to load and verify script after 3 attempts.
           timeout /t 5 >nul
           endlocal
           exit /b 1
       )
   )
