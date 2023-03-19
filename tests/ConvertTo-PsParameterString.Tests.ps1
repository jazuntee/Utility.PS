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

Describe 'ConvertTo-PsParameterString' {

    class FullOutput {
        [string] $CommandName = 'ConvertTo-PsParameterString'
        [hashtable] $BoundParameters = @{ }
        [type] $ExpectedInputType
        [hashtable[]] $IO = @(
            @{
                Input  = $PSBoundParameters
                Output = ''
            }
            @{
                Input  = @{
                    NamedParameter1 = 'Value1'
                }
                Output = ' -NamedParameter1 ([System.String]''Value1'')'
            }
            @{
                Input  = [ordered]@{
                    NamedParameter1 = 'Value1'
                    NamedParameter2 = 2
                }
                Output = ' -NamedParameter1 ([System.String]''Value1'') -NamedParameter2 ([System.Int32]2)'
            }
        )
    }
    TestGroup FullOutput

    class CompactOutput {
        [string] $CommandName = 'ConvertTo-PsParameterString'
        [hashtable] $BoundParameters = @{
            Compact = $true
        }
        [type] $ExpectedInputType
        [hashtable[]] $IO = @(
            @{
                Input  = $PSBoundParameters
                Output = ''
            }
            @{
                Input  = @{
                    NamedParameter1 = 'Value1'
                }
                Output = ' -NamedParameter1 ''Value1'''
            }
            @{
                Input  = [ordered]@{
                    NamedParameter1 = 'Value1'
                    NamedParameter2 = 2
                }
                Output = ' -NamedParameter1 ''Value1'' -NamedParameter2 2'
            }
        )
    }
    TestGroup CompactOutput

}
