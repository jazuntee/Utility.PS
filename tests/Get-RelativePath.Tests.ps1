[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'Get-RelativePath' {

    Context 'String Output' {
        class CaseInsensitiveInput {
            [string] $CommandName = 'Get-RelativePath'
            [hashtable] $BoundParameters = @{
                WorkingDirectory   = 'C:\DirectoryA'
                DirectorySeparator = '\'
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'C:\DirectoryA\File1.txt'
                    Output = '.\File1.txt'
                }
                @{
                    Input  = 'C:\Directorya\File1.txt'
                    Output = '.\File1.txt'
                }
                @{
                    Input  = 'C:\DirectoryB\File2.txt'
                    Output = '.\..\DirectoryB\File2.txt'
                }
            )
        }
        TestGroup CaseInsensitiveInput

        class CaseSensitiveInput {
            [string] $CommandName = 'Get-RelativePath'
            [hashtable] $BoundParameters = @{
                WorkingDirectory   = 'C:\DirectoryA'
                CompareCase        = $true
                DirectorySeparator = '\'
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input  = 'C:\DirectoryA\File1.txt'
                    Output = '.\File1.txt'
                }
                @{
                    Input  = 'C:\Directorya\File1.txt'
                    Output = '.\..\Directorya\File1.txt'
                }
                @{
                    Input  = 'C:\DirectoryB\File2.txt'
                    Output = '.\..\DirectoryB\File2.txt'
                }
            )
        }
        TestGroup CaseSensitiveInput
    }

}
