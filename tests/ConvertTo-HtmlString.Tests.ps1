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

Describe 'ConvertTo-HtmlString' {

    Context 'HTML-Encoded String Input' {
        class StringInput {
            [string] $CommandName = 'ConvertTo-HtmlString'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'A string with <html> encoding'
                    Output = 'A string with &lt;html&gt; encoding'
                }
                @{
                    Input  = 'Another <html>-encoded string'
                    Output = 'Another &lt;html&gt;-encoded string'
                }
            )
        }
        TestGroup StringInput
    }

}
