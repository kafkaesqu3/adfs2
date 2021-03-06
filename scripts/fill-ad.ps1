# http://technet.microsoft.com/de-de/library/dd378937%28v=ws.10%29.aspx
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/29/powertip-create-an-organizational-unit-with-powershell.aspx
Import-Module ActiveDirectory

$Forest = Get-ADForest
$Domain = Get-ADDomain

# Top level OU created to hold the users and other objects
# and the list of sub-OUs to create under it
$CompanyOU = "Zioptis"
$RegionalOU = "US"

$RegionalOUs = @(
    "Employees",
    "Workstations",
    "Servers"
    )

#List of department names randomly chosen for each user
$EmployeeRoles = @(
  "Manager",
  "HR",
  "Legal",
  "Finance",
  "Engineer",
  "Sales",
  "IT",
  "Development",
  "Helpdesk",
  "Operations"
    )

$Geographic = @(
  "US")

$Locations = @( #location of asset
  "C3",
  "C5",
  "HQ")

$purpose = @(
  "DC", #DOMAIN CONTROLLERS
  "APP", #application server
  "SQL",
  "DB", #
  "FS", #FILE
  "PS", #PRINT
  "EXCH", #EXCHANGE
  "CTX", # CITRIX
  "ESX"  # VMWARE
  )
$Environments = @(
  "DEV",
  "QA",
  "PROD")

$Virtual = @(
  "V", # virtual
  "P") #physical

$SecurityGroups = @(
  "ZioptisAccounts"
  "EmailUsers",
  "VPNUsers",
  "CitrixUsers",
  "ExchMailboxAdm",
  "RDPaccess",
  "SQLread0",
  "SQLread1",
  "SQLread2",
  "SQLread3",
  "SQLwrite0",
  "SQLwrite1",
  "SQLwrite2",
  "SQLwrite3",
  "SQLwrite4",
  "GitReadAccess",
  "GitWriteAccess",
  "FinanceAuditors",
  "DBAudit",
  "LegalRead",
  "LegalWrite"
  "HRread",
  "HRwrite",
  "Interns",
  "TempEmployees",
  "SalesforceRead",
  "SalesforceWrite",
  "ESXIread",
  "ESXIwrite",
  "ProdPush",
  "DevPush",
  "QApush",
  "QAtest"
  )

Function Test-OUPath()
{
    param([string]$path)
    
    $OUExists = [adsi]::Exists("LDAP://$path")
    
    return $OUExists
}

#------------------------------------------
#-------------------OUs--------------------
#------------------------------------------
function Create-RegionalOU {
  $OUPath = "OU=" + $RegionalOU + "," + $Domain.DistinguishedName
  if (!(Test-OUPath $OUPath))
  {
      Write-Output "Creating OU: $RegionalOU"
      try
      {
          New-ADOrganizationalUnit -Name $RegionalOU -Path $Domain.DistinguishedName -ErrorAction STOP
      }
      catch
      {
          Write-Warning $_.Exception.Message
      }
  } else {
      Write-Output "OU $RegionalOU already exists"
  }
}

function Fill-RegionalOUs 
{
  foreach ($SubOU in $RegionalOUs)
  {
    $OUPath = "OU=$SubOU,OU=$RegionalOU," + $Domain.DistinguishedName
    
    if (!(Test-OUPath $OUPath))
    {
        Write-Output "Creating OU: $SubOU"
        New-ADOrganizationalUnit -Name $SubOU -Path $("OU=" + $RegionalOU + "," + $Domain.DistinguishedName)
    } else {
        Write-Output "OU $SubOU already exists"
    }
  }

  $OUPath = "OU=DeptGroups,OU=$RegionalOU," + $Domain.DistinguishedName
  if (!(Test-OUPath $OUPath))
  {
      Write-Output "Creating OU: $OUPath"
      New-ADOrganizationalUnit -Name "DeptGroups" -Path $("OU=" + $RegionalOU + "," + $Domain.DistinguishedName)
  } else {
      Write-Output "OU $OUPath already exists"
  }

  $OUPath = "OU=AccessGroups,OU=$RegionalOU," + $Domain.DistinguishedName
  if (!(Test-OUPath $OUPath))
  {
      Write-Output "Creating OU: $OUPath"
      New-ADOrganizationalUnit -Name "AccessGroups" -Path $("OU=" + $RegionalOU + "," + $Domain.DistinguishedName)
  } else {
      Write-Output "OU $OUPath already exists"
  }


  foreach ($dept in $EmployeeRoles) {
    $OUPath = "OU=" + $dept + ",OU=Employees,OU=$RegionalOU," + $Domain.DistinguishedName
    if (!(Test-OUPath $OUPath)) {
      Write-Output "Creating $dept OU"
      New-ADOrganizationalUnit -Name $dept -Path $("OU=Employees," + "OU=" + $RegionalOU + "," + $Domain.DistinguishedName)
    } else {
      Write-Output "OU $dept already exists"
    }
  }
}

