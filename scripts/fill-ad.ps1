# http://technet.microsoft.com/de-de/library/dd378937%28v=ws.10%29.aspx
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/29/powertip-create-an-organizational-unit-with-powershell.aspx
Write-Host "HELLO I AM fill-ad"
Import-Module ActiveDirectory
try {
    NEW-ADOrganizationalUnit -name "IT-Services"
    NEW-ADOrganizationalUnit -name "SupportGroups" -path "OU=IT-Services,DC=zioptis,DC=local"
    NEW-ADOrganizationalUnit -name "CostCenter" -path "OU=SupportGroups,OU=IT-Services,DC=zioptis,DC=local"
}
catch {
}

try {
    NEW-ADOrganizationalUnit -name "Locations"
    NEW-ADOrganizationalUnit -name "HeadQuarter" -path "OU=Locations,DC=zioptis,DC=local"
    NEW-ADOrganizationalUnit -name "Users" -path "OU=HeadQuarter,OU=Locations,DC=zioptis,DC=local"
}
catch {
}

Import-CSV -delimiter ";" c:\scripts\users.csv | foreach {
  try {
    New-ADUser -SamAccountName $_.SamAccountName -GivenName $_.GivenName -Surname $_.Surname -Name $_.Name `
               -Path "OU=Users,OU=HeadQuarter,OU=Locations,DC=zioptis,DC=local" `
               -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -Enabled $true
    }
    catch 
   {    
   }
}

try {
    New-ADGroup -Name "SecurePrinting" -SamAccountName SecurePrinting -GroupCategory Security -GroupScope Global -DisplayName "Secure Printing Users" -Path "OU=SupportGroups,OU=IT-Services,DC=zioptis,DC=local"
    New-ADGroup -Name "CostCenter-123" -SamAccountName CostCenter-123 -GroupCategory Security -GroupScope Global -DisplayName "CostCenter 123 Users" -Path "OU=CostCenter,OU=SupportGroups,OU=IT-Services,DC=zioptis,DC=local"
    New-ADGroup -Name "CostCenter-125" -SamAccountName CostCenter-125 -GroupCategory Security -GroupScope Global -DisplayName "CostCenter 125 Users" -Path "OU=CostCenter,OU=SupportGroups,OU=IT-Services,DC=zioptis,DC=local"
}
catch {
}

try 
{
    Add-ADGroupMember -Identity SecurePrinting -Members CostCenter-125
    Add-ADGroupMember -Identity CostCenter-125 -Members mike.hammer
    Add-ADGroupMember -Identity CostCenter-123 -Members john.franklin
}
catch {
}

Write-Host "done with fill-ad"