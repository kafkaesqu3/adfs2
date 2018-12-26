Write-Host "Additional steps on print server"

dism.exe /Online /Enable-Feature=Printing-Server-Role
dism.exe /Online /Enable-Feature=Printing-AdminTools-Collection

#dism.exe /Online /Enable-Feature=Printing-LPRPortMonitor
#dism.exe /Online /Enable-Feature=Printing-InternetPrinting-Client
#dism.exe /Online /Enable-Feature=Printing-LPDPrintService
#dism.exe /Online /Enable-Feature=Printing-InternetPrinting-Server
#dism.exe /Online /Enable-Feature=Printing-XPSServices-Features

Write-Output "ps is done! If this doesnt exit automatically, ^C^C^C a few times"