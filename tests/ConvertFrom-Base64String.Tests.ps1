[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot "TestCommon.ps1")

Describe "ConvertFrom-Base64String" {

    Context "Base64-Encoded String Input" {
        class StringOutput {
            [string] $CommandName = 'ConvertFrom-Base64String'
            [hashtable] $BoundParameters = @{}
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = "QSBzdHJpbmcgd2l0aCBiYXNlNjQgZW5jb2Rpbmc="
                    Output = "A string with base64 encoding"
                }
                @{
                    Input = "QW5vdGhlciBiYXNlNjQtZW5jb2RlZCBzdHJpbmc="
                    Output = "Another base64-encoded string"
                }
            )
        }
        TestGroup StringOutput

        class ByteArrayOutput {
            [string] $CommandName = 'ConvertFrom-Base64String'
            [hashtable] $BoundParameters = @{
                RawBytes = $true
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = "5oIhNbCaFUGAe8NsiAKfpA=="
                    Output = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                }
                @{
                    Input = "OTAAAA=="
                    Output = [byte[]]@(57, 48, 0, 0)
                }
            )
        }
        TestGroup ByteArrayOutput
    }

    Context "Base64Url-Encoded String Input" {
        class StringOutput {
            [string] $CommandName = 'ConvertFrom-Base64String'
            [hashtable] $BoundParameters = @{
                Base64Url = $true
                Encoding = 'ASCII'
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = "QVNDSUkgc3RyaW5nIHdpdGggYmFzZTY0dXJsIGVuY29kaW5n"
                    Output = "ASCII string with base64url encoding"
                }
                @{
                    Input = "QW5vdGhlciBiYXNlNjR1cmwtZW5jb2RlZCBzdHJpbmcgd2l0aCBBU0NJSSBlbmNvZGluZw"
                    Output = "Another base64url-encoded string with ASCII encoding"
                }
            )
        }
        TestGroup StringOutput

        class ByteArrayOutput {
            [string] $CommandName = 'ConvertFrom-Base64String'
            [hashtable] $BoundParameters = @{
                Base64Url = $true
                RawBytes = $true
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = "5oIhNbCaFUGAe8NsiAKfpA"
                    Output = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                }
                @{
                    Input = "OTAAAA"
                    Output = [byte[]]@(57, 48, 0, 0)
                }
            )
        }
        TestGroup ByteArrayOutput
    }
}
