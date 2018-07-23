$resources = @{
    Name = @(
        'PSDSCResources'
        'DSCR_AutoLogon'
        'AccessControlDSC'
        'ComputerManagementDSC'
        'SqlServerDSC'
        'SecurityPolicyDSC'
        'ReverseDSC'
        'xScheduledTask'
        'xSmbShare'
        'xWinEventLog'
    )
    Force = $true
    Verbose = $true
}

Install-Module @resources
Get-DscResource -Verbose
