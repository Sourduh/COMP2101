function Get-DiskStorage {
	$DiskInfo = Get-CimInstance CIM_DiskDrive
	
	$DiskInfoTable = @()

	foreach ($disk in $DiskInfo) {
		$DiskPartitions = $disk | Get-CimAssociatedInstance -ResultClassName Cim_diskpartition
		foreach ($partition in $DiskPartitions) {
			$LogicalDisks = $partition | Get-CimAssociatedInstance -ResultClassName Cim_logicaldisk
			foreach ($logicaldisk in $LogicalDisks) {
				$DiskInfoTable += [PSCustomObject]@{
					Manufacturer = $disk.Manufacturer
					Location = $partition.DeviceID
					Drive = $logicaldisk.DeviceID
					"Size in GB" = $logicaldisk.size / 1GB -as [int]
					"Free Space in GB" = $logicaldisk.FreeSpace / 1GB -as [int]
					"Free Space as %" = $logicaldisk.FreeSpace / $logicaldisk.size * 100 -as [int]
				}
			}
		}
	}
	$DiskInfoTable|Format-Table -AutoSize Manufacturer, Location, Drive, "Size in GB", "Free Space in GB", "Free Space as %"
}
