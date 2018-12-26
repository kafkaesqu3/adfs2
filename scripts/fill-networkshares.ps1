function fill-department-share
{
    Write-Output "Creating new file share"
    New-Item -Path C:\departments  -ItemType Container
    New-SmbShare -Path C:\departments -Name DeptShare
    Set-SmbShare -Name  DeptShare -Description 'Zioptis departmental share' -Confirm:$false

    Write-Output "Copying files into departmental share"
    Copy-Item -recurse C:\fileshare\departments\* C:\departments\ 
}

function fill-sysvol
{
    new-item $env:systemroot\sysvol\scripts
    Write-Output "Copying scripts into SYSVOL"
    #copy-item C:\fileshare\sysvol\* $env:systemroot\sysvol\scripts
}


fill-department-share
fill-sysvol