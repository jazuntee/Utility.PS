[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'ConvertFrom-HexString' {

    Context 'Hex String Input' {
        class StringOutput {
            [string] $CommandName = 'ConvertFrom-HexString'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = '57 68 61 74 20 69 73 20 61 20 68 65 78 20 73 74 72 69 6E 67 3F'
                    Output = 'What is a hex string?'
                }
                @{
                    Input  = '41 53 43 49 49 20 73 74 72 69 6E 67 20 77 69 74 68 20 62 61 73 65 36 34 75 72 6C 20 65 6E 63 6F 64 69 6E 67'
                    Output = 'ASCII string with base64url encoding'
                }
            )
        }
        TestGroup StringOutput

        class ByteArrayOutput {
            [string] $CommandName = 'ConvertFrom-HexString'
            [hashtable] $BoundParameters = @{
                RawBytes = $true
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'E6 82 21 35 B0 9A 15 41 80 7B C3 6C 88 02 9F A4'
                    Output = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                }
                @{
                    Input  = '39 30 00 00'
                    Output = [byte[]]@(57, 48, 0, 0)
                }
            )
        }
        TestGroup ByteArrayOutput
    }

    Context 'Hex String Input with no delimiter' {
        class StringOutput {
            [string] $CommandName = 'ConvertFrom-HexString'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = '415343494920737472696E6720746F2068657820737472696E67'
                    Output = 'ASCII string to hex string'
                }
                @{
                    Input  = '416E6F7468657220415343494920737472696E6720746F2068657820737472696E67'
                    Output = 'Another ASCII string to hex string'
                }
            )
        }
        TestGroup StringOutput

        class ByteArrayOutput {
            [string] $CommandName = 'ConvertFrom-HexString'
            [hashtable] $BoundParameters = @{
                RawBytes = $true
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'E6822135B09A1541807BC36C88029FA4'
                    Output = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                }
                @{
                    Input  = '39300000'
                    Output = [byte[]]@(57, 48, 0, 0)
                }
            )
        }
        TestGroup ByteArrayOutput
    }
}
