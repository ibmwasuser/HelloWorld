# Define the list of server names
$servers = @("LAPTOP-9F63FAHI","localhost")

# Get the credentials once
$cred = Get-Credential

# Define the script block to be executed on each server
$scriptBlock = {
    param($serverName, $cred)
    
    # Inside the script block, you can use the $serverName parameter to reference each server
    $so = New-PSSessionOption -SkipCACheck -SkipCNCheck —SkipRevocationCheck
    $Session = New-PSSession -ComputerName $serverName -SessionOption $so -UseSSL -Credential $cred
    
    # Get disk information for C and D drives
    $disks = Get-WmiObject -Class Win32_logicalDisk -Filter "DriveType = 3"
    
    # Display disk information in GB
    Write-Output "Disk information for ${serverName}:"
    $disks | Select-Object SystemName, DeviceID, VolumeName, `
               @{Name="TotalSize(GB)";Expression={[math]::Round($_.Size / 1GB, 2)}}, `
               @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}, `
               @{Name="UsedSpace(GB)";Expression={[math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)}}
    Remove-PSSession -Session $Session
}

# Loop through each server and execute the script block
foreach ($server in $servers) {
    Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $server, $cred
}
