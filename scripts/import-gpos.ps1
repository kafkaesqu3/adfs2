Import-Module ActiveDirectory

# Purpose: sets Helpdesk group as local admins on all workstations
Write-Host "Setting group membership policies"
$GPOName = 'helpdesk'
$OU = "ou=Workstations,ou=US,dc=zioptis,dc=local"
Write-Host "Importing $GPOName..."
# backup a GPO with the command:  backup-gpo -name helpdesk -path C:\
Import-GPO -BackupGpoName $GPOName -Path "c:\fileshare\policies\Helpdesk_localadmins" -TargetName $GPOName -CreateIfNeeded
$gpLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name $GPOName
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name $GPOName -Target $OU -Enforced yes
}
else
{
    Write-Host "GpLink $GPOName already linked on $OU. Moving On."
}


# # Purpose: Installs the GPOs for the custom WinEventLog auditing policy.
# Write-Host "Configuring auditing policy GPOS..."
# $GPOName = 'Domain Controllers Enhanced Auditing Policy'
# $OU = "ou=Domain Controllers,dc=zioptis,dc=local"
# Write-Host "Importing $GPOName..."
# Import-GPO -BackupGpoName $GPOName -Path "c:\fileshare\policies\Domain_Controllers_Enhanced_Auditing_Policy" -TargetName $GPOName -CreateIfNeeded
# $gpLinks = $null
# $gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
# $GPO = Get-GPO -Name $GPOName
# If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
# {
#     New-GPLink -Name $GPOName -Target $OU -Enforced yes
# }
# else
# {
#     Write-Host "GpLink $GPOName already linked on $OU. Moving On."
# }

# $GPOName = 'Servers Enhanced Auditing Policy'
# $OU = "ou=Servers,dc=zioptis,dc=local"
# Write-Host "Importing $GPOName..."
# Import-GPO -BackupGpoName $GPOName -Path "c:\vagrant\resources\GPO\Servers_Enhanced_Auditing_Policy" -TargetName $GPOName -CreateIfNeeded
# $gpLinks = $null
# $gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
# $GPO = Get-GPO -Name $GPOName
# If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
# {
#     New-GPLink -Name $GPOName -Target $OU -Enforced yes
# }
# else
# {
#     Write-Host "GpLink $GPOName already linked on $OU. Moving On."
# }

# $GPOName = 'Workstations Enhanced Auditing Policy'
# $OU = "ou=Workstations,dc=zioptis,dc=local" 
# Write-Host "Importing $GPOName..."
# Import-GPO -BackupGpoName $GPOName -Path "c:\vagrant\resources\GPO\Workstations_Enhanced_Auditing_Policy" -TargetName $GPOName -CreateIfNeeded
# $gpLinks = $null
# $gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
# $GPO = Get-GPO -Name $GPOName
# If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
# {
#     New-GPLink -Name $GPOName -Target $OU -Enforced yes
# }
# else
# {
#     Write-Host "GpLink $GPOName already linked on $OU. Moving On."
# }












# # Purpose: Install the GPO that specifies the WEF collector
# Write-Host "Importing the GPO to enable Powershell Module, ScriptBlock and Transcript logging..."
# Import-GPO -BackupGpoName 'Powershell Logging' -Path "c:\vagrant\resources\GPO\powershell_logging" -TargetName 'Powershell Logging' -CreateIfNeeded
# $OU = "ou=Workstations,dc=zioptis,dc=local" 
# $gPLinks = $null
# $gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
# $GPO = Get-GPO -Name 'Powershell Logging'
# If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
# {
#     New-GPLink -Name 'Powershell Logging' -Target $OU -Enforced yes
# }
# else
# {
#     Write-Host "Powershell Loggin was already linked at $OU. Moving On."
# }
# $OU = "ou=Servers,dc=zioptis,dc=local" 
# $gPLinks = $null
# $gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
# $GPO = Get-GPO -Name 'Powershell Logging'
# If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
# {
#     New-GPLink -Name 'Powershell Logging' -Target $OU -Enforced yes
# }
# else
# {
#     Write-Host "Powershell Loggin was already linked at $OU. Moving On."
# }
# $OU = "ou=Domain Controllers,dc=zioptis,dc=local"
# $gPLinks = $null
# $gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
# If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
# {
#     New-GPLink -Name 'Powershell Logging' -Target $OU -Enforced yes
# }
# else
# {
#     Write-Host "Powershell Loggin was already linked at $OU. Moving On."
# }
# gpupdate /force