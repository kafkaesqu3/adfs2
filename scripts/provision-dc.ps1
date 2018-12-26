Write-Host "Additional steps on domain controller"

. c:\scripts\fill-ad.ps1
# . c:\scripts\create-jboss-serviceacct.ps1
#. c:\scripts\create-jb7ep-keytab.ps1
. c:\scripts\finish-domain-provision.ps1
. c:\scripts\fill-networkshares.ps1

Write-Output "Setting default OU: All new machines will be considered workstations"
Redircmp.exe ou=workstations,ou=us,dc=zioptis,dc=local 