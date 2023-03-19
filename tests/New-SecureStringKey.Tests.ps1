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

Describe 'New-SecureStringKey' {

    It 'No Input 16 byte default' {
        $Output = New-SecureStringKey
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [securestring]
        (ConvertFrom-SecureString $Output).Length | Should -Be 524
    }

    It 'as Positional Parameter' {
        $Input = 24
        $Output = New-SecureStringKey $Input
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [securestring]
        (ConvertFrom-SecureString $Output).Length | Should -Be 556
    }

    It 'as Pipeline Input' {
        $Input = 32
        $Output = $Input | New-SecureStringKey
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [securestring]
        (ConvertFrom-SecureString $Output).Length | Should -Be 588
    }

}
