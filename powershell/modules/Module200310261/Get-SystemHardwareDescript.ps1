function Get-SystemHardwareDescription{
	$ComputerSystemInfo = gwmi Win32_ComputerSystem
	$ComputerSystemInfo
}