function Create-ITServicesOUs
{
  $OUPath = "OU=IT-Services," + $Domain.DistinguishedName
  if (!(Test-OUPath $OUPath)) {
    Write-Output "Creating IT-Services OUs"
    New-ADOrganizationalUnit -Name "IT-Services" -Path $Domain.DistinguishedName
  } else {
    Write-Output "OU SupportGroups already exists"
  }

  $OUPath = "OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName
  if (!(Test-OUPath $OUPath)) {
    Write-Output "Creating SupportGroups OUs"
    New-ADOrganizationalUnit -Name "SupportGroups" -Path $("OU=IT-Services," + $Domain.DistinguishedName)
  } else {
    Write-Output "OU SupportGroups already exists"
  }


  $OUPath = "OU=CostCenter,OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName
  if (!(Test-OUPath $OUPath)) {
    Write-Output "Creating CostCenter OUs"
    New-ADOrganizationalUnit -Name "CostCenter" -Path $("OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName)
  } else {
    Write-Output "OU CostCenter already exists"
  }

  $OUPath = "OU=ServiceAccounts,OU=IT-Services," + $Domain.DistinguishedName
  if (!(Test-OUPath $OUPath)) {
    Write-Output "Creating ServiceAccounts OUs"
    New-ADOrganizationalUnit -Name "ServiceAccounts" -Path $("OU=IT-Services," + $Domain.DistinguishedName)
  } else {
    Write-Output "OU ServiceAccounts already exists"
  }
}


function add-Groups
{
  Write-Output "Creating security groups"
  try {
      New-ADGroup -Name "SecurePrinting" -SamAccountName SecurePrinting -GroupCategory Security -GroupScope Global -DisplayName "Secure Printing Users" -Path $("OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName)
      New-ADGroup -Name "CostCenter-123" -SamAccountName CostCenter-123 -GroupCategory Security -GroupScope Global -DisplayName "CostCenter 123 Users" -Path $("OU=CostCenter,OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName)
      New-ADGroup -Name "CostCenter-125" -SamAccountName CostCenter-125 -GroupCategory Security -GroupScope Global -DisplayName "CostCenter 125 Users" -Path $("OU=CostCenter,OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName)

      New-ADGroup -Name "Server Admins" -SamAccountName ServerAdmins -GroupCategory Security -GroupScope Global -DisplayName "Server Administrators" -Path $("OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName)
      New-ADGroup -Name "Local Admins" -SamAccountName LocalAdmins -GroupCategory Security -GroupScope Global -DisplayName "Local Administrators" -Path $("OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName)
      New-ADGroup -Name "ExchAdmins" -SamAccountName ExchAdmins -GroupCategory Security -GroupScope Global -DisplayName "Exchange Admins" -Path $("OU=IT-Services," + $Domain.DistinguishedName)
      New-ADGroup -Name "Service Accounts" -SamAccountName ServiceAccounts -GroupCategory Security -GroupScope Global -DisplayName "Service Accounts" -Path $("OU=IT-Services," + $Domain.DistinguishedName)
  } catch {
    Write-Output "Error add-group"
  }
  foreach ($group in $EmployeeRoles) {
    try {
      New-ADGroup -Name $group -SamAccountName $group -GroupCategory Security -GroupScope Global -DisplayName $group -Path $("OU=DeptGroups," + "OU=" + $RegionalOU + "," + $Domain.DistinguishedName)
      } catch {
        Write-Output "Group $group already exists"
      }
    }

  foreach ($group in $SecurityGroups) {
    try {
      New-ADGroup -Name $group -SamAccountName $group -GroupCategory Security -GroupScope Global -DisplayName $group -Path $("OU=AccessGroups," + "OU=" + $RegionalOU + "," + $Domain.DistinguishedName)
    } catch {
      Write-Output "Group $group already exists"
    }
  }
}

function add-Users 
{
  Write-Output "Adding users to domain"
  Import-CSV -delimiter "," c:\scripts\users.csv | foreach {
    $user = $_
    try {
       New-ADUser -SamAccountName $user.SamAccountName -GivenName $user.First -Surname $user.Last -Name $user.Full `
                 -Path $("OU=" + $user.Role + ",OU=Employees,OU=" + $RegionalOU + "," + $Domain.DistinguishedName) `
                 -AccountPassword (ConvertTo-SecureString -AsPlainText $user.Password -Force) -Enabled $true
    } catch {    
      #Write-Output "WARNING: User $($user.SamAccountName) already in domain"
    }
    try {
      Add-ADGroupMember -Identity $($user.Role) -Members $($user.SamAccountName)
    } catch {
      #Write-Output "Error adding user to group"
    }
    if ($_.Role -eq "Operations") {
      $rand = get-random -Maximum 2
      if ($rand -eq 0) {
        try {Add-ADGroupMember -Identity CostCenter-125 -Members $_.SamAccountName} catch {}
      }
      else {
        try {Add-ADGroupMember -Identity CostCenter-123 -Members $_.SamAccountName} catch {}
      } 
    }

    $GroupMembership = Get-Random -InputObject $SecurityGroups -Count 7
    foreach ($group in $GroupMembership) {
      try {Add-ADGroupMember -Identity $group -Members $_.SamAccountName}
      catch {}
    }    
  }
}

function add-WorkshopUsers 
{
  Write-Output "Adding workshop users to domain"
  if (!(Test-Path 'c:\scripts\users2.csv')) 
  {
    Write-Output "Data file users2.csv missing! Skipping this"  
  } else {
    Import-CSV -delimiter "," c:\scripts\users2.csv | foreach {
      $user = $_
      try {
         New-ADUser -SamAccountName $user.SamAccountName -GivenName $user.First -Surname $user.Last -Name $user.Full `
                   -Path $("OU=" + $user.Role + ",OU=Employees,OU=" + $RegionalOU + "," + $Domain.DistinguishedName) `
                   -AccountPassword (ConvertTo-SecureString -AsPlainText $user.Password -Force) -Enabled $true
      } catch {    
        #Write-Output "WARNING: User $($user.SamAccountName) already in domain"
      }
      try {
        Add-ADGroupMember -Identity $($user.Role) -Members $($user.SamAccountName)
      } catch {
        #Write-Output "Error adding user to group"
      }
      if ($_.Role -eq "Operations") {
        $rand = get-random -Maximum 2
        if ($rand -eq 0) {
          Add-ADGroupMember -Identity CostCenter-125 -Members $_.SamAccountName
        }
        else {
          Add-ADGroupMember -Identity CostCenter-123 -Members $_.SamAccountName
        } 
      }
      $GroupMembership = Get-Random -InputObject $SecurityGroups -Count 7
      foreach ($group in $GroupMembership) {
        Add-ADGroupMember -Identity $group -Members $_.SamAccountName
      }
    }
  }
}

function populate-groups 
{
  Add-ADGroupMember -Identity "Domain Admins" -Members "ExchAdmins"

  Write-Output "Creating DA account"
  New-ADUser -SamAccountName "GOD" -Name "GOD" `
                 -Path $("OU=IT-Services," + $Domain.DistinguishedName) `
                 -AccountPassword (ConvertTo-SecureString -AsPlainText "Zioptis123" -Force) -Enabled $true
  Add-ADGroupMember -Identity "Domain Admins" -Members "GOD"


  New-ADUser -SamAccountName "svcSAM505" -Name "Software Asset Nanagement" `
                 -Path $("OU=IT-Services," + $Domain.DistinguishedName) `
                 -AccountPassword (ConvertTo-SecureString -AsPlainText "nejif8eVBEc0hv" -Force) -Enabled $true
  Add-ADGroupMember -Identity "Domain Admins" -Members "svcSAM505"


  New-ADUser -SamAccountName "svcExch" -Name "Exchange Services" `
                 -Path $("OU=IT-Services," + $Domain.DistinguishedName) `
                 -AccountPassword (ConvertTo-SecureString -AsPlainText "ue3jfJfAi3fd3" -Force) -Enabled $true
  Add-ADGroupMember -Identity "ExchAdmins" -Members "svcExch"

  try 
    {
        Add-ADGroupMember -Identity SecurePrinting -Members CostCenter-125
    } catch {
    }
}

function create-machineaccounts {
  Write-Output "Creating machine accounts for servers to ensure they are placed in the correct OU"
  $ServerOUPath = "OU=Servers,OU=$RegionalOU," + $Domain.DistinguishedName
  New-ADComputer -Name "adfs2" -SamAccountName "adfs2" -Path $ServerOUPath
  New-ADComputer -Name "web" -SamAccountName "web" -Path $ServerOUPath
  New-ADComputer -Name "ps" -SamAccountName "ps" -Path $ServerOUPath
  New-ADComputer -Name "ts" -SamAccountName "ts" -Path $ServerOUPath

  Write-Output "Creating 1000 additional machine accounts to make domain look real"
  $InputRange = 10000..99999
  $RandomRange = $InputRange | Where-Object { $Exclude -notcontains $_ }

  for ($i=1; $i -le 40; $i++)
  {
    # randomly get each part of the hostname
    $geo_hostname = Get-Random -InputObject $Geographic -Count 1
    $loc_hostname = Get-Random -InputObject $Locations -Count 1
    $pur_hostname = Get-Random -InputObject $purpose -Count 1
    $env_hostname = Get-Random -InputObject $Environments -Count 1
    $vir_hostname = Get-Random -InputObject $Virtual -Count 1

    $rand = Get-Random -InputObject $RandomRange

    # build hostname
    # example: USC5-APPDEVV-33522
    $hostname = "$($geo_hostname)$($loc_hostname)-$($pur_hostname)$($env_hostname)$($vir_hostname)$($rand)"
    New-ADComputer -Name $hostname -SamAccountName $hostname -Path $ServerOUPath
  }

}

Create-RegionalOU
Fill-RegionalOUs
Create-ITServicesOUs
Add-Groups
Add-Users
add-WorkshopUsers
populate-groups
create-machineaccounts