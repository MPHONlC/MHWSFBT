$batPath = Join-Path $env:USERPROFILE "AppData\Local\Temp\Monitor.bat"
if (Test-Path $batPath) {
    Write-Output "Launching Monitoring scripts..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$batPath`"" -WindowStyle Hidden
} else {
    Write-Error "Monitoring script not found at $batPath"
}
