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

Describe 'Expand-Data' {

    Context 'DEFLATE Input' {
        class StringOutput {
            [string] $CommandName = 'Expand-Data'
            [hashtable] $BoundParameters = @{
                WarningAction = 'SilentlyContinue'
            }
            [type] $ExpectedInputType = [byte[]]
            [hashtable[]] $IO = @(
                @{
                    Input  = [byte[]]@(115, 12, 118, 246, 244, 84, 40, 46, 41, 202, 204, 75, 87, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 207, 44, 201, 80, 112, 113, 117, 243, 113, 12, 113, 5, 0)
                    Output = 'ASCII string compressed with DEFLATE'
                }
                @{
                    Input  = [byte[]]@(115, 204, 203, 47, 201, 72, 45, 82, 112, 113, 117, 243, 113, 12, 113, 85, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 46, 41, 202, 204, 75, 87, 40, 207, 44, 201, 80, 112, 12, 118, 246, 244, 84, 72, 205, 75, 206, 79, 1, 138, 1, 0)
                    Output = 'Another DEFLATE compressed string with ASCII encoding'
                }
            )
        }
        TestGroup StringOutput

        class ByteArrayOutput {
            [string] $CommandName = 'Expand-Data'
            [hashtable] $BoundParameters = @{
                RawBytes      = $true
                WarningAction = 'SilentlyContinue'
            }
            [type] $ExpectedInputType = [byte[]]
            [hashtable[]] $IO = @(
                @{
                    Input  = [byte[]]@(179, 52, 96, 96, 0, 0)
                    Output = [byte[]]@(57, 48, 0, 0)
                }
                @{
                    Input  = [byte[]]@(123, 214, 164, 104, 186, 97, 150, 168, 99, 67, 245, 225, 156, 14, 166, 249, 75, 0)
                    Output = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                }
            )
        }
        TestGroup ByteArrayOutput
    }

    Context 'GZIP Input' {
        class StringOutput {
            [string] $CommandName = 'Expand-Data'
            [hashtable] $BoundParameters = @{
                GZip          = $true
                WarningAction = 'SilentlyContinue'
            }
            [type] $ExpectedInputType = [byte[]]
            [hashtable[]] $IO = @(
                @{
                    Input  = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 115, 12, 118, 246, 244, 84, 40, 46, 41, 202, 204, 75, 87, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 207, 44, 201, 80, 112, 113, 117, 243, 113, 12, 113, 5, 0, 246, 49, 37, 3, 36, 0, 0, 0)
                    Output = 'ASCII string compressed with DEFLATE'
                }
                @{
                    Input  = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 115, 204, 203, 47, 201, 72, 45, 82, 112, 113, 117, 243, 113, 12, 113, 85, 72, 206, 207, 45, 40, 74, 45, 46, 78, 77, 81, 40, 46, 41, 202, 204, 75, 87, 40, 207, 44, 201, 80, 112, 12, 118, 246, 244, 84, 72, 205, 75, 206, 79, 1, 138, 1, 0, 5, 158, 182, 155, 53, 0, 0, 0)
                    Output = 'Another DEFLATE compressed string with ASCII encoding'
                }
            )
        }
        TestGroup StringOutput

        class ByteArrayOutput {
            [string] $CommandName = 'Expand-Data'
            [hashtable] $BoundParameters = @{
                GZip          = $true
                RawBytes      = $true
                WarningAction = 'SilentlyContinue'
            }
            [type] $ExpectedInputType = [byte[]]
            [hashtable[]] $IO = @(
                @{
                    Input  = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 179, 52, 96, 96, 0, 0, 167, 141, 12, 136, 4, 0, 0, 0)
                    Output = [byte[]]@(57, 48, 0, 0)
                }
                @{
                    Input  = [byte[]]@(31, 139, 8, 0, 0, 0, 0, 0, 2, 255, 123, 214, 164, 104, 186, 97, 150, 168, 99, 67, 245, 225, 156, 14, 166, 249, 75, 0, 101, 37, 115, 75, 16, 0, 0, 0)
                    Output = [byte[]]@(230, 130, 33, 53, 176, 154, 21, 65, 128, 123, 195, 108, 136, 2, 159, 164)
                }
            )
        }
        TestGroup ByteArrayOutput
    }
}
