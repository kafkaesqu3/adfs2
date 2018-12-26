Write-Output "Setting registry key to disable defender real time scanning"
Reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
try {
Write-Output "1"    
sc.exe stop WinDefend
Write-Output "2"
} catch {
    Write-Output "Error stopping defender service!"
}

try {
Write-Output "3"
Set-MpPreference -DisableRealtimeMonitoring $true
Write-Output "4"
} catch {
    Write-Output "Error disabling defender realtime monitoring"
}