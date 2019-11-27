[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot "TestCommon.ps1")

Describe "ConvertTo-HexString" {

    Context "Default Output" {
        class StringInput {
            [string] $CommandName = 'ConvertTo-HexString'
            [hashtable] $BoundParameters = @{}
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = "What is a hex string?"
                    Output = "57 68 61 74 20 69 73 20 61 20 68 65 78 20 73 74 72 69 6E 67 3F"
                }
                @{
                    Input = "ASCII string with base64url encoding"
                    Output = "41 53 43 49 49 20 73 74 72 69 6E 67 20 77 69 74 68 20 62 61 73 65 36 34 75 72 6C 20 65 6E 63 6F 64 69 6E 67"
                }
            )
        }
        TestGroup StringInput

        class ByteInput {
            [string] $CommandName = 'ConvertTo-HexString'
            [hashtable] $BoundParameters = @{
                WarningAction = "SilentlyContinue"
            }
            [type] $ExpectedInputType = [byte[]]
            [hashtable[]] $IO = @(
                @{
                    Input = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                    Output = 'E6 82 21 35 B0 9A 15 41 80 7B C3 6C 88 02 9F A4'
                }
                @{
                    Input = [byte[]]@(57, 48, 0, 0)
                    Output = '39 30 00 00'
                }
            )
        }
        TestGroup ByteInput

        class ValueTypeInput {
            [string] $CommandName = 'ConvertTo-HexString'
            [hashtable] $BoundParameters = @{}
            [type] $ExpectedInputType
            [hashtable[]] $IO = @(
                @{
                    Input = [bool]$true
                    Output = '01'
                }
                @{
                    Input = [bool]$false
                    Output = '00'
                }
                @{
                    Input = [char]'a'
                    Output = '61 00'
                }
                @{
                    Input = [int]0
                    Output = '00 00 00 00'
                }
                @{
                    Input = [Int16]127
                    Output = '7F 00'
                }
                @{
                    Input = [UInt16]127
                    Output = '7F 00'
                }
                @{
                    Input = [Int32]127
                    Output = '7F 00 00 00'
                }
                @{
                    Input = [UInt32]127
                    Output = '7F 00 00 00'
                }
                @{
                    Input = [Int64]127
                    Output = '7F 00 00 00 00 00 00 00'
                }
                @{
                    Input = [UInt64]127
                    Output = '7F 00 00 00 00 00 00 00'
                }
                @{
                    Input = [Single]127
                    Output = '00 00 FE 42'
                }
                @{
                    Input = [Double]127
                    Output = '00 00 00 00 00 C0 5F 40'
                }
                @{
                    Input = [decimal]127
                    Error = $true
                }
                @{
                    Input = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4'
                    Output = 'E6 82 21 35 B0 9A 15 41 80 7B C3 6C 88 02 9F A4'
                }
            )
        }
        TestGroup ValueTypeInput

        class FileInput {
            [string] $CommandName = 'ConvertTo-HexString'
            [hashtable] $BoundParameters = @{}
            [type] $ExpectedInputType = [System.IO.FileInfo]
            [hashtable[]] $IO = @(
                @{
                    Input = &{ $Path = 'TestDrive:\TextFile.txt'; Set-Content $Path -Value 'What is a hex string?'; Get-Item $Path }
                    Output = '57 68 61 74 20 69 73 20 61 20 68 65 78 20 73 74 72 69 6E 67 3F 0D 0A'
                }
            )
        }
        TestGroup FileInput
    }

    Context "No Delimiter Output" {
        class StringInput {
            [string] $CommandName = 'ConvertTo-HexString'
            [hashtable] $BoundParameters = @{
                Delimiter = ''
                Encoding = 'ASCII'
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = "ASCII string to hex string"
                    Output = "415343494920737472696E6720746F2068657820737472696E67"
                }
                @{
                    Input = "Another ASCII string to hex string"
                    Output = "416E6F7468657220415343494920737472696E6720746F2068657820737472696E67"
                }
            )
        }
        TestGroup StringInput
    }

    Write-Host
    It "Terminating Errors" {
        $ScriptBlock = { ([int]127),([decimal]127),([long]127) | ConvertTo-HexString -ErrorAction Stop }
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
