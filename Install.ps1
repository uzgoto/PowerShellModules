using namespace System.Management.Automation
Set-StrictMode -Version Latest
$ErrorActionPreference = [ActionPreference]::Stop

function Install-LocalModules
{
    [CmdletBinding()]
    param()

    $ModulePath = "$env:ProgramFiles\WindowsPowerShell\Modules"

    $modulePath =
        Get-ChildItem -LiteralPath $MyInvocation.PSScriptRoot -Directory  |
        Get-modulePath

    Write-Verbose "Create $ModulePath directory if absent."
    if(-not(Test-Path -Path $ModulePath))
    {
        Write-Warning "$ModulePath directory is not found. create directory."
        New-Item -Path $ModulePath -ItemType directory -Force -Verbose
    }

    try {
        $modulePath | ForEach-Object {
            $moduleName = Split-Path $_ -Leaf
            Write-Verbose "Remove module $moduleName directory if present."
            $newModulePath = Join-Path $ModulePath $moduleName
            if(Test-Path -Path $newModulePath) {
                Write-Warning "Module directory $moduleName is already existed. Remove this."
                Remove-Item -Path $newModulePath -Recurse -Force -Verbose
            }
            # Copy Module
            Write-Host "Copy module $moduleName to module path." -ForegroundColor Cyan
            Copy-Item -Path $_ -Destination $ModulePath -Recurse -Force -Verbose
            # Import Module
            Write-Host "Importe module $moduleName" -ForegroundColor Cyan
            Import-Module -Name $moduleName -Verbose
        }
    }
    catch {
        exit 1
    }
    exit 0
}
filter Get-modulePath
{
    [OutputType([string[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [string[]]$Path
    )

    $psm1Path = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Extension -eq ".psm1" }
    if ($null -eq $psm1Path)
    {
        Write-Warning "Module file (.psm1) is not found in $Path!!"
    }
    else
    {
        $Path
    }
}
Install-LocalModules