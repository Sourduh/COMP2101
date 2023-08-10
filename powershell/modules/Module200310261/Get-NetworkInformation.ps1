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