sc.exe config wuauserv start=auto 
Start-Service -Name 'wuauserv'

. c:\scripts\install-iis.ps1
. c:\scripts\install-iisnode.ps1

. c:\scripts\install-chocolatey.ps1
. c:\scripts\install-git.ps1
. c:\scripts\install-posh-git.ps1
. c:\scripts\insert-ssh-key.ps1
. c:\scripts\install-atom.ps1
