# Author:   @virtualhobbit
# Website:  http://virtualhobbit.com
# Ref:      https://virtualhobbit.com/2016/06/08/wednesday-tidbit-using-powershell-to-create-group-policy-objects
 
# Variables
$modName = "C:\scripts\GPWmiFilter.psm1"
$GPOname = "Helpdesk admin group"
$defaultNC = ( [ADSI]"LDAP://RootDSE" ).defaultNamingContext.Value
$domainRoot = $defaultNC
#$WMIFilterName = 'Windows 2008 R2 onwards'
 
  
# Unblock module
Unblock-File $modName
 
# Import modules
Import-Module ActiveDirectory
Import-Module GroupPolicy
Import-Module $modName -Force
if(!(Get-Module "GPWmiFilter")){
    Write-Host -ForegoundColor Red "Error: The correct module is not loaded. Exiting"
     
    Exit
}
 
# Create GPO shell
$GPO = New-GPO -Name $GPOname
 
# Disable User Configuration
$GPO.GpoStatus = "Helpdesk"
 
# Set the RFC number as the description
$GPO.Description = "set helpdesk users as local admins"
 
# Create WMI Filter
#$filter = New-GPWmiFilter -Name $WMIFilterName -Expression 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.0%" OR Version LIKE "6.1%" OR Version LIKE "6.2%" OR Version LIKE "6.3%"' -Description 'Queries for Windows Server 2008 R2 onwards' -PassThru
 
# Add WMI Filter to GPO
#$GPO.WmiFilter = $filter
 
# Enable WinRM
$winrmkey = 'HKLM\Software\Policies\Microsoft\Windows\WinRM\Service'
$params = @{
    Key = $winrmkey;
    ValueName = 'AllowAutoConfig';
    Value = 1;
    Type = 'Dword';
}
$GPO | Set-GPRegistryValue @params
 
# Link GPO to domain root
New-GPLink -Name $GPOname -Target $domainRoot | Out-Null