#======================================================================================
#	Author: David Segura
#	Version: 18.8.29
#	https://www.osdeploy.com/
#======================================================================================
#   Set Error Preference
#======================================================================================
$ErrorActionPreference = 'SilentlyContinue'
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





#======================================================================================
#   Relocate OSConfig
#======================================================================================
if ($ScriptDirectory -ne $OSConfig){
	if (Test-Path $OSConfig) {
		Write-Host "Removing existing $OSConfig..." -ForegroundColor Yellow
		Remove-Item -Path $OSConfig -Recurse -Force
	}
    Write-Host "Copying $ScriptDirectory to $OSConfig..." -ForegroundColor Yellow
    Copy-Item -Path $ScriptDirectory -Destination $OSConfig -Recurse
}
#======================================================================================
#	Capture the Environment Variables in the Log
#======================================================================================
Get-Childitem -Path Env:* | Sort-Object Name | Format-Table
#======================================================================================
#	Increase the Screen Buffer size
#======================================================================================
#	This entry allows increased scrolling of the console windows
if (!(Test-Path "HKCU:\Console")) {
	New-Item -Path "HKCU:\Console" -Force | Out-Null
	New-ItemProperty -Path HKCU:\Console ScreenBufferSize -Value 589889656 -PropertyType DWORD -Force | Out-Null
}
#======================================================================================
#	Execute PowerShell files in OSConfig
#======================================================================================
Write-Host ""
$OSConfigChild = Get-ChildItem $OSConfig -Directory
foreach ($item in $OSConfigChild) {
    Write-Host "$($item.FullName)" -ForegroundColor Green
    $OSConfigScripts = Get-ChildItem $item.FullName -Filter *.ps1 -File
	
    foreach ($script in $OSConfigScripts) {
        Write-Host "Executing $($script.FullName)"
		
		#Normal processing
        #Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait
		
		#Hidden Window
        #Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -WindowStyle Hidden
		
		#Minimized Window
        Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -WindowStyle Minimized
		
		#Maximized Window
        #Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -WindowStyle Maximized
		
		#Same Window
		#Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -NoNewWindow
		
    }
    Write-Host ""
}
#======================================================================================





#======================================================================================
#	Enable the following lines for testing as needed
#	Start-Process PowerShell_ISE.exe -Wait
#	Read-Host -Prompt "Press Enter to Continue"
#======================================================================================
Stop-Transcript
#======================================================================================