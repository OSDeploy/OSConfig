#======================================================================================
#	Author: David Segura
#	Version: 18.9.4
#	https://www.osdeploy.com/
#======================================================================================
#   Requirements
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
#   Remove Existing OSConfig
#======================================================================================
if ($ScriptDirectory -ne $OSConfig) {
	if (Test-Path $OSConfig) {
		Write-Host "Removing existing $OSConfig..." -ForegroundColor Yellow
		Remove-Item -Path $OSConfig -Recurse -Force
    }
}
#======================================================================================
#   Check for Provisioning Package
#====================================================================================== 
if ($ScriptDirectory -like "*ProvisioningPkgTmp*") {
    Write-Host "OSConfig is running from a Provisioning Package ..." -ForegroundColor Yellow
    #======================================================================================
    #   Expand Provisioning Package
    #====================================================================================== 
    if (Test-Path "$ScriptDirectory\OSConfig.cab") {
        if (!(Test-Path $OSConfig)) {New-Item -ItemType Directory -Path $OSConfig}
        Write-Host "Expanding '$ScriptDirectory\OSConfig.cab' to '$OSConfig'..." -ForegroundColor Yellow
        expand "$ScriptDirectory\OSConfig.cab" $OSConfig -F:*
    }
} else {
    #======================================================================================
    #   Copy Files
    #====================================================================================== 
    if ($ScriptDirectory -ne $OSConfig) {
        Write-Host "Copying '$ScriptDirectory' to '$OSConfig'..." -ForegroundColor Yellow
        Copy-Item -Path $ScriptDirectory -Destination $OSConfig -Recurse
    }
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
        #======================================================================================
        #	Execute Provisioning Package Minimized
        #   Change WindowStyle to Hidden when testing is complete
        #======================================================================================
        if (Test-Path "$ScriptDirectory\OSConfig.cab") {
            Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -WindowStyle Minimized
        #======================================================================================
        #	Execute Standard PowerShell Script
        #   Choose proper WindowStyle
        #======================================================================================
        } else {
            #Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait
            #Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -NoNewWindow
            Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -WindowStyle Minimized
            #Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -WindowStyle Maximized
            #Start-Process PowerShell.exe -ArgumentList "-file `"$($script.FullName)`"" -Wait -WindowStyle Hidden
        }
    }
    Write-Host ""
}
#======================================================================================
#	Enable the following lines for testing as needed
#	Start-Process PowerShell_ISE.exe -Wait
#	Read-Host -Prompt "Press Enter to Continue"
#======================================================================================
Stop-Transcript
#======================================================================================