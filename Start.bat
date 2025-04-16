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
call "%secondaryScript%"
exit /b
