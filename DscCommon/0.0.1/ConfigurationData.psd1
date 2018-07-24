$configurationData = @{
    AllNodes = @(
        @{
            NodeName = '*'
        },
        @{
            NodeName = localhost
            Role = Management
            Service = 'WinRM'
        },
        @{
            NodeName = xxx.xxx.xxx.xxx
            Role = Dbms
            Service = 'MSSQL$MSSQLSERVER', 'SQLAgent$MSSQLSERVER'
        }
    )
}