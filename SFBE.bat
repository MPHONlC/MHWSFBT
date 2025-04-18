@echo off
setlocal EnableDelayedExpansion
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Loading...
for /f "tokens=3" %%A in ('reg query "HKCU\Console" /v QuickEdit') do reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul
timeout /t 2 >nul
:CheckProcess
tasklist /FI "IMAGENAME eq MonsterHunterWilds.exe" | findstr /i "MonsterHunterWilds.exe" >nul
if %ERRORLEVEL%==0 (
    color 06
    echo MonsterHunterWilds.exe is still running. Waiting 10 seconds...
	title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] MonsterHunterWilds.exe is still running. Waiting 10 seconds...
    timeout /t 10 /nobreak >nul
	cls
    goto CheckProcess
)
color 0A
echo MonsterHunterWilds.exe is not running. Proceeding with cleanup...
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] MonsterHunterWilds.exe is not running. Proceeding with cleanup...
timeout /t 2 >nul
cls
set "filesList=Start.bat SFB.bat Monitor.bat MonitorLauncher.bat MHWSaveFileBackupTool.bat hash_Monitor.txt hash_SFB.txt hash_Monitor.bat.txt hash_SFB.bat.txt SFB Monitor hashtemp.tmp"
for %%F in (%filesList%) do (
    for /f "skip=1 tokens=1" %%a in ('wmic process where "CommandLine like '%%%F%%'" get ProcessId 2^>nul') do (
        set "pid=%%a"
        if not "!pid!"=="" (
		    color 05
		    title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Terminating process with PID !pid! associated with %%F...
            echo Terminating process with PID !pid! associated with %%F...
			timeout /t 1 >nul
			cls
            taskkill /F /PID !pid! >nul 2>&1
        )
    )
)
color 05
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Deleting files from "%USERPROFILE%\AppData\Local\Temp"...
echo Deleting files from "%USERPROFILE%\AppData\Local\Temp"...
timeout /t 1 >nul
cls
for %%F in (%filesList%) do (
    if exist "%USERPROFILE%\AppData\Local\Temp\%%F" (
       echo Deleting "%USERPROFILE%\AppData\Local\Temp\%%F"
       del /F /Q "%USERPROFILE%\AppData\Local\Temp\%%F"
    )
)
set "otherFiles=SFBE.bat handle.exe handle64.exe handle64a.exe handle.zip Eula.txt"
color 05
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Deleting additional files from "%USERPROFILE%\AppData\Local\Temp"...
echo Deleting additional files from "%USERPROFILE%\AppData\Local\Temp"...
timeout /t 1 >nul
cls
for %%F in (%otherFiles%) do (
    if exist "%USERPROFILE%\AppData\Local\Temp\%%F" (
       echo Deleting "%USERPROFILE%\AppData\Local\Temp\%%F"
       del /F /Q "%USERPROFILE%\AppData\Local\Temp\%%F"
    )
)
color 05
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Emptying Recycle Bin...
echo Emptying Recycle Bin...
timeout /t 1 >nul
cls
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Force" >nul
color 0A
title Monster Hunter Wilds : Save File Backup Script --- [CLEANUP] Cleanup complete.
echo Cleanup complete.
timeout /t 2 >nul
endlocal
exit
