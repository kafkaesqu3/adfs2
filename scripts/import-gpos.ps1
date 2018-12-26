Write-Output "importing group policies into domain"
# backup a GPO with the command:  backup-gpo -name helpdesk -path C:\
import-gpo -BackupId "{F3D49DC4-F7FE-4925-8771-241F9AFBCCD4}" -path 'C:\fileshare\policies' -targetname helpdesk -CreateIfNeeded

Write-Output "linking imported policies to domain OUs"
$OU = "ou=Workstations,ou=US,dc=zioptis,dc=local"
New-GPLink -Name helpdesk -Target $OU -Enforced yes

