#======================================================================================
#	Author: David Segura
#	Version: 18.8.30
#	https://www.osdeploy.com/
#======================================================================================
#	Backup-GPO will backup OSDeploy GPO's into this directory
#======================================================================================
$DomainGPOs = 'OSDeploy Branding','OSDeploy Policy Win7','OSDeploy Policy Win10'

foreach ($GPO in $DomainGPOs) {
    if (Test-Path "$PSScriptRoot\$GPO") {
        Write-Host "Removing $PSScriptRoot\$GPO" -ForegroundColor Cyan
        Remove-Item -Path "$PSScriptRoot\$GPO" -Recurse -Force
    }

    if (!(Test-Path "$PSScriptRoot\$GPO")) {
        Write-Host "Creating $PSScriptRoot\$GPO" -ForegroundColor Cyan
        New-Item -Path "$PSScriptRoot" -Name $GPO -ItemType Directory
    }

    Write-Host "Backing up $PSScriptRoot\$GPO" -ForegroundColor Yellow
    Backup-Gpo -Name $GPO -Path "$PSScriptRoot\$GPO"
}