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
#	Main
#======================================================================================
#	Gather Registry XML
#======================================================================================
$GPOPreferences = Get-ChildItem "$ScriptDirectory\ImportXML" *.xml -Recurse
if ($ProductName -like "*Windows 7*") {$GPOPreferences = $GPOPreferences | Where-Object {$_.FullName -NotLike "*Win10*"}}
if ($ProductName -like "*Windows 10*") {$GPOPreferences = $GPOPreferences | Where-Object {$_.FullName -NotLike "*Win7*"}}
if ($ProductName -like "*Windows Server") {$GPOPreferences = $GPOPreferences | Where-Object {$_.FullName -NotLike "*Win7*" -and $_.FullName -NotLike "*Win10*"}}
#======================================================================================
#	Import Registry XML
#======================================================================================
if (!($GPOPreferences)) {
	Write-Host "Could not find any compatible Registry XML files"
} else {
	#======================================================================================
	# Load Registry Hives
	#======================================================================================
	if (Test-Path "C:\Users\Default\NTUser.dat") {
		Write-Host "Loading Default User NTUser.dat" -ForegroundColor Cyan
		Start-Process reg -ArgumentList "load HKLM\MountedDefaultUser C:\Users\Default\NTUser.dat" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
	}
	if (Test-Path "C:\Users\Administrator\NTUser.dat") {
		Write-Host "Loading Administrator NTUser.dat" -ForegroundColor Cyan
		Start-Process reg -ArgumentList "load HKLM\MountedAdministrator C:\Users\Administrator\NTUser.dat" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
	}
	#======================================================================================
	#	Process Registry XML
	#======================================================================================
	foreach ($RegistryXml in $GPOPreferences) {
		$RegistrySettings = @()
		$RegistrySettings
		Write-Host "Processing $($RegistryXml.FullName)" -ForegroundColor Yellow
		Write-Host ""

		[xml]$XmlDocument = Get-Content -Path $RegistryXml.FullName
		$nodes = $XmlDocument.SelectNodes("//*[@action]")

		foreach ($node in $nodes) {
			$NodeAction = $node.attributes['action'].value
			$NodeDefault = $node.attributes['default'].value
			$NodeHive = $node.attributes['hive'].value
			$NodeKey = $node.attributes['key'].value
			$NodeName = $node.attributes['name'].value
			$NodeType = $node.attributes['type'].value
			$NodeValue = $node.attributes['value'].value

			$obj = new-object psobject -prop @{Action=$NodeAction;Default=$NodeDefault;Hive=$NodeHive;Key=$NodeKey;Name=$NodeName;Type=$NodeType;Value=$NodeValue}
			$RegistrySettings += $obj
		}

		foreach ($RegEntry in $RegistrySettings) {
			$RegAction = $RegEntry.Action
			$RegDefault = $RegEntry.Default
			$RegHive = $RegEntry.Hive
			#$RegHive = $RegHive -replace 'HKEY_LOCAL_MACHINE','HKLM:' -replace 'HKEY_CURRENT_USER','HKCU:' -replace 'HKEY_USERS','HKU:'
			$RegKey = $RegEntry.Key
			$RegName = $RegEntry.Name
			$RegType = $RegEntry.Type
			$RegType = $RegType -replace 'REG_SZ','String'
			$RegType = $RegType -replace 'REG_DWORD','DWord'
			$RegType = $RegType -replace 'REG_QWORD','QWord'
			$RegType = $RegType -replace 'REG_MULTI_SZ','MultiString'
			$RegType = $RegType -replace 'REG_EXPAND_SZ','ExpandString'
			$RegType = $RegType -replace 'REG_BINARY','Binary'
			$RegValue = $RegEntry.Value

			if ($RegType -eq 'Binary') {
				$RegValue = $RegValue -replace '(..(?!$))','$1,'
				$RegValue = $RegValue.Split(',') | ForEach-Object {"0x$_"}
			}

			$RegPath = "Registry::$RegHive\$RegKey"
			$RegPathAdmin = "Registry::HKEY_LOCAL_MACHINE\MountedAdministrator\$RegKey"
			$RegPathDUser = "Registry::HKEY_LOCAL_MACHINE\MountedDefaultUser\$RegKey"

			if ($RegAction -eq "D") {
				if ($RegDefault -eq '0' -and $RegName -eq '' -and $RegValue -eq '') {
					Write-Host "Remove-Item -LiteralPath $RegPath" -ForegroundColor Red
					Remove-Item -LiteralPath $RegPath -Force
				} elseif ($RegDefault -eq '1') {
					Write-Host "Remove-ItemProperty -LiteralPath $RegPath" -ForegroundColor Red
					Write-Host "-Name '(Default)'"
					Remove-ItemProperty -LiteralPath $RegPath -Name '(Default)' -Force
				} else {
					Write-Host "Remove-ItemProperty -LiteralPath $RegPath" -ForegroundColor Red
					Write-Host "-Name $RegName"
					Remove-ItemProperty -LiteralPath $RegPath -Name $RegName -Force
				}
				
				if ($RegHive -eq 'HKEY_CURRENT_USER'){
					if (Test-Path -Path "HKLM:\MountedAdministrator") {
						Write-Host "Remove-ItemProperty -LiteralPath $RegPathAdmin" -ForegroundColor Red
						if ($RegDefault -eq '0' -and $RegName -eq '' -and $RegValue -eq '') {
							Remove-ItemProperty -LiteralPath $RegPathAdmin -Force
						} elseif ($RegDefault -eq '1') {
							Write-Host "-Name '(Default)'"
							Remove-ItemProperty -LiteralPath $RegPathAdmin -Name '(Default)' -Force
						} else {
							Write-Host "-Name $RegName"
							Remove-ItemProperty -LiteralPath $RegPathAdmin -Name $RegName -Force
						}
					}
					if (Test-Path -Path "HKLM:\MountedDefaultUser") {
						Write-Host "Remove-ItemProperty -LiteralPath $RegPathDUser" -ForegroundColor Red
						if ($RegDefault -eq '0' -and $RegName -eq '' -and $RegValue -eq '') {
							Remove-ItemProperty -LiteralPath $RegPathDUser -Force
						} elseif ($RegDefault -eq '1') {
							Write-Host "-Name '(Default)'"
							Remove-ItemProperty -LiteralPath $RegPathDUser -Name '(Default)' -Force
						} else {
							Write-Host "-Name $RegName"
							Remove-ItemProperty -LiteralPath $RegPathDUser -Name $RegName -Force
						}
					}
				}
			} else {
				if (!(Test-Path -LiteralPath $RegPath)) {
					Write-Host "New-Item -Path $RegPath" -ForegroundColor Green
					New-Item -Path $RegPath -Force | Out-Null
				}
				if ($RegHive -eq 'HKEY_CURRENT_USER'){
					if (Test-Path -Path "HKLM:\MountedAdministrator") {
						if (!(Test-Path -LiteralPath $RegPathAdmin)) {
							Write-Host "New-Item -Path $RegPathAdmin" -ForegroundColor Green
							New-Item -Path $RegPathAdmin -Force | Out-Null
						}
					}
					if (Test-Path -Path "HKLM:\MountedDefaultUser") {
						if (!(Test-Path -LiteralPath $RegPathDUser)) {
							Write-Host "New-Item -Path $RegPathDUser" -ForegroundColor Green
							New-Item -Path $RegPathDUser -Force | Out-Null
						}
					}
				}
				if ($RegDefault -eq '1') {$RegName = '(Default)'}
				if (!($RegType -eq '')) {
					Write-Host "New-ItemProperty -LiteralPath $RegPath" -ForegroundColor Green
					Write-Host "-Name $RegName -PropertyType $RegType -Value $RegValue"
					New-ItemProperty -LiteralPath $RegPath -Name $RegName -PropertyType $RegType -Value $RegValue -Force | Out-Null
					if ($RegHive -eq 'HKEY_CURRENT_USER'){
						if (Test-Path -Path "HKLM:\MountedAdministrator") {
							Write-Host "New-ItemProperty -LiteralPath $RegPathAdmin" -ForegroundColor Green
							Write-Host "-Name $RegName -PropertyType $RegType -Value $RegValue"
							New-ItemProperty -LiteralPath $RegPathAdmin -Name $RegName -PropertyType $RegType -Value $RegValue -Force | Out-Null
						}
						if (Test-Path -Path "HKLM:\MountedDefaultUser") {
							Write-Host "New-ItemProperty -LiteralPath $RegPathDUser" -ForegroundColor Green
							Write-Host "-Name $RegName -PropertyType $RegType -Value $RegValue"
							New-ItemProperty -LiteralPath $RegPathDUser -Name $RegName -PropertyType $RegType -Value $RegValue -Force | Out-Null
						}
					}
				}
			}
		}
	}
	Remove-Item Variable:RegistrySettings
	#======================================================================================
	#	Unload Registry Hives
	#======================================================================================
	if (Test-Path -Path "HKLM:\MountedDefaultUser") {
		Start-Process reg -ArgumentList "unload HKLM\MountedDefaultUser" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
	}
	if (Test-Path -Path "HKLM:\MountedAdministrator") {
		Start-Process reg -ArgumentList "unload HKLM\MountedAdministrator" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
	}
}
#======================================================================================





#======================================================================================
#	Enable the following lines for testing as needed
#	Start-Process PowerShell_ISE.exe -Wait
#	Read-Host -Prompt "Press Enter to Continue"
#======================================================================================
Stop-Transcript
#======================================================================================