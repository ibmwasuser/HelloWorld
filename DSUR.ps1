# Define the list of server names
$servers = @("LAPTOP-9F63FAHI","localhost")

# Get the credentials once
$cred = Get-Credential
#$htmlTable += "<table><tr><th>Hostname</th><th>Drive</th><th>Volume Name</th><th>Total Size (GB)</th><th>Free Space (GB)</th><th>Used Space (GB)</th></tr>"

# Define the script block to be executed on each server
$scriptBlock = {
    param($serverName, $cred)
    
    # Inside the script block, you can use the $serverName parameter to reference each server
    $so = New-PSSessionOption -SkipCACheck -SkipCNCheck —SkipRevocationCheck
    $Session = New-PSSession -ComputerName $serverName -SessionOption $so -UseSSL -Credential $cred
    
    # Get disk information for C and D drives
    $disks = Get-WmiObject -Class Win32_logicalDisk -Filter "DriveType = 3 AND (DeviceID = 'C:' OR DeviceID = 'D:')"
    
    # Start building HTML table for this server
    #$htmlTable = "<h2>Disk information for $serverName</h2>"
    #$htmlTable = "<h2>Disk information</h2>"
    $htmlTable += "<table><tr><th>Hostname</th><th>Drive</th><th>Volume Name</th><th>Total Size (GB)</th><th>Free Space (GB)</th><th>Used Space (GB)</th></tr>"
    
    # Populate HTML table with disk information
    foreach ($disk in $disks) {
        #$htmlTable += "<tr>"
        $htmlTable += "<td>$($env:COMPUTERNAME)</td>"
        $htmlTable += "<td>$($disk.DeviceID)</td>"
        $htmlTable += "<td>$($disk.VolumeName)</td>"
        $htmlTable += "<td>$([math]::Round($disk.Size / 1GB, 2))</td>"
        $htmlTable += "<td>$([math]::Round($disk.FreeSpace / 1GB, 2))</td>"
        $htmlTable += "<td>$([math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2))</td>"
        $htmlTable += "</tr>"
    }
    
    $htmlTable += "</table>"
    
    Write-Output $htmlTable
    Remove-PSSession -Session $Session
}

# Initialize HTML content for all servers
$htmlContent = "<html><head><style>table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid #dddddd; text-align: left; padding: 8px; } th { background-color: #f2f2f2; }</style></head><body>"

# Loop through each server and execute the script block
foreach ($server in $servers) {
    $result = Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $server, $cred
    $htmlContent += $result
}

# Finalize HTML content
$htmlContent += "</body></html>"

# Save the HTML content to a file
$htmlContent | Out-File -FilePath "C:\temp\AllServerDiskInfo.html"
