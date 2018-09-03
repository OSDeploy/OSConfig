#======================================================================================
#	Author: David Segura
#	Version: 18.9.3
#	https://www.osdeploy.com/
#======================================================================================
#	Requirements
#======================================================================================
$RequiresOS = ""
$RequiresOSReleaseId = ""
$RequiresOSBuild = ""
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
#	System Information
#======================================================================================
$SystemManufacturer = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\SystemInformation).SystemManufacturer.Trim()
$SystemProductName = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\SystemInformation).SystemProductName.Trim()
$BIOSVersion = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\SystemInformation).BIOSVersion.Trim()
$BIOSReleaseDate = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\SystemInformation).BIOSReleaseDate.Trim()
if ($SystemManufacturer -like "*Dell*") {$SystemManufacturer = "Dell"}
Write-Host "SystemManufacturer: $SystemManufacturer" -ForegroundColor Cyan
Write-Host "SystemProductName: $SystemProductName" -ForegroundColor Cyan
Write-Host "BIOSVersion: $BIOSVersion" -ForegroundColor Cyan
Write-Host "BIOSReleaseDate: $BIOSReleaseDate" -ForegroundColor Cyan
Write-Host ""
#======================================================================================
#	Windows Information
#======================================================================================
if (Test-Path -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion") {
	$ProductName = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").ProductName.Trim()
	$EditionID = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").EditionID.Trim()
	if ($ProductName -like "*Windows 10*") {
		$CompositionEditionID = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").CompositionEditionID.Trim()
		$ReleaseId = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").ReleaseId.Trim()
	}
	$CurrentBuild = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").CurrentBuild.Trim()
	$CurrentBuildNumber = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber.Trim()
	$CurrentVersion = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").CurrentVersion.Trim()
	$InstallationType = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").InstallationType.Trim()
	$RegisteredOwner = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").RegisteredOwner.Trim()
	$RegisteredOrganization = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").RegisteredOrganization.Trim()
} else {
	$ProductName = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").ProductName.Trim()
	$EditionID = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").EditionID.Trim()
	if ($ProductName -like "*Windows 10*") {
		$CompositionEditionID = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").CompositionEditionID.Trim()
		$ReleaseId = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").ReleaseId.Trim()
	}
	$CurrentBuild = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").CurrentBuild.Trim()
	$CurrentBuildNumber = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").CurrentBuildNumber.Trim()
	$CurrentVersion = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").CurrentVersion.Trim()
	$InstallationType = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").InstallationType.Trim()
	$RegisteredOwner = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").RegisteredOwner.Trim()
	$RegisteredOrganization = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion").RegisteredOrganization.Trim()
}

if ($env:PROCESSOR_ARCHITECTURE -like "*64") {
	#64-bit
	$Arch = "x64"
	$Bits = "64-bit"
} else {
	#32-bit
	$Arch = "x86"
	$Bits = "32-bit"
}

if ($env:SystemDrive -eq "X:") {
	$IsWinPE = "True"
	Write-Host "System is running in WinPE" -ForegroundColor Green
} else {
	$IsWinPE = "False"
}

Write-Host "ProductName: $ProductName" -ForegroundColor Cyan
Write-Host "Architecture: $Arch" -ForegroundColor Cyan
Write-Host "IsWinPE: $IsWinPE" -ForegroundColor Cyan
Write-Host "EditionID: $EditionID" -ForegroundColor Cyan
Write-Host "CompositionEditionID: $CompositionEditionID" -ForegroundColor Cyan
Write-Host "ReleaseId: $ReleaseId" -ForegroundColor Cyan
Write-Host "CurrentBuild: $CurrentBuild" -ForegroundColor Cyan
Write-Host "CurrentBuildNumber: $CurrentBuildNumber" -ForegroundColor Cyan
Write-Host "CurrentVersion: $CurrentVersion" -ForegroundColor Cyan
Write-Host "InstallationType: $InstallationType" -ForegroundColor Cyan
Write-Host "RegisteredOwner: $RegisteredOwner" -ForegroundColor Cyan
Write-Host "RegisteredOrganization: $RegisteredOrganization" -ForegroundColor Cyan
Write-Host ""
#======================================================================================
#	Filter Requirements
#======================================================================================
if (!(Test-Path variable:\RequiresOS)) {
	Write-Host "OS Build requirement does not exist"
} else {
	if ($RequiresOS -eq "") {
		Write-Host "Operating System requirement is empty"
	} elseif ($ProductName -like "*$RequiresOS*") {
		Write-Host "Operating System requirement PASSED" -ForegroundColor Green
	} else {
		Write-Host "Operating System requirement FAILED ... Exiting" -ForegroundColor Red
		Stop-Transcript
		Return
	}
}

if (!(Test-Path variable:\RequiresOSReleaseId)) {
	Write-Host "OS Release Id requirement does not exist"
} else {
	if ($RequiresOSReleaseId -eq "") {
		Write-Host "OS Release Id requirement is empty"
	} elseif ($ReleaseId -eq $RequiresOSReleaseId) {
		Write-Host "OS Release Id requirement PASSED" -ForegroundColor Green
	} else {
		Write-Host "OS Release Id requirement FAILED ... Exiting" -ForegroundColor Red
		Stop-Transcript
		Return
	}
}

if (!(Test-Path variable:\RequiresOSBuild)) {
	Write-Host "OS Build requirement does not exist"
} else {
	if ($RequiresOSBuild -eq "") {
		Write-Host "OS Build requirement is empty"
	} elseif ($CurrentBuild -eq $RequiresOSBuild) {
		Write-Host "OS Build requirement PASSED" -ForegroundColor Green
	} else {
		Write-Host "OS Build requirement FAILED" -ForegroundColor Red
	}
}
Write-Host ""
#======================================================================================
# Set AppAssoc.xml
#======================================================================================
$AppAssoc = "$OSConfig\Apps\AppAssoc.xml"

if ($ProductName -like "*Windows 10*") {$AppAssocOS = "$OSConfig\Apps\AppAssocWin10.xml"}
if ($ProductName -like "*Server 2016*") {$AppAssocOS = "$OSConfig\Apps\AppAssocServer2016.xml"}

if (Test-Path $AppAssocOS) {Copy-Item $AppAssocOS $AppAssoc -Force}

if (Test-Path $AppAssoc) {
	Write-Host "Importing Default App Association file $AppAssoc"
	dism /online /Import-DefaultAppAssociations:$AppAssoc
}
#======================================================================================
#	Enable the following lines for testing as needed
#	Start-Process PowerShell_ISE.exe -Wait
#	Read-Host -Prompt "Press Enter to Continue"
#======================================================================================
Stop-Transcript
#======================================================================================