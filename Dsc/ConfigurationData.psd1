@{
    @(
        @{
            NodeName = '*'
        },
        @{
            NodeName = 'dbms.sample.com'
            Role = 'dbms'
            SqlServer = @{
                InstallerPath = 'c:\temp\sqlserver\xxxxxx.exe'
                ProductKey = 'xxxx-xxxx-xxxx-xxxx-xxxx'
                UpdateEnabled = $false
                Features = @(
                    'SQLEngine'
                    'Conn'
                    'SDK'
                )
                SharedFeaturePath = '{0}\Microsoft SQL Server' -f $env:ProgramFiles
                SharedFeature86Path = '{0}\Microsoft SQL Server' -f $env:ProgramW6432
            }
            Instances = @(
                @{
                    Name = 'SampleInstance'
                    RootPath = 'D:\'
                    ServiceAccount = 'SqlServiceAdmin'
                    Collation = 'Japanese_CI_AS'
                    SecurityMode = 'SQL'
                    DataDir = 'D:\'
                    UserDBDir = 'F:\'
                    UserDBLogDir = 'E:\'
                    TempDBDirs = @(
                        'H:\'
                        'I:\'
                        'J:\'
                        'K:\'
                    )
                    TempDBLogDir = 'G:\'
                    BackupDir = 'C:\Backup\'
                }
            )
        }
    )
}