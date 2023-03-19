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

Describe 'Select-PsBoundParameters' {

    class ExcludeCommand {
        [string] $CommandName = 'Select-PsBoundParameters'
        [hashtable] $BoundParameters = @{
            CommandName = 'Select-PsBoundParameters'
        }
        [type] $ExpectedInputType = [hashtable]
        [hashtable[]] $IO = @(
            @{
                Input  = @{
                    ExcludeParameters = 'Valid'
                    NotAParameter     = 'Remove'
                }
                Output = @{
                    ExcludeParameters = 'Valid'
                }
            }
        )
    }
    TestGroup ExcludeCommand

    class ExcludeParameters {
        [string] $CommandName = 'Select-PsBoundParameters'
        [hashtable] $BoundParameters = @{
            ExcludeParameters = 'Verbose', 'NotAParameter'
        }
        [type] $ExpectedInputType = [hashtable]
        [hashtable[]] $IO = @(
            @{
                Input  = @{
                    Name          = 'Valid'
                    Verbose       = $true
                    NotAParameter = 'Remove'
                }
                Output = @{
                    Name = 'Valid'
                }
            }
        )
    }
    TestGroup ExcludeParameters
}
