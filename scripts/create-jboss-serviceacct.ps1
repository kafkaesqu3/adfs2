Import-Module ActiveDirectory
  
$Domain = Get-ADDomain
$DomainShort = $Domain.name + '\'

$identity = "svcJBOSS"
$hostname = "jboss-dev"
$password = 'Pa$sw0rd'

# remove user if already created
Try {
  Remove-ADUser -Identity $identity -Confirm:$false
} Catch {
  write-host "Error removing user; account probably doesnt exist"
  echo $_.Exception|format-list -force
}

# create account
Try {
New-ADUser -SamAccountName $identity -GivenName "JBoss7 SSO" -Surname "JBoss7 SSO" -Name $identity `
  -CannotChangePassword $true -PasswordNeverExpires $true -Enabled $true `
  -Path $("OU=ServiceAccounts,OU=IT-Services," + $Domain.DistinguishedName) `
  -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force)
} Catch {
  Write-host "Error creating service account user"
  echo $_.Exception|format-list -force
}

# disable kerberos preauth on account (ASREP)
# http://www.jeffgeiger.com/wiki/index.php/PowerShell/ADUnixImport
try {
Get-ADUser -Identity $identity | Set-ADAccountControl -DoesNotRequirePreAuth:$true
} Catch {
  Write-host "Get-ADUser | Set-ADAccountControl "
  echo $_.Exception|format-list -force
}

# create keytab
New-Item -Path c:\vagrant\resources -type directory -Force -ErrorAction SilentlyContinue
If (Test-Path c:\vagrant\resources\$identity.keytab) {
  Remove-Item c:\vagrant\resources\$identity.keytab
}

$servicePrincipalName = 'HTTP/' + $hostname + '.' + $Domain.dnsroot + '@' + $Domain.dnsroot.ToUpper()

Try {
& ktpass -out c:\vagrant\resources\$identity.keytab -princ $servicePrincipalName -mapUser $($DomainShort + "$identity") -mapOp set -pass $password  -crypto RC4-HMAC-NT
}
catch {
  write-host "ktpass failed"
  echo $_.Exception|format-list -force
}

If (Test-Path c:\vagrant\resources\$identity.keytab) {
  try {
    Write-Host -fore green "Keytab created for user $identity at c:\vagrant\resources\$identity.keytab"
    & setspn -l $identity
  } catch {
    write-host "error setting SPN"
    echo $_.Exception|format-list -force
  }
} else {
  Write-Host -fore red "Keytab not created"
}