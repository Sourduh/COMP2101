function Get-SystemHardwareDescription{
	$ComputerSystemInfo = gwmi Win32_ComputerSystem
	$ComputerSystemInfo
}

function Get-OperatingDescription{
	$OSInfo = Get-CimInstance Win32_OperatingSystem
	
	$OSTable = @()
	foreach ($OS in $OSInfo) {
		$OSTable += [PSCustomObject]@{
			"Operating System" = $OS.Caption
			"Version Number" = $OS.version
		}
	}
	$OSTable | Format-Table -AutoSize "Operating System", "Version Number"
}

function Get-CPUDescription {
	$CPUInfo = Get-CimInstance Win32_Processor
	$CPUTable = @()
	foreach ($CPU in $CPUInfo) {
		$CPUL1 = If ($CPU.L1CacheSize -eq $null) { "N/A" } else { $CPU.L1CacheSize}
		$CPUL2 = If ($CPU.L2CacheSize -eq $null) { "N/A" } else { $CPU.L2CacheSize}
		$CPUL3 = If ($CPU.L3CacheSize -eq $null) { "N/A" } else { $CPU.L3CacheSize}
		

		$CPUTable += [PSCustomObject]@{
			"Name" = $CPU.name
			"Speed (GHz)" = $CPU.MaxClockSpeed / 1000 -as [int]
			Cores = $CPU.NumberOfCores
			"L1 Cache" = $CPUL1
			"L2 Cache" = $CPUL2
			"L3 Cache" = $CPUL3
		}
	}
	$CPUTable | Format-Table -AutoSize "Name", "Speed (GHz)", Cores, "L1 Cache", "L2 Cache", "L3 Cache"
}

function Get-GPUDescription{
	$GPUInfo = Get-CimInstance Win32_VideoController
	$GPUTable = @()
	foreach ($GPU in $GPUInfo) {
		$GPUTable += [PSCustomObject]@{
			"Vendor" = $GPUInfo.AdapterCompatibility
			"Description" = $GPUInfo.Description
			"Resolution" = "$($GPUInfo.CurrentHorizontalResolution) x $($GPUInfo.CurrentVerticalResolution)"
		}
	}
	$GPUTable | Format-Table -AutoSize "Vendor", "Description", "Resolution"
}


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

function Get-NetworkInformation {
	$NetworkConfiguration = Get-CimInstance win32_networkadapterconfiguration | Where-Object {$_.ipenabled -eq $true }
	$ConfigurationTable = @()
	foreach ($config in $NetworkConfiguration) {
		$description = If ($config.Description -eq $null) { "N/A" } else { $config.Description}
		$index = If ($config.Index -eq $null) { "N/A" } else { $config.Index}
		$IPAddress = If ($config.IPAddress -eq $null) { "N/A" } else {$config.IPAddress}
		$submask = If ($config.IPSubnet -eq $null) { "N/A" } else {$config.IPSubnet}
		$DNSdomain = If ($config.DNSDomain -eq $null) { "N/A" } else { $config.DNSDomain}
		$DNSserver = If ($config.DNSServerSearchOrder -eq $null) { "N/A" } else { $config.DNSServerSearchOrder}
		$default = If ($config.DefaultIPGateway -eq $null) { "N/A" } else { $config.DefaultIPGateway}
		$ConfigurationTable += [PSCustomObject]@{
			Description = $description
			Index = $index
			"IP Address" = $IPAddress
			"Subnet Mask" = $submask
			"DNS Domain Name" = $DNSdomain
			"DNS Server" = $default
			"Default Gateway" = $default
		}
	}
	$ConfigurationTable | Format-Table -AutoSize Description, Index, "IP Address", "Subnet Mask", "DNS Domain Name", "DNS Server", "Default Gateway"
}


Get-SystemHardwareDescription
Get-OperatingDescription
Get-CPUDescription
Get-GPUDescription
Get-PhysicalMemoryDescription
Get-DiskStorage
Get-NetworkInformation