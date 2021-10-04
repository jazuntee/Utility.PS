[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'ConvertFrom-QueryString' {

    Context 'Query String Input' {
        class PSObjectOutput {
            [string] $CommandName = 'ConvertFrom-QueryString'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'index=10&name=path%2Ffile.json'
                    Output = New-Module -AsCustomObject { $index = [string]10; $name = 'path/file.json'; Export-ModuleMember -Variable * }
                }
                @{
                    Input  = 'id=352182e6-9ab0-4115-807b-c36c88029fa4&title=convert%26prosper'
                    Output = New-Module -AsCustomObject { $id = [string]'352182e6-9ab0-4115-807b-c36c88029fa4'; $title = 'convert&prosper'; Export-ModuleMember -Variable * }
                }
                @{
                    Input  = ''
                    Output = New-Module -AsCustomObject { }
                }
            )
        }
        TestGroup PSObjectOutput

        class HashtableOutput {
            [string] $CommandName = 'ConvertFrom-QueryString'
            [hashtable] $BoundParameters = @{ AsHashtable = $true }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'index=10&name=path%2Ffile.json'
                    Output = @{ index = [string]10; name = 'path/file.json' }
                }
                @{
                    Input  = 'id=352182e6-9ab0-4115-807b-c36c88029fa4&title=convert%26prosper'
                    Output = @{ id = [string]'352182e6-9ab0-4115-807b-c36c88029fa4'; title = 'convert&prosper' }
                }
                @{
                    Input  = ''
                    Output = @{}
                }
            )
        }
        TestGroup HashtableOutput
    }

}
