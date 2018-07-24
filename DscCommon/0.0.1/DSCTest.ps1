Configuration Test
{
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Role = 'Dsc'
    )
    Import-DscResource -ModuleName xSmbShare

    Node localhost
    {
        xSmbShare share1
        {
            Name = 'Share1'
            Ensure = 'Present'
            ReadAccess = 'hoge'
            Path = 'C:/test'
        }
    }
}
. (Join-Path $MyInvocation.PSScriptRoot 'ConfigurationData.psd1')
Test -Output test -ConfigurationData $configurationData
Start-DscConfiguration -Path test -Wait -Verbose
