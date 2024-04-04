# List of computer names
$computers = "localhost"

foreach ($computer in $computers) {
    Write-Host "Disk space information for ${computer}:"

    $disks = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk

    foreach ($disk in $disks) {
        $driveLetter = $disk.DeviceID
        $totalSpaceGB = [math]::Round($disk.Size / 1GB, 2)
        $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
        $freeSpacePercent = [math]::Round(($freeSpaceGB / $totalSpaceGB) * 100, 2)

        if ($freeSpacePercent -lt 39.5) {
            Write-Host -ForegroundColor Green "Drive $driveLetter - Total Space: $totalSpaceGB GB, Free Space: $freeSpaceGB GB, Free Space Percentage: $freeSpacePercent%"
        } else {
            Write-Host "Drive $driveLetter - Total Space: $totalSpaceGB GB, Free Space: $freeSpaceGB GB, Free Space Percentage: $freeSpacePercent%"
        }
    }
    Write-Host "-------------------------------------"
}
