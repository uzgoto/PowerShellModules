using namespace System.Management.Automation
using namespace System.IO
Set-StrictMode -Version Latest
$ErrorActionPreference = [ActionPreference]::Stop

function Get-ScriptFileNameFullPath
{
    return $MyInvocation.MyCommand.Name
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
    $root = Get-ScriptCurrentPath
    while((Split-Path $root -Leaf) -eq 'Scripting')
    {
        $root = Split-Path $root -Parent
        if([string]::IsNullOrEmpty($root)) { return [string]::Empty }
    }
    return $root
}
function Get-ScriptLogPath
{
    $logName = (Get-Date -Format 'yyyyMMddHHmmss'), (Get-ScriptName), 'log' -join '.\.git'
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