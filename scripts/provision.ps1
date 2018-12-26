Write-Output "Disable firewall"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

$box = Get-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name "ComputerName"
$box = $box.ComputerName.ToString().ToLower()

if ($env:COMPUTERNAME -imatch 'vagrant') {

  Write-Host 'Hostname is still the original one, skip provisioning for reboot'

  Write-Host 'Install bginfo'
  . c:\scripts\install-bginfo.ps1

  Write-Host -fore red 'Hint: vagrant reload' $box '--provision'

} elseif ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host -fore red "Ooops, workgroup!"

  if (!(Test-Path 'c:\scripts\bginfo.exe')) {
    Write-Host 'Install bginfo'
    . c:\scripts\install-bginfo.ps1
  }

  if ($env:COMPUTERNAME -imatch 'dc') {
    . c:\scripts\create-domain.ps1 192.168.40.2
  } else {
    . c:\scripts\join-domain.ps1
  }

  Write-Host -fore red 'Hint: vagrant reload' $box '--provision'

} else {

  Write-Host -fore green "I am domain joined!"

  if (!(Test-Path 'c:\scripts\bginfo.exe')) {
    Write-Host 'Install bginfo'
    . c:\scripts\install-bginfo.ps1
  }

  c:\scripts\pinto10.exe /PTFILE C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe

  Write-Host 'Provisioning after joining domain'

  $script = "c:\scripts\provision-" + $box + ".ps1"
  . $script
}
