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
