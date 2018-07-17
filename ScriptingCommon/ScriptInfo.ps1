using namespace System.Management.Automation
using namespace System.IO
Set-StrictMode -Version Latest
$ErrorActionPreference = [ActionPreference]::Stop

function Get-ScriptFileNameFullPath
{
    return $Script:MyInvocation.MyCommand.Name
}
function Get-ScriptName
{
    $scriptPath = Get-ScriptFileNameFullPath
    return [Path]::GetFileNameWithoutExtension($scriptPath)
}
function Get-ScriptCurrentPath
{
    $scriptPath = Get-ScriptFileNameFullPath
    return Split-Path $scriptPath -Parent
}
function Get-ScriptRootPath
{
    $current = Get-ScriptCurrentPath
    while((Split-Path $current -Leaf) -ne 'Scripting')
    {
        $current = Split-Path $current -Parent
        if([string]::IsNullOrEmpty($current)) { return [string]::Empty }
    }
    return $current
}
function Get-ScriptLogPath
{
    $logName = (Get-Date -Format 'yyyyMMddHHmmss'), (Get-ScriptName), 'log' -join '.'
    $logDirectory = Join-Path (Get-ScriptRootPath) 'Logs'
    return Join-Path $logDirectory $logName
}
function Get-CallTimeLogText
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Start', 'End')]$State
    )
    return "=== {0} {1} ===" -f (Get-Date -Format 'yyyy/MM/dd HH:mm:ss.ffffff'), $State
}

# $functionToExport = @(
#     'Get-ScriptName',
#     'Get-ScriptCurrentPath',
#     'Get-ScriptRootPath',
#     'Get-ScriptLogPath',
#     'Get-CallTimeLogText'
# )
# Export-ModuleMember -Function $functionToExport -Verbose