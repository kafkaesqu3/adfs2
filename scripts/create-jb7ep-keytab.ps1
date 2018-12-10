Import-Module ActiveDirectory

$identity = "jb7ep"
$hostname = "EP"
$password = 'MyPa$sw0rd'

Try {
  Remove-ADUser -Identity $identity -Confirm:$false
} Catch {echo $_.Exception|format-list -force}
try {
New-ADUser -SamAccountName $identity -GivenName "JBoss7 SSO" -Surname "JBoss7 SSO" -Name $identity `
  -CannotChangePassword $true -PasswordNeverExpires $true -Enabled $true `
  -Path "OU=ServiceAccounts,OU=IT-Services,DC=zioptis,DC=local" `
  -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force)
} catch {echo $_.Exception|format-list -force}

# http://www.jeffgeiger.com/wiki/index.php/PowerShell/ADUnixImport
Get-ADUser -Identity $identity | Set-ADAccountControl -DoesNotRequirePreAuth:$true

# create keytab
try {
New-Item -Path c:\vagrant\resources -type directory -Force -ErrorAction SilentlyContinue
If (Test-Path c:\vagrant\resources\$identity.keytab) {
  Remove-Item c:\vagrant\resources\$identity.keytab
}
} catch {echo $_.Exception|format-list -force}
try {
$servicePrincipalName = 'HTTP/' + $hostname + '.zioptis.local@zioptis.local'
} catch { echo $_.Exception|format-list -force}
try {
& ktpass -out c:\vagrant\resources\$identity.keytab -princ $servicePrincipalName -mapUser "zioptis\$identity" -mapOp set -pass $password  -crypto RC4-HMAC-NT
} catch {echo $_.Exception|format-list -force }

If (Test-Path c:\vagrant\resources\$identity.keytab) {
  Write-Host -fore green "Keytab created for user $identity at c:\vagrant\resources\$identity.keytab"
try {
  & setspn -l $identity
}
catch {echo $_.Exception|format-list -force}
} else {
  Write-Host -fore red "Keytab not created"
}

