#. c:\scripts\dis-autologon.ps1
Write-Host 'Installing RSAT tools'
wusa.exe C:\resources\WindowsTH-RSAT_WS_1803-x64.msu /quiet /norestart
#. C:\scripts\install-admodules.ps1
. c:\scripts\dis-updates.bat
. C:\scripts\disable-defender.ps1


Write-Output "Workstation is done"