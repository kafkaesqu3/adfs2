Import-Module ActiveDirectory
  
try {
  #echo "no"
  NEW-ADOrganizationalUnit -name "IT-Services"
} Catch {
  Write-Host "IT-Services"
  echo $_.Exception|format-list -force
}


Try {
  #echo "no"
  NEW-ADOrganizationalUnit -name "ServiceAccounts" -path "OU=IT-Services,DC=zioptis,DC=local"
} Catch {
  Write-Host "ServiceAccounts"
  echo $_.Exception|format-list -force
}

$identity = "jb7nd"
$hostname = "ND"
$password = 'MyPa$sw0rd'

Try {
  Remove-ADUser -Identity $identity -Confirm:$false
} Catch {
  write-host "Remove-ADUser"
  echo $_.Exception|format-list -force
}

Try {
New-ADUser -SamAccountName $identity -GivenName "JBoss7 SSO" -Surname "JBoss7 SSO" -Name $identity `
  -CannotChangePassword $true -PasswordNeverExpires $true -Enabled $true `
  -Path "OU=ServiceAccounts,OU=IT-Services,DC=zioptis,DC=local" `
  -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force)
} Catch {
  Write-host "New-ADUser "
  echo $_.Exception|format-list -force
}

# http://www.jeffgeiger.com/wiki/index.php/PowerShell/ADUnixImport
try {
Get-ADUser -Identity $identity | Set-ADAccountControl -DoesNotRequirePreAuth:$true
} Catch {
  Write-host "Get-ADUser | Set-ADAccountControl "
  echo $_.Exception|format-list -force
}

# create keytab
echo "got it"
New-Item -Path c:\vagrant\resources -type directory -Force -ErrorAction SilentlyContinue
If (Test-Path c:\vagrant\resources\$identity.keytab) {
  Remove-Item c:\vagrant\resources\$identity.keytab
}
Try {
  $servicePrincipalName = 'HTTP/' + $hostname + '.zioptis.local@zioptis.local'
} catch {
  write-host "servicePrincipalName"
  echo $_.Exception|format-list -force
}

Try {
& ktpass -out c:\vagrant\resources\$identity.keytab -princ $servicePrincipalName -mapUser "zioptis\$identity" -mapOp set -pass $password  -crypto RC4-HMAC-NT
}
catch {
  write-host "ktpass"
  echo $_.Exception|format-list -force
}

If (Test-Path c:\vagrant\resources\$identity.keytab) {
  try {
    write-host "we made it to setspn"
    Write-Host -fore green "Keytab created for user $identity at c:\vagrant\resources\$identity.keytab"
    & setspn -l $identity
  } catch {
    echo $_.Exception|format-list -force
  }
} else {
  Write-Host -fore red "Keytab not created"
}