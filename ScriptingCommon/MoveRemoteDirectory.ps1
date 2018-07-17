function Move-RemoteDirectory
{
    [CmdletBinding()]
    param
    (
        # 'From' if copy directory from remote to local.
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('From', 'To')]$FromTo,
        [Parameter(Mandatory = $true, Position = 1)]
        [stirng]$RemoteComputerName,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 3)]
        [string]$Destination,
        [Parameter(Mandatory = $false)]
        [switch]$Expand
    )

    $archiveName = $($(Split-Path $Path -Leaf) + '.zip')
    $archivePath = $(Join-Path $(Split-Path $Path -Parent) $archiveName)

    $session = New-PSSession -ComputerName $RemoteComputerName
    # Compress and delete.
    Invoke-Command -Session $session -ScriptBlock {
        Get-ChildItem $using:Path |
            Compress-Archive -DestinationPath $using:archivePath -Force -Verbose -WhatIf
        Remove-Item -Path $Path -Recurse -Force -Verbose -WhatIf
    }

    # Copy archive file.
    Copy-Item -$($FromTo)Session $session -Path $archivePath -Destination $Destination -Force -Verbose -WhatIf

    # Delete copied archive file.
    Invoke-Command -Session $session -ScriptBlock {
        Remove-Item -Path $using:archivePath -Force -Verbose -WhatIf
    }

    # Expand archive if nesessary.
    if($Expand)
    {
        $destinationArchivePath = $(Join-Path $Destination $archiveName)
        Expand-Archive -Path $destinationArchivePath -DestinationPath $Destination -Force -Verbose -WhatIf
    }
}