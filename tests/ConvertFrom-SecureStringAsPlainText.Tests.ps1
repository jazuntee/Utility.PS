[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'ConvertFrom-SecureStringAsPlainText' {

    class SecureStringInput {
        [string] $CommandName = 'ConvertFrom-SecureStringAsPlainText'
        [hashtable] $BoundParameters = @{
            Force = $true
        }
        [type] $ExpectedInputType = [securestring]
        [hashtable[]] $IO = @(
            @{
                Input = (ConvertTo-SecureString 'SuperSecretString' -AsPlainText -Force)
                Output = 'SuperSecretString'
            }
        )
    }
    TestGroup SecureStringInput

}
