Import-Module -Name Pester -Scope Local -Force -Verbose
. '.\ScriptingCommon\ScriptInfo.ps1'

Describe 'Get-ScriptName' {
    It "returns script name without extension." {
        Mock Get-ScriptFileNameFullPath { return 'C:\hoge\fuga\piyo.ps1' }
        Get-ScriptName | Should Be 'piyo'
    }
}
Describe 'Get-ScriptCurrentPath' {
    It "returns script file parent path" {
        Mock Get-ScriptFileNameFullPath { return 'C:\hoge\fuga\piyo.ps1' }
        Get-ScriptCurrentPath | Should Be 'C:\hoge\fuga'
    }
}
Describe 'Get-ScriptRootPath' {
    It "contains 'Scripting' directory, returns Scripting path" {
        Mock Get-ScriptFileNameFullPath { return 'C:\hoge\Scripting\fuga\piyo.ps1' }
        Get-ScriptRootPath | Should Be 'C:\hoge\Scripting'
    }
    It "not contains 'Scripting' directory, returns empty string." {
        Mock Get-ScriptFileNameFullPath { return 'C:\hoge\fuga\piyo.ps1'}
        Get-ScriptRootPath | Should Be ""
    }
}
Describe 'Get-ScriptLogPath' {
    It "returns log file under Logs directory under script root" {
        Mock Get-ScriptFileNameFullPath { return 'C:\hoge\Scripting\fuga\piyo.ps1' }
        Mock Get-Date -Format 'yyyyMMddHHmmss' { return '20200101235959' }
        Get-ScriptLogPath | Should Be 'C:\hoge\Scripting\Logs\20200101235959.piyo.log'
    }
}
Describe 'Get-CallTimeLogText' {
    It "given 'Start', returns start log text." {
        Mock Get-Date -Format 'yyyy/MM/dd HH:mm:ss.ffffff' { return '2020/01/01 23:59:59.012345' }
        Get-CallTimeLogText -State Start | Should Be '=== 2020/01/01 23:59:59.012345 Start ==='
    }
    It "given 'End', returns end log text." {
        Mock Get-Date -Format 'yyyy/MM/dd HH:mm:ss.ffffff' { return '2020/01/01 23:59:59.012345' }
        Get-CallTimeLogText -State End | Should Be '=== 2020/01/01 23:59:59.012345 End ==='
    }
}