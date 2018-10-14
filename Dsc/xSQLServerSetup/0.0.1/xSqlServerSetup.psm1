enum Ensure 
{
    Absent
    Present
}
enum ServiceStartupType
{
    Automatic
    Disabled
    Manual
}
enum QuoteType
{
    Default
    None
    EachItems
}

[DscResource()]
class xSqlServerSetupDsc
{
    Static [string] $DefaultInstallPath = "${env:ProgramFiles}\Microsoft SQL Server"
    Static [string] $DefaultInstall86Path = "${env:ProgramFiles86}\Microsoft SQL Server"

    [DscProperty(Key)]
    [string] $InstanceName

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Mandatory)]
    [string] $PathToSetup

    [DscProperty()]
    [bool] $UpdateEnabled = $true

    [DscProperty()]
    [string] $UpdateSource = 'MU'
    
    [DscProperty()]
    [string[]] $Features = @('SQLEngine, Conn')

    [DscProperty()]
    [bool] $IndicateProgress = $false

    [DscProperty()]
    [string] $InstallSharedDir = [xSqlServerSetupDsc]::DefaultInstallPath

    [DscProperty()]
    [string] $InstallSharedWowDir = [xSqlServerSetupDsc]::DefaultInstall86Path

    [DscProperty()]
    [string] $InstanceDir = $(Join-Path -Path $this.InstanceDir -ChildPath "$($this.InstanceName)\MSSQL")

    [DscProperty()]
    [string] $ProductKey = ''

    [DscProperty()]
    [pscredential] $AgentServiceAccount = 'NT AUTHORITY\LOCAL SERVICE'

    [DscProperty()]
    [ServiceStartupType] $AgentServiceStartupType = [ServiceStartupType]::Manual

    [DscProperty()]
    [ServiceStartupType] $BrowserServiceStartupType = [ServiceStartupType]::Disabled

    [DscProperty()]
    [string] $InstallSqlDataDir = [xSqlServerSetupDsc]::DefaultInstallPath

    [DscProperty()]
    [pscredential] $SaAccount = $null

    [DscProperty()]
    [string] $SqlBackupDir = $(Join-Path -Path [xSqlServerSetupDsc]::DefaultInstallPath -ChildPath "$($this.InstanceName)\MSSQL\Backup")

    [DscProperty()]
    [string] $SqlCollation

    [DscProperty(Mandatory)]
    [pscredential] $SqlServiceAccount

    [DscProperty()]
    [ServiceStartupType] $SqlServiceStartupType = [ServiceStartupType]::Automatic

    [DscProperty(Mandatory)]
    [string[]] $SqlSysAdminAccounts

    [DscProperty()]
    [string[]] $SqlTempDbDirs = @($(Join-Path -Path [xSqlServerSetupDsc]::DefaultInstallPath -ChildPath "$($this.InstanceName)\MSSQL\Data"))

    [DscProperty()]
    [string] $SqlTempDbLogDir = $(Join-Path -Path [xSqlServerSetupDsc]::DefaultInstallPath -ChildPath "$($this.InstanceName)\MSSQL\Data")

    [DscProperty()]
    [ValidateRange(8MB, 1024MB)]
    [int] $SqlTempDbFileSize = 8MB

    [DscProperty()]
    [ValidateRange(0MB, 1024MB)]
    [int] $SqlTempDbFileGrowth = 64MB

    [DscProperty()]
    [ValidateRange(8MB, 1024MB)]
    [int] $SqlTempDbLogFileSize = 8MB

    [DscProperty()]
    [ValidateRange(0MB, 1024MB)]
    [int] $SqlTempDbLogFileGrowth = 64MB

    [DscProperty()]
    [string] $SqlUserDbDir = $(Join-Path -Path [xSqlServerSetupDsc]::DefaultInstallPath -ChildPath "$($this.InstanceName)\MSSQL\Data")

    [DscProperty()]
    [bool] $SqlServiceInstantFileInit = $false

    [DscProperty()]
    [string] $SqlUserDbLogDir = $(Join-Path -Path [xSqlServerSetupDsc]::DefaultInstallPath -ChildPath "$($this.InstanceName)\MSSQL\Data")

    [DscProperty()]
    [ValidateSet(0, 1, 2, 3)]
    [int] $FileStreamLevel = 0

    [DscProperty()]
    [string] $FileStreamShareName = $null

    [DscProperty()]
    [bool] $NamedPipeEnabled = $true

    [DscProperty()]
    [bool] $TcpEnabled = $false

    # Gets the resource's current state.
    [xSqlServerSetupDsc] Get() {
        
        return $this
    }
    
    # Sets the desired state of the resource.
    [void] Set()
    {
        $SetupPath = Join-Path -Path $this.PathToSetup -ChildPath 'setup.exe'

        $SetupParameters = @(
            $this.FormatSetupParameterString('IACCEPTSQLSERVERLICENSETERMS')
            $this.FormatSetupParameterString('Q')
            $this.FormatSetupParameterString('HIDECONSOLE')
            $this.FormatSetupParameterString('ACTION', 'Install')
            $this.FormatSetupParameterString('UPDATEENABLED', $this.UpdateEnabled)
            $this.FormatSetupParameterString('FEATURES', $this.Features, ',', [QuoteType]::None)
            $this.FormatSetupParameterString('INSTALLSHAREDDIR', $this.InstallSharedDir)
            $this.FormatSetupParameterString('INSTALLSHAREDWOWDIR', $this.InstallSharedWowDir)
            $this.FormatSetupParameterString('INSTANCEDIR', $this.InstanceDir)
            $this.FormatSetupParameterString('INSTANCEID', $this.InstanceName)
            $this.FormatSetupParameterString('INSTANCENAME', $this.InstanceName)
            $this.FormatSetupParameterString('PID', $this.ProductKey)
            $this.FormatSetupParameterString('AGTSVCACCOUNT', $this.AgentServiceAccount.UserName)
            $this.FormatSetupParameterString('AGTSVCPASSWORD', $this.AgentServiceAccount.Password)
            $this.FormatSetupParameterString('AGTSVCSTARTUPTYPE', $this.AgentServiceStartupType)
            $this.FormatSetupParameterString('BROWSERSVCSTARTUPTYPE', $this.BrowserServiceStartupType)
            $this.FormatSetupParameterString('INSTALLSQLDATADIR', $this.InstallSqlDataDir)
            $this.FormatSetupParameterString('SQLBACKUPDIR', $this.SqlBackupDir)
            $this.FormatSetupParameterString('SQLCOLLATION', $this.SqlCollation)
            $this.FormatSetupParameterString('SQLSVCACCOUNT', $this.SqlServiceAccount.UserName)
            $this.FormatSetupParameterString('SQLSVCPASSWORD', $this.SqlServiceAccount.Password)
            $this.FormatSetupParameterString('SQLSVCSTARTUPTYPE', $this.SqlServiceStartupType)
            $this.FormatSetupParameterString('SQLSYSADMINACCOUNTS', $this.SqlSysAdminAccounts, ',', [QuoteType]::Default)
            $this.FormatSetupParameterString('SQLTEMPDBDIR', $this.SqlTempDbDirs, ' ', [QuoteType]::EachItems)
            $this.FormatSetupParameterString('SQLTEMPDBLOGDIR', $this.SqlTempDbLogDir)    
            $this.FormatSetupParameterString('SQLTEMPDBFILECOUNT', $this.SqlTempDbDirs.Length)
            $this.FormatSetupParameterString('SQLTEMPDBFILESIZE', $this.SqlTempDbFileSize)
            $this.FormatSetupParameterString('SQLTEMPDBFILEGROWTH', $this.SqlTempDbFileGrowth)
            $this.FormatSetupParameterString('SQLTEMPDBLOGFILESIZE', $this.SqlTempDbLogFileSize)
            $this.FormatSetupParameterString('SQLTEMPDBLOGFILEGROWTH', $this.SqlTempDbLogFileGrowth)
            $this.FormatSetupParameterString('SQLUSERDBDIR', $this.SqlUserDbDir)
            $this.FormatSetupParameterString('SQLSVCINSTANTFILEINIT', $(if ($this.SqlServiceInstantFileInit) { 'True' } else { 'False' }))
            $this.FormatSetupParameterString('SQLUSERDBLOGDIR', $this.SqlUserDbLogDir)
            $this.FormatSetupParameterString('FILESTREAMLEVEL', $this.FileStreamLevel)
            $this.FormatSetupParameterString('NPENABLED', $this.NamedPipeEnabled)
            $this.FormatSetupParameterString('TCPENABLED', $this.TcpEnabled)
        )

        if ($this.UpdateEnabled)
        {
            $SetupParameters += $this.FormatSetupParameterString('UPDATESOURCE', $this.UpdateSource)
        }
        if ($this.IndicateProgress)
        {
            $SetupParameters += $this.FormatSetupParameterString('INDICATEPROGRESS')
        }
        if ($this.SaPassword)
        {
            $SetupParameters += @(
                $this.FormatSetupParameterString('SECURITYMODE', 'SQL')
                $this.FormatSetupParameterString('SAPWD', $this.SaAccount.Password)
            )
        }
        if ($this.FileStreamLevel -ne 0)
        {
            $this.FormatSetupParameterString('FILESTREAMSHARENAME', $this.FileStreamShareName)
        }

        $param = $SetupParameters -join ' '
        Write-Verbose -Message ('Execute setup')
        Write-Verbose -Message ('{0} {1}' -f $SetupPath, $param)
        Start-Process -FilePath $SetupPath -ArgumentList $param -NoNewWindow -Wait -Verbose
    }
    
    # Tests if the resource is in the desired state.
    [bool] Test() {
        $sqlService = Get-Service | Where-Object { $_.Name -eq $('MSSQL${0}' -f $this.InstanceName) }
        if ($this.Ensure -eq [Ensure]::Present)
        {
            return $null -ne $sqlService
        }

        return $null -eq $sqlService
    }

    [string] FormatSetupParameterString([string]$Key, [object]$Value = $null, [string]$Delimiter = ',', [QuoteType]$QuoteType = [QuoteType]::Default)
    {
        $builder = [System.Text.StringBuilder]::new()
        $builder.Append('/')
        $builder.Append($Key)
        if ($null -eq $Value)
        {
            return $builder.ToString()
        }

        $builder.Append('=')
        if ($Value -is [System.Array]) {
            switch ($QuoteType) {
                EachItems { $builder.Append($($Value | ForEach-Object { "$_" }) -join $Delimiter) }
                None { $builder.Append($($Value -join $Delimiter)) }
                Default { $builder.Append("$($Value -join $Delimiter)") }
            }
        } elseif ($Value -is [System.Boolean]) {
            $builder.Append($(if ($Value) { "1" } else { "0" }))
        } else {
            $builder.Append("$Value")
        }

        return $builder.ToString()
    }
}