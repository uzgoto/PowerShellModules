Set-StrictMode -Version Latest
function Write-ScriptLog
{
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]$Messages,
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet('Info', 'Warn', 'Error')]
        [string]$Level = 'Info'
    )

    $now = (Get-Date -Format 'yyyy/MM/dd HH:mm:ss.ffffff')
    $logLevel = $Level.PadRight(5)
    $color = switch ($Level) {
        Info { 'Green' }
        Warn { 'Yellow' }
        Error { 'Red' }
        Default { 'White' }
    }
    foreach($message in $Messages)
    {
        Write-Host "[$now][$logLevel] $message" -ForegroundColor $color
    }
}
