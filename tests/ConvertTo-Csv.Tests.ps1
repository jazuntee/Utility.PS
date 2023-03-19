[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = ".\src\*.psd1"
)

BeforeDiscovery {
    ## Load Test Helper Functions
    . (Join-Path $PSScriptRoot 'TestCommon.ps1')
}

BeforeAll {
    $CriticalError = $null
    $PSModule = Import-Module $ModulePath -Force -PassThru -ErrorVariable CriticalError
    if ($CriticalError) { throw $CriticalError }

    ## Load Test Helper Functions
    . (Join-Path $PSScriptRoot 'TestCommon.ps1')
}

Describe 'ConvertTo-Csv' -Skip {

    It 'StandardInput' {
        $Input = @(
            New-Module -AsCustomObject { $id = [guid]'51e8ea3e-ca83-46fc-8106-cdc2d9fb5577'; $title = '1st'; Export-ModuleMember -Variable * }
            New-Module -AsCustomObject { $id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4'; $title = '2nd'; Export-ModuleMember -Variable * }
        )
        $Input | Should -BeOfType [object]
        $Output = $Input | ConvertTo-Csv -NoTypeInformation
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [object[]]
        $Output | Should -BeExactly @(
            '"id","title"'
            '"51e8ea3e-ca83-46fc-8106-cdc2d9fb5577","1st"'
            '"352182e6-9ab0-4115-807b-c36c88029fa4","2nd"'
        )
    }

    It 'ArrayInputDefaultDelimiter' {
        $Input = @(
            New-Module -AsCustomObject { $id = [guid]'51e8ea3e-ca83-46fc-8106-cdc2d9fb5577'; $title = '1st'; Export-ModuleMember -Variable * }
            New-Module -AsCustomObject { $id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4'; $title = @('2nd', 'now what?'); Export-ModuleMember -Variable * }
            New-Module -AsCustomObject { $id = [guid]'05e58144-b57f-4803-a465-c7c23f2fb3df'; $title = [System.Collections.Generic.List[string]]@('3rd', 'cool', 'list'); Export-ModuleMember -Variable * }
        )
        $Input | Should -BeOfType [object]
        $Output = $Input | ConvertTo-Csv -NoTypeInformation
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [object[]]
        $Output | Should -BeExactly @(
            '"id","title"'
            '"51e8ea3e-ca83-46fc-8106-cdc2d9fb5577","1st"'
            @'
"352182e6-9ab0-4115-807b-c36c88029fa4","2nd
now what?"
'@
            @'
"05e58144-b57f-4803-a465-c7c23f2fb3df","3rd
cool
list"
'@
        )
    }

    It 'ArrayInputWithDelimiter' {
        $Input = @(
            New-Module -AsCustomObject { $id = [guid]'51e8ea3e-ca83-46fc-8106-cdc2d9fb5577'; $title = @('1st'); Export-ModuleMember -Variable * }
            New-Module -AsCustomObject { $id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4'; $title = @('2nd', 'now what?'); Export-ModuleMember -Variable * }
            New-Module -AsCustomObject { $id = [guid]'05e58144-b57f-4803-a465-c7c23f2fb3df'; $title = [System.Collections.Generic.List[string]]@('3rd', 'cool', 'list'); Export-ModuleMember -Variable * }
        )
        $Input | Should -BeOfType [object]
        $Output = $Input | ConvertTo-Csv -NoTypeInformation -ArrayDelimiter '; '
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [object[]]
        $Output | Should -BeExactly @(
            '"id","title"'
            '"51e8ea3e-ca83-46fc-8106-cdc2d9fb5577","1st"'
            '"352182e6-9ab0-4115-807b-c36c88029fa4","2nd; now what?"'
            '"05e58144-b57f-4803-a465-c7c23f2fb3df","3rd; cool; list"'
        )
    }

}
