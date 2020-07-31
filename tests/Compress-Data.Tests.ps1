[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force
#Import-Module Pester -MaximumVersion 4.99

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'Compress-Data' {

    Context 'DEFLATE Output' {
        class StringInput {
            [string] $CommandName = 'Compress-Data'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'ASCII string compressed with DEFLATE'
                    Output = [byte[]]@(115, 12, 118, 246, 244, 84, 40, 46, 41, 202, 204, 75, 87, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 207, 44, 201, 80, 112, 113, 117, 243, 113, 12, 113, 5, 0)
                }
                @{
                    Input  = 'Another DEFLATE compressed string with ASCII encoding'
                    Output = [byte[]]@(115, 204, 203, 47, 201, 72, 45, 82, 112, 113, 117, 243, 113, 12, 113, 85, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 46, 41, 202, 204, 75, 87, 40, 207, 44, 201, 80, 112, 12, 118, 246, 244, 84, 72, 205, 75, 206, 79, 1, 138, 1, 0)
                }
            )
        }
        TestGroup StringInput

        class ByteInput {
            [string] $CommandName = 'Compress-Data'
            [hashtable] $BoundParameters = @{
                WarningAction = 'SilentlyContinue'
            }
            [type] $ExpectedInputType = [byte[]]
            [hashtable[]] $IO = @(
                @{
                    Input  = [byte[]]@(57, 48, 0, 0)
                    Output = [byte[]]@(179, 52, 96, 96, 0, 0)
                }
                @{
                    Input  = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                    Output = [byte[]]@(123, 214, 164, 104, 186, 97, 150, 168, 99, 67, 245, 225, 156, 14, 166, 249, 75, 0)
                }
            )
        }
        TestGroup ByteInput

        class ValueTypeInput {
            [string] $CommandName = 'Compress-Data'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType
            [hashtable[]] $IO = @(
                @{
                    Input  = [bool]$true
                    Output = [byte[]]@(99, 4, 0)
                }
                @{
                    Input  = [bool]$false
                    Output = [byte[]]@(99, 0, 0)
                }
                @{
                    Input  = [char]'a'
                    Output = [byte[]]@(75, 100, 0, 0)
                }
                @{
                    Input  = [int]0
                    Output = [byte[]]@(99, 96, 96, 96, 0, 0)
                }
                @{
                    Input  = [Int16]127
                    Output = [byte[]]@(171, 103, 0, 0)
                }
                @{
                    Input  = [UInt16]127
                    Output = [byte[]]@(171, 103, 0, 0)
                }
                @{
                    Input  = [Int32]127
                    Output = [byte[]]@(171, 103, 96, 96, 0, 0)
                }
                @{
                    Input  = [UInt32]127
                    Output = [byte[]]@(171, 103, 96, 96, 0, 0)
                }
                @{
                    Input  = [Int64]127
                    Output = [byte[]]@(171, 103, 128, 0, 0)
                }
                @{
                    Input  = [UInt64]127
                    Output = [byte[]]@(171, 103, 128, 0, 0)
                }
                @{
                    Input  = [Single]127
                    Output = [byte[]]@(99, 96, 248, 231, 4, 0)
                }
                @{
                    Input  = [Double]127
                    Output = [byte[]]@(99, 96, 0, 130, 3, 241, 14, 0)
                }
                @{
                    Input = [decimal]127
                    Error = $true
                }
                @{
                    Input  = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4'
                    Output = [byte[]]@(123, 214, 164, 104, 186, 97, 150, 168, 99, 67, 245, 225, 156, 14, 166, 249, 75, 0)
                }
            )
        }
        TestGroup ValueTypeInput

        class FileInput {
            [string] $CommandName = 'Compress-Data'
            [hashtable] $BoundParameters = @{ }
            [type] $ExpectedInputType = [System.IO.FileInfo]
            [hashtable[]] $IO = @(
                @{
                    Input  = & { $Path = 'TestDrive:\TextFile.txt'; Set-Content $Path -Value 'A compressed string with DEFLATE'; Get-Item $Path }
                    Output = [byte[]]@(115, 84, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 46, 41, 202, 204, 75, 87, 40, 207, 44, 201, 80, 112, 113, 117, 243, 113, 12, 113, 229, 229, 2, 0)
                }
            )
        }
        TestGroup FileInput
    }

    Context 'GZIP Output' {
        class StringInput {
            [string] $CommandName = 'Compress-Data'
            [hashtable] $BoundParameters = @{
                GZip          = $true
                GZipUnknownOS = $true
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'ASCII string compressed with DEFLATE'
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 115, 12, 118, 246, 244, 84, 40, 46, 41, 202, 204, 75, 87, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 207, 44, 201, 80, 112, 113, 117, 243, 113, 12, 113, 5, 0, 246, 49, 37, 3, 36, 0, 0, 0)
                }
                @{
                    Input  = 'Another DEFLATE compressed string with ASCII encoding'
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 115, 204, 203, 47, 201, 72, 45, 82, 112, 113, 117, 243, 113, 12, 113, 85, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 46, 41, 202, 204, 75, 87, 40, 207, 44, 201, 80, 112, 12, 118, 246, 244, 84, 72, 205, 75, 206, 79, 1, 138, 1, 0, 5, 158, 182, 155, 53, 0, 0, 0)
                }
            )
        }
        TestGroup StringInput

        class ByteInput {
            [string] $CommandName = 'Compress-Data'
            [hashtable] $BoundParameters = @{
                GZip          = $true
                GZipUnknownOS = $true
                WarningAction = 'SilentlyContinue'
            }
            [type] $ExpectedInputType = [byte[]]
            [hashtable[]] $IO = @(
                @{
                    Input  = [byte[]]@(57, 48, 0, 0)
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 179, 52, 96, 96, 0, 0, 167, 141, 12, 136, 4, 0, 0, 0)
                }
                @{
                    Input  = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 123, 214, 164, 104, 186, 97, 150, 168, 99, 67, 245, 225, 156, 14, 166, 249, 75, 0, 101, 37, 115, 75, 16, 0, 0, 0)
                }
            )
        }
        TestGroup ByteInput

        class ValueTypeInput {
            [string] $CommandName = 'Compress-Data'
            [hashtable] $BoundParameters = @{
                GZip          = $true
                GZipUnknownOS = $true
            }
            [type] $ExpectedInputType
            [hashtable[]] $IO = @(
                @{
                    Input  = [bool]$true
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 99, 4, 0, 27, 223, 5, 165, 1, 0, 0, 0)
                }
                @{
                    Input  = [bool]$false
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 99, 0, 0, 141, 239, 2, 210, 1, 0, 0, 0)
                }
                @{
                    Input  = [char]'a'
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 75, 100, 0, 0, 25, 72, 63, 61, 2, 0, 0, 0)
                }
                @{
                    Input  = [int]0
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 99, 96, 96, 96, 0, 0, 28, 223, 68, 33, 4, 0, 0, 0)
                }
                @{
                    Input  = [Int16]127
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 171, 103, 0, 0, 198, 119, 126, 233, 2, 0, 0, 0)
                }
                @{
                    Input  = [UInt16]127
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 171, 103, 0, 0, 198, 119, 126, 233, 2, 0, 0, 0)
                }
                @{
                    Input  = [Int32]127
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 171, 103, 96, 96, 0, 0, 214, 111, 24, 18, 4, 0, 0, 0)
                }
                @{
                    Input  = [UInt32]127
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 171, 103, 96, 96, 0, 0, 214, 111, 24, 18, 4, 0, 0, 0)
                }
                @{
                    Input  = [Int64]127
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 171, 103, 128, 0, 0, 85, 92, 82, 16, 8, 0, 0, 0)
                }
                @{
                    Input  = [UInt64]127
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 171, 103, 128, 0, 0, 85, 92, 82, 16, 8, 0, 0, 0)
                }
                @{
                    Input  = [Single]127
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 99, 96, 248, 231, 4, 0, 147, 51, 169, 51, 4, 0, 0, 0)
                }
                @{
                    Input  = [Double]127
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 99, 96, 0, 130, 3, 241, 14, 0, 34, 73, 114, 191, 8, 0, 0, 0)
                }
                @{
                    Input = [decimal]127
                    Error = $true
                }
                @{
                    Input  = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4'
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 123, 214, 164, 104, 186, 97, 150, 168, 99, 67, 245, 225, 156, 14, 166, 249, 75, 0, 101, 37, 115, 75, 16, 0, 0, 0)
                }
            )
        }
        TestGroup ValueTypeInput

        class FileInput {
            [string] $CommandName = 'Compress-Data'
            [hashtable] $BoundParameters = @{
                GZip          = $true
                GZipUnknownOS = $true
            }
            [type] $ExpectedInputType = [System.IO.FileInfo]
            [hashtable[]] $IO = @(
                @{
                    Input  = & { $Path = 'TestDrive:\TextFile.txt'; Set-Content $Path -Value 'A compressed string with DEFLATE'; Get-Item $Path }
                    Output = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 115, 84, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 46, 41, 202, 204, 75, 87, 40, 207, 44, 201, 80, 112, 113, 117, 243, 113, 12, 113, 229, 229, 2, 0, 23, 219, 236, 124, 34, 0, 0, 0)
                }
            )
        }
        TestGroup FileInput
    }
}
