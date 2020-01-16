[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'ConvertTo-Base64String' {

    Context 'Base64-Encoded String Output' {
        class StringInput {
            [string] $CommandName = 'ConvertTo-Base64String'
            [hashtable] $BoundParameters = @{}
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = 'A string with base64 encoding'
                    Output = 'QSBzdHJpbmcgd2l0aCBiYXNlNjQgZW5jb2Rpbmc='
                }
                @{
                    Input = 'Another base64-encoded string'
                    Output = 'QW5vdGhlciBiYXNlNjQtZW5jb2RlZCBzdHJpbmc='
                }
            )
        }
        TestGroup StringInput

        class ByteInput {
            [string] $CommandName = 'ConvertTo-Base64String'
            [hashtable] $BoundParameters = @{
                WarningAction = 'SilentlyContinue'
            }
            [type] $ExpectedInputType = [byte[]]
            [hashtable[]] $IO = @(
                @{
                    Input = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                    Output = '5oIhNbCaFUGAe8NsiAKfpA=='
                }
                @{
                    Input = [byte[]]@(57, 48, 0, 0)
                    Output = 'OTAAAA=='
                }
            )
        }
        TestGroup ByteInput

        class ValueTypeInput {
            [string] $CommandName = 'ConvertTo-Base64String'
            [hashtable] $BoundParameters = @{}
            [type] $ExpectedInputType
            [hashtable[]] $IO = @(
                @{
                    Input = [bool]$true
                    Output = 'AQ=='
                }
                @{
                    Input = [bool]$false
                    Output = 'AA=='
                }
                @{
                    Input = [char]'a'
                    Output = 'YQA='
                }
                @{
                    Input = [int]0
                    Output = 'AAAAAA=='
                }
                @{
                    Input = [Int16]127
                    Output = 'fwA='
                }
                @{
                    Input = [UInt16]127
                    Output = 'fwA='
                }
                @{
                    Input = [Int32]127
                    Output = 'fwAAAA=='
                }
                @{
                    Input = [UInt32]127
                    Output = 'fwAAAA=='
                }
                @{
                    Input = [Int64]127
                    Output = 'fwAAAAAAAAA='
                }
                @{
                    Input = [UInt64]127
                    Output = 'fwAAAAAAAAA='
                }
                @{
                    Input = [Single]127
                    Output = 'AAD+Qg=='
                }
                @{
                    Input = [Double]127
                    Output = 'AAAAAADAX0A='
                }
                @{
                    Input = [decimal]127
                    Error = $true
                }
                @{
                    Input = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4'
                    Output = '5oIhNbCaFUGAe8NsiAKfpA=='
                }
            )
        }
        TestGroup ValueTypeInput

        class FileInput {
            [string] $CommandName = 'ConvertTo-Base64String'
            [hashtable] $BoundParameters = @{}
            [type] $ExpectedInputType = [System.IO.FileInfo]
            [hashtable[]] $IO = @(
                @{
                    Input = &{ $Path = 'TestDrive:\TextFile.txt'; Set-Content $Path -Value 'A string with base64 encoding'; Get-Item $Path }
                    Output = 'QSBzdHJpbmcgd2l0aCBiYXNlNjQgZW5jb2RpbmcNCg=='
                }
            )
        }
        TestGroup FileInput
    }

    Context 'Base64Url-Encoded String Output' {
        class StringInput {
            [string] $CommandName = 'ConvertTo-Base64String'
            [hashtable] $BoundParameters = @{
                Base64Url = $true
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = 'ASCII string with base64url encoding'
                    Output = 'QVNDSUkgc3RyaW5nIHdpdGggYmFzZTY0dXJsIGVuY29kaW5n'
                }
                @{
                    Input = 'Another base64url-encoded string with ASCII encoding'
                    Output = 'QW5vdGhlciBiYXNlNjR1cmwtZW5jb2RlZCBzdHJpbmcgd2l0aCBBU0NJSSBlbmNvZGluZw'
                }
            )
        }
        TestGroup StringInput
    }

    Write-Host
    It 'Terminating Errors' {
        $ScriptBlock = { ([int]127),([decimal]127),([long]127) | ConvertTo-Base64String -ErrorAction Stop }
        $ScriptBlock | Should -Throw
        try {
            $Output = & $ScriptBlock
        }
        catch {
            Test-ErrorOutput $_
        }
        $Output | Should -BeNullOrEmpty
    }
}
