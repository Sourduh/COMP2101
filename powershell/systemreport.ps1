Param(
	[switch]$System,
	[switch]$Disks,
	[switch]$Network
)

if ($system) {
	Get-SystemHardwareDescription
	Get-OperatingDescription
	Get-PhysicalMemoryDescription
	Get-GPUDescription
}

if ($Disks) {
	Get-DiskStorage
}

if ($Network) {
	Get-NetworkInformation
}

if (-not ($System -or $Disks -or $Network)) {
	Get-SystemHardwareDescription
	Get-OperatingDescription
	Get-PhysicalMemoryDescription
	Get-GPUDescription
	Get-DiskStorage
	Get-NetworkInformation
}