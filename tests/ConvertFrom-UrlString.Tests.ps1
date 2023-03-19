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

Describe 'ConvertFrom-UrlString' {

    Context 'URL-Encoded String Output' {
        class StringOutput {
            [string] $CommandName = 'ConvertFrom-UrlString'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'A+string+with+url+encoding'
                    Output = 'A string with url encoding'
                }
                @{
                    Input  = 'Another+url-encoded+string'
                    Output = 'Another url-encoded string'
                }
            )
        }
        TestGroup StringOutput
    }

}
