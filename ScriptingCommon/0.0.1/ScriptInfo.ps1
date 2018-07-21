using namespace System.IO
Set-StrictMode -Version Latest

function Get-ScriptFileNameFullPath
{
    return $Script:MyInvocation.PSCommandPath
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
