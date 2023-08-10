function Get-PhysicalMemoryDescription{
	$RAMinfo = gwmi -class win32_physicalmemory
	$RAMInfoTable = @()

	foreach ($info in $RAMinfo) {
		$RAMInfoTable += [PSCustomObject]@{
			Vendor = $info.manufacture
			Description = $info.description
			Size = $info.capacity / 1GB
			Bank = $info.banklabel
			Slot = $info.devicelocator
		}
		$TotalInstalledMemory += $info.capacity / 1GB
	}
	$RAMInfoTable | Format-Table -AutoSize Vendor, Description, Size, Bank, Slot
	"Total installed RAM is $($TotalInstalledMemory)"
}
