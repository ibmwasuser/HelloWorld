# Define the path to the file containing server names
$ServersFile = "C:\Path\To\Servers.txt"

# Read the list of server names from the file
$Servers = Get-Content $ServersFile

# Get the credentials
$cred = Get-Credential

# Define the session options
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

# Initialize an array to store the output from each server
$outputArray = @()

# Loop through each server and execute the script
foreach ($Server in $Servers) {
    # Create a new PSSession for the current server
    $Session = New-PSSession -ComputerName $Server -SessionOption $so -UseSSL -Credential $cred
    
    # Execute the script block on the remote server and store only the necessary information in $output
    $output = Invoke-Command -Session $Session -ScriptBlock {
        $logicalDisks = Get-WmiObject -Class Win32_LogicalDisk -Filter DriveType=3
        
        $logicalDisks | ForEach-Object {
            $diskSizeGB = [math]::Round($_.Size / 1GB, 2)
            $freeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2)
            $freeSpacePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
            
            [PSCustomObject]@{
                SystemName = $_.SystemName
                DeviceID = $_.DeviceID
                VolumeName = $_.VolumeName
                SizeGB = $diskSizeGB
                FreeSpaceGB = $freeSpaceGB
                FreeSpacePercent = $freeSpacePercent
            }
        }
    }
    
    # Add only the necessary information from the output of the current server to the $outputArray
    $outputArray += $output
    
    # Remove the PSSession
    Remove-PSSession -Session $Session
}

# Format the output array as a table
$outputArray | Format-Table
