Configuration SQLInstall
{
    [CmdletBinding()]
    param
    (
    )

    Import-DscResource -ModuleName SqlServerDsc
    $serviceCredential = Get-Credential -UserName $instance.ServiceAccount -Message ('Enter {0} password.' -f $instance.ServiceAccount)
    $saCredential = Get-Credential -Message 'Enter sa password.'
    Node $AllNodes.NodeName
    {
        WindowsFeature NetFrameword45
        {
            Name = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }

        $server = $Node.SqlServer
        foreach ($instance in $Node.Instances)
        {
            SqlSetup "InstallInstance$($instance.Name)"
            {
                Action = 'Install'
                InstanceName = $instance.Name
                SourcePath = $server.InstallerPath
                ProductKey = $server.ProductKey
                UpdateEnabled = $server.UpdateEnabled
                Features = $server.Features
                InstallSharedDir = $server.SharedFeaturePath
                InstallSharedWOWDir = $server.SharedFeature86Path
                InstanceDir = $instance.RootPath
                SQLSvcAccount = $serviceCredential
                AgtSvcAccount = $serviceCredential
                SQLCollation = $instance.Collation
                SQLSysAdminAccounts = $serviceCredential
                SecurityMode = $instance.SecurityMode
                SAPwd = $saCredential
                InstallSQLDataDir = $instance.DataDir
                SQLUserDBDir = $instance.UserDBDir
                SQLUserDBLogDir = $instance.UserDBLogDir
                SQLTempDBDir = $instance.TempDBDir
                SQLTempDBLogDir = $instance.TempDBLogDir
                SQLBackupDir = $instance.BackupDir
    
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
}
