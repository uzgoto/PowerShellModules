Configuration SQLInstall
{
    [CmdletBinding()]
    param
    (
    )

    Import-DscResource -ModuleName SqlServerDsc
    $ProductName = 'Microsoft SQL Server'
    $ProgramFilesPath = @{
        x64 = Join-Path -Path $env:ProgramFiles -ChildPath $ProductName
        x86 = JOin-Path -Path $env:ProgramW6432 -ChildPath $ProductName
    }

    Node $AllNodes.NodeName
    {
        WindowsFeature NetFrameword45
        {
            Name = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }

        SqlSetup "InstallInstance$($Node.InstanceName)"
        {
            Action = 'Install'
            InstanceName = $Node.InstanceName
            SourcePath = $Node.SourcePath
            ProductKey = $Node.ProductKey
            UpdateEnabled = 'False'
            Features = 'SQLEngine,Conn,SDK'
            InstallSharedDir = if ($Node.SharedFeaturePath) { $Node.SharedFeaturePath } else { $ProgramFilesPath.x64 }
            InstallSharedWOWDir = if($Node.SharedFeature86Path) { $Node.SharedFeature86Path } else { $ProgramFilesPath.x86 }
            InstanceDir = $Node.InstanceRootPath
            SQLSvcAccount = Get-Credential -UserName $Node.MSSQLServiceAccount -Message ('Enter {0} password.' -f $Node.MSSQLServiceAccount)
            AgtSvcAccount = Get-Credential -UserName $Node.SQLAgentServiceAccount -Message ('Enter {0} password.' -f $Node.SQLAgentServiceAccount)
            SQLCollation = $Node.Collation
            SQLSysAdminAccounts = $Node.SysAdminAccounts
            SecurityMode = 'SQL'
            SAPwd = Get-Credential -Message 'Enter sa password.'
            InstallSQLDataDir = $Node.DataDir
            SQLUserDBDir = $Node.UserDbDir
            SQLUserDBLogDir = $Node.UserDbLogDit
            SQLTempDBDir = $Node.TempDbDirs -join ' '
            SQLTempDBLogDir = $Node.TempDbLogDir
            SQLBackupDir = $Node.BackupDir

            DependsOn = '[WindowsFeature]NetFramework45'
        }

        foreach ($service in $Node.SqlService)
        {
            SqlServiceAccount "ServiceAccount$($service.Type)Of$($Node.InstanceName)"
            {
                ServerName = $Node.ServerName
                InstanceName = $Node.InstanceName
                ServiceType = $service.Type
                ServiceAccount = $serviceCredential
                RestartService = $true
                Force = $true
            }
        }

        foreach ($option in $Node.Option)
        {
            # See https://docs.microsoft.com/ja-jp/sql/database-engine/configure-windows/server-configuration-options-sql-server?view=sql-server-2016
            SqlServerConfiguration "ServerConfig$($option.Name)Of$($Node.InstanceName)"
            {
                ServerName = $Node.ServerName
                InstanceName = $Node.InstanceName
                OptionName = $option.Name
                OptionValue = $option.Value
                RestartService = $false
            }
        }

        SqlServerMaxDop "ServerMaxDopOf$($Node.InstanceName)"
        {
            Ensure = 'Present'
            ServerName = $Node.ServerName
            InstanceName = $Node.InstanceName
            DynamicAlloc = $false
            ProcessOnlyOnActiveNode = $false
            MaxDop = $Node.MaxDop
        }
        
        SqlServerMemory "ServerMemoryOf$($Node.InstanceName)"
        {
            Ensure = 'Present'
            ServerName = $Node.ServerName
            InstanceName = $Node.InstanceName
            DynamicAlloc = $false
            ProcessOnlyOnActiveNode = $false
            MinMemory = $Node.MinimumMemory
            MaxMemory = $Node.MaximumMemory
        }

        SqlServerNetwork "ServerNetworkTcpOf$($Node.InstanceName)"
        {
            ServerName = $Node.ServerName
            InstanceName = $Node.InstanceName
            ProtocolName = $Node.Network.Tcp.Name
            IsEnabled = $Node.Network.Tcp.IsEnabled
            TcpDynamicPort = [string]::IsNullOrEmpty($Node.Network.Tcp.Port)
            TcpPort = $Node.Network.Tcp.Port
        }

        foreach ($database in $Node.Server.Instance.Database)
        {
            if ($database.Type -ne 'System')
            {
                SqlDatabase "Database$($database.Name)Of$($Node.InstanceName)"
                {
                    Ensure = 'Present'
                    ServerName = $Node.ServerName
                    InstanceName = $Node.InstanceName
                    Name = $database.Name
                    Collation = $database.Collation
                }
            }

            SqlDatabasePermission "Database$($database.Name)Of$($Node.InstanceName)"
            {
                Ensure = 'Present'
                ServerName = $Node.ServerName
                InstanceName = $Node.InstanceName
                Database = $database.Name
                Name = $database.Permission.User
                PermissionState = 'Grant'
                # See https://docs.microsoft.com/ja-jp/sql/relational-databases/security/permissions-database-engine?view=sql-server-2016
                Permissions = $database.Permission
            }

            SqlDatabaseRecoveryModel "Database$($database.Name)Of$($Node.InstanceName)"
            {
                ServerName = $Node.ServerName
                InstanceName = $Node.InstanceName
                Name = $database.Name
                RecoveryModel = $database.RecoveryModel
            }
        }
    }
}