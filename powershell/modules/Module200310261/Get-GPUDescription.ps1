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