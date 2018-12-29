Write-Host "Additional steps on domain controller"

. c:\scripts\fill-ad.ps1
. c:\scripts\finish-domain-provision.ps1
. c:\scripts\fill-networkshares.ps1
. c:\scripts\import-gpos.ps1

Write-Output "Setting default OU: All new machines will be considered workstations"
Redircmp.exe ou=workstations,ou=us,dc=zioptis,dc=local 

Write-Output "Scheduled task to make changes to other machines as they join the domain"
schtasks /create /sc minute /mo 5 /tn "PostSetup" /tr START /MIN C:\scripts\dc-postsetup-tasks.bat

Write-Output "dc is done! If vagrant doesnt exit after this, ^C^C^C a few times"