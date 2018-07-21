Import-Module -Name Pester -Scope Local -Force
. (Join-Path $PSScriptRoot 'Logger.ps1')

Describe 'Write-ScriptLog' {
    It "returns Info log." {
        Mock Get-Date -Format 'yyyy/MM/dd HH:mm:ss.ffffff' { return '2019/01/01 12:59:59.012345' }
        Mock Write-Host { return $Object }
        Write-ScriptLog -Messages 'Test' | Should Be '[2019/01/01 12:59:59.012345][Info ] Test'
    }
    It "returns Warn log." {
        Mock Get-Date -Format 'yyyy/MM/dd HH:mm:ss.ffffff' { return '2019/01/01 12:59:59.012345' }
        Mock Write-Host { return $Object }
        Write-ScriptLog -Messages 'WarnTest' -Level Warn | Should Be '[2019/01/01 12:59:59.012345][Warn ] WarnTest'
    }
    It "returns Error log." {
        Mock Get-Date -Format 'yyyy/MM/dd HH:mm:ss.ffffff' { return '2019/01/01 12:59:59.012345' }
        Mock Write-Host { return $Object }
        Write-ScriptLog -Messages 'ErrorTest' -Level Error | Should Be '[2019/01/01 12:59:59.012345][Error] ErrorTest'
    }
    It "returns multiple Info logs." {
        Mock Get-Date -Format 'yyyy/MM/dd HH:mm:ss.ffffff' { return '2019/01/01 12:59:59.012345' }
        Mock Write-Host { return $Object }
        'Test1','Test2','Test3' | Write-ScriptLog |
            Should Be
                '[2019/01/01 12:59:59.012345][Info ] Test1'
                '[2019/01/01 12:59:59.012345][Info ] Test2'
                '[2019/01/01 12:59:59.012345][Info ] Test3'
    }
}
