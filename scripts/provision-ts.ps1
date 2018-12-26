Write-Host "Additional steps on terminal server"

. c:\scripts\install-remotedebugger.ps1

# nice tutorial
# https://technet.microsoft.com/en-us/library/dd883275%28v=ws.10%29.aspx
# using powershell
# http://blogs.technet.com/b/manojnair/archive/2011/12/02/rds-powershell-tfm-part-i-installing-remote-desktop-role-services.aspx

. c:\scripts\install-terminalserver.ps1

Write-Output "ts is done! If this doesnt exit automatically, ^C^C^C a few times"