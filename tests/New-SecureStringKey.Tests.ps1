[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot "TestCommon.ps1")

Describe "New-SecureStringKey" {

    It "No Input 16 byte default" {
        $Output = New-SecureStringKey
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [securestring]
        (ConvertFrom-SecureString $Output).Length -eq 524 | Should -BeTrue
    }

    It "as Positional Parameter" {
        $Input = 24
        $Output = New-SecureStringKey $Input
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [securestring]
        (ConvertFrom-SecureString $Output).Length -eq 556 | Should -BeTrue
    }

    It "as Pipeline Input" {
        $Input = 32
        $Output = $Input | New-SecureStringKey
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [securestring]
        (ConvertFrom-SecureString $Output).Length -eq 588 | Should -BeTrue
    }

}
