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
