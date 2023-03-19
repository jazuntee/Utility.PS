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

Describe 'ConvertTo-Dictionary' {

    Context 'Hashtable Input' {
        class HashtableInput {
            [string] $CommandName = 'ConvertTo-Dictionary'
            [hashtable] $BoundParameters = @{
                ValueType = [string]
            }
            [type] $ExpectedInputType = [hashtable]
            [hashtable[]] $IO = @(
                @{
                    Input  = @{ KeyName = 'StringValue' }
                    Output = (Invoke-Command { $D = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'; $D.Add('KeyName', 'StringValue'); $D })
                }
                @{
                    Input  = @{ AnotherKey = 'AnotherStringValue' }
                    Output = (Invoke-Command { $D = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'; $D.Add('AnotherKey', 'AnotherStringValue'); $D })
                }
            )
        }
        TestGroup HashtableInput
    }

}
