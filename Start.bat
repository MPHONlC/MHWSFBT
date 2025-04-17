@echo off
setlocal
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
set "dest=%USERPROFILE%\AppData\Local\Temp"
color 0A
title Monster Hunter Wilds : Save File Backup Script --- Loading Scripts...
echo ============================================================
echo Loading Scripts...
echo ============================================================
echo.
cls
call :DownloadAndVerify "Monitor.bat" "https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/Monitor.bat" "4F5BA3B759A9B01AD65C630DA682133800C8356710417D63B14C1B270B624592"
if errorlevel 1 goto error_exit
call :DownloadAndVerify "SFB.bat" "https://raw.githubusercontent.com/MPHONlC/MHWSFBT/main/SFB.bat" "F7EF964C80F459D4FD4DF75A190FBCDD0ADE1BFBB8035F411B2D126D145E6561"
if errorlevel 1 goto error_exit
echo.
color 0A
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
    color 06
    title Monster Hunter Wilds : Save File Backup Script --- [!] MHWSaveFileBackupTool.bat is missing. Please download it.
    echo [!] MHWSaveFileBackupTool.bat is missing. Please download it.
)
start "" /min "%USERPROFILE%\AppData\Local\Temp\Monitor.bat"
color 0A
echo Monitor.bat has been launched in a minimized window.
echo Now continuing with the rest of the script...
cls
timeout /t 1 >nul
goto end_script
:error_exit
echo.
color 04
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
   color 05
   echo Loading script (Attempt !count! of 3)...
   title Monster Hunter Wilds : Save File Backup Script --- Loading script (Attempt !count! of 3)...
   curl -L "!url!" -o "!file!" >nul 2>&1
   if not exist "!file!" (
       color 04
       echo Failed to load script.
       title Monster Hunter Wilds : Save File Backup Script --- Failed to load script.
       if !count! lss 3 (
	   color 06
           echo Retrying to load script...
           title Monster Hunter Wilds : Save File Backup Script --- Retrying to load script...
           timeout /t 2 >nul
           goto download_loop
       ) else (
	   color 04
           echo [!] Failed to load script after 3 attempts.
           title Monster Hunter Wilds : Save File Backup Script --- [!] Failed to load script after 3 attempts.
           endlocal
           exit /b 1
       )
   )
   color 03
   echo Script Loaded.
   title Monster Hunter Wilds : Save File Backup Script --- Script Loaded.
   echo.
   cls
   color 05
   title Monster Hunter Wilds : Save File Backup Script --- Verifying...
   echo Verifying...
   cls
   del "%temp%\hash_!filename!.txt" 2>nul
   certutil -hashfile "!file!" SHA256 > "%temp%\hash_!filename!.txt" 2>&1
   set "calculated="
   for /f "usebackq skip=1 tokens=1" %%H in ("%temp%\hash_!filename!.txt") do (
       set "calculated=%%H"
       goto afterhash
   )
:afterhash
   set "calculated=!calculated: =!"
   echo.
   echo Calculated Hash: !calculated!
   echo Expected Hash:   !expected!
   echo.
   if /i "!calculated!"=="!expected!" (
       color 0A
       title Monster Hunter Wilds : Save File Backup Script --- Script Verification SUCCESSFUL.
       echo Script Verification SUCCESSFUL.
       timeout /t 2 >nul
       endlocal & exit /b 0
   ) else (
       color 04
       title Monster Hunter Wilds : Save File Backup Script --- Script Verification FAILED.
       echo Script Verification FAILED.
       if !count! lss 3 (
	   color 05
           title Monster Hunter Wilds : Save File Backup Script --- Retrying to load...
           echo Retrying to load...
           timeout /t 2 >nul
           goto download_loop
       ) else (
	   color 04
           title Monster Hunter Wilds : Save File Backup Script --- [!] Failed to load and verify script after 3 attempts.
           echo [!] Failed to load and verify script after 3 attempts.
           set "SFBEUrl=https://raw.githubusercontent.com/MPHONlC/MHWSFBT/refs/heads/main/SFBE.bat"
           set "SFBEPath=%dest%\SFBE.bat"
           curl -L --progress-bar "%SFBEUrl%" -o "%SFBEPath%"
           if exist "%SFBEPath%" (
	       color 06
	       title Monster Hunter Wilds : Save File Backup Script --- Executing cleanup Script due to verification failure...
               echo Executing cleanup Script due to verification failure...
               call "%SFBEPath%"
           ) else (
	       color 04
	       title Monster Hunter Wilds : Save File Backup Script --- Failed to execute.
               echo Failed to do cleanup.
           )
           
           timeout /t 5 >nul
           endlocal
           exit /b 1
       )
   )
