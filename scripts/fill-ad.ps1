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
      }
      else
      {
          Write-Output "OU $SubOU already exists"
      }
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
      New-ADGroup -Name "Helpdesk" -SamAccountName Helpdesk -GroupCategory Security -GroupScope Global -DisplayName "Helpdesk" -Path $("OU=SupportGroups,OU=IT-Services," + $Domain.DistinguishedName)

      foreach ($role in $EmployeeRoles) {
        New-ADGroup -Name $role -SamAccountName $role -GroupCategory Security -GroupScope Global -DisplayName $role
      }
    }
  catch {
    Write-Output "Error add-group"
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
        Add-ADGroupMember -Identity CostCenter-125 -Members $_.SamAccountName
      }
      else {
        Add-ADGroupMember -Identity CostCenter-123 -Members $_.SamAccountName
      } 
    }
  }
}


function populate-groups 
{
  Write-Output "Creating DA account"
  New-ADUser -SamAccountName "GOD" -Name "GOD" `
                 -Path $("OU=IT-Services," + $Domain.DistinguishedName) `
                 -AccountPassword (ConvertTo-SecureString -AsPlainText "Zioptis123" -Force) -Enabled $true
  Add-ADGroupMember -Identity "Domain Admins" -Members "GOD"

  
  try 
    {
        Add-ADGroupMember -Identity SecurePrinting -Members CostCenter-125
    } catch {
    }
}

Create-RegionalOU
Fill-RegionalOUs
Create-ITServicesOUs
Add-Groups
Add-Users
populate-groups