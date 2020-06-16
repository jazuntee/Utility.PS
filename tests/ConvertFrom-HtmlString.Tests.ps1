[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'ConvertFrom-HtmlString' {

    Context 'HTML-Encoded String Output' {
        class StringOutput {
            [string] $CommandName = 'ConvertFrom-HtmlString'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'A string with &lt;html&gt; encoding'
                    Output = 'A string with <html> encoding'
                }
                @{
                    Input  = 'Another &lt;html&gt;-encoded string'
                    Output = 'Another <html>-encoded string'
                }
            )
        }
        TestGroup StringOutput
    }

}
