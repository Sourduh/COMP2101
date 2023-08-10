$modulePath = $PSScriptRoot

$functionFiles = Get-ChildItem -Path $modulePath -Filter '*.ps1'

foreach ($file in $functionFiles) {
	. $file.FullName
}