using namespace System.Management.Automation
using namespace System.Security.Principal

function Main
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$ModulePath
    )
    Set-StrictMode -Version Latest
    $ErrorActionPreference = [ActionPreference]::Stop

    # This script is placed at root directory.
    $path = (Split-Path $PSCommandPath -Parent)
    $modulePaths = Get-ChildItem $path -Directory  | Get-ModulePaths

    Write-Verbose "Checking Module Root Path $ModulePath is exist not not."
    if(!(Test-Path -Path $ModulePath))
    {
        Write-Warning "$ModulePath not found. creating module path."
        New-Item -Path $ModulePath -ItemType directory -Force -Verbose
    }

    try {
        $modulePaths | ForEach-Object {
            Write-Verbose "Checking Module Path $_ is exist not not."
            if(Test-Path -Path $_) {
                Write-Warning "$_ is already existed. Skip creating module directory."
                Remove-Item -Path $_ -Recurse -Force -Verbose -WhatIf
            }
            # Copy Module
            $moduleName = (Split-Path $_ -Leaf)
            Write-Host "Copying module $moduleName to Module path $_." -ForegroundColor Cyan
            Copy-Item -Path $path -Destination $_ -Recurse -Force -Verbose -WhatIf
            # Import Module
            Write-Host "Importing Module $moduleName" -ForegroundColor Cyan
            Import-Module -Name $moduleName -Verbose -WhatIf
        }
    }
    catch {
        exit 1
    }
    exit 0
}
filter Get-ModulePaths
{
    [OutputType([string[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [string[]]$Paths
    )
    $Paths | ForEach-Object
    {
        if(Test-Path $_)
        {
            $modulePath = Get-ChildItem $_ | Where-Object { $_.Extension -eq ".psm1" }
            if ($null -eq $modulePath)
            {
                Write-Warning "Module file (.psm1) is not found in {0}!!" -f $_
            }
            else
            {
                $(Split-Path $modulePath -Parent)
            }
        }
        else
        {
            Write-Warning "Path ({0}) is not exist!!" -f $_
        }
    }
}
function Test-RunAs
{
    $user = [WindowsIdentity]::GetCurrent()
    return (New-Object WindowsPrincipal $user).IsInRole([WindowsBuiltinRole]::Administrator)
}


if (!(Test-RunAs))
{
    Write-Host -Object "管理者で起動してください" -ForegroundColor Red
    exit 1
}
$ModulePath = "$env:ProgramFiles\WindowsPowerShell\Modules"
Main -Modulepath $ModulePath
