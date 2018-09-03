#======================================================================================
#	Author: David Segura
#	Version: 18.9.3
#	https://www.osdeploy.com/
#======================================================================================
#   Set Error Preference
#======================================================================================
$ErrorActionPreference = 'SilentlyContinue'
#$VerbosePreference = 'Continue'
#======================================================================================
#   Set OSDeploy
#======================================================================================
$OSDeploy = "$env:ProgramData\OSDeploy"
$OSConfig = "$env:ProgramData\OSConfig"
$OSConfigLogs = "$OSDeploy\Logs\OSConfig"
$ScriptName = $MyInvocation.MyCommand.Name
$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path -Parent
$Host.UI.RawUI.WindowTitle = "$ScriptDirectory\$ScriptName"
#======================================================================================
#	Create the Log Directory
#======================================================================================
if (!(Test-Path $OSConfigLogs)) {New-Item -ItemType Directory -Path $OSConfigLogs}
#======================================================================================
#	Start the Transcript
#======================================================================================
$LogName = "$ScriptName-$((Get-Date).ToString('yyyy-MM-dd-HHmmss')).log"
Start-Transcript -Path (Join-Path $OSConfigLogs $LogName)
Write-Host ""
Write-Host "Starting $ScriptName from $ScriptDirectory" -ForegroundColor Yellow
#======================================================================================
#	Create the Registry Backup Directory
#======================================================================================
$RegistryBackup = "$OSDeploy\RegistryBackup\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))"
if (!(Test-Path $RegistryBackup)) {
	New-Item -ItemType Directory -Path $RegistryBackup | Out-Null
}
#======================================================================================
#	Backup the Registry
#======================================================================================
$regExport = 
"export HKCC $RegistryBackup\HKCC.reg /y",
"export HKCU $RegistryBackup\HKCU.reg /y",
"export HKU\.Default $RegistryBackup\HKU-Default.reg /y",
"export HKLM\HARDWARE $RegistryBackup\HKLM-Hardware.reg /y",
"export HKLM\SOFTWARE\Classes $RegistryBackup\HKLM-Software-Classes.reg /y",
"export HKLM\SOFTWARE\Microsoft $RegistryBackup\HKLM-Software-Microsoft.reg /y",
"export HKLM\SOFTWARE\Policies $RegistryBackup\HKLM-Software-Policies.reg /y",
"export HKLM\SYSTEM $RegistryBackup\HKLM-System.reg /y",
"export HKLM\SYSTEM\Setup $RegistryBackup\HKLM-System-Setup.reg /y"

foreach ($reg in $regExport) {
	Write-Host "reg $reg" -ForegroundColor Green
	Start-Process reg -ArgumentList $reg -Wait -WindowStyle Hidden
	Write-Host ""
}
#======================================================================================
#	Enable the following lines for testing as needed
#	Start-Process PowerShell_ISE.exe -Wait
#	Read-Host -Prompt "Press Enter to Continue"
#======================================================================================
Stop-Transcript
#======================================================================================