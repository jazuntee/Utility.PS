[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'Test-IpAddressInSubnet' {

    Context 'Matching Subnet Output' {

        class SubnetOutput {
            [string] $CommandName = 'Test-IpAddressInSubnet'
            [hashtable] $BoundParameters = @{
                Subnets = '192.168.1.1/32','192.168.1.0/24','0.0.0.0/0'
                ReturnMatchingSubnets = $true
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = '192.168.1.1'
                    Output = '192.168.1.1/32','192.168.1.0/24','0.0.0.0/0'
                }
                @{
                    Input = '192.168.1.10'
                    Output = '192.168.1.0/24','0.0.0.0/0'
                }
                @{
                    Input = '192.168.2.1'
                    Output = '0.0.0.0/0'
                }
            )
        }
        TestGroup SubnetOutput

        class NoMatchingSubnetOutput {
            [string] $CommandName = 'Test-IpAddressInSubnet'
            [hashtable] $BoundParameters = @{
                Subnets = '192.168.1.1/32','192.168.1.0/24'
                ReturnMatchingSubnets = $true
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = '192.168.1.1'
                    Output = '192.168.1.1/32','192.168.1.0/24'
                }
                @{
                    Input = '192.168.5.1'
                    Error = $true
                }
                @{
                    Input = '192.168.6.1'
                    Error = $true
                }
                @{
                    Input = '192.168.1.10'
                    Output = '192.168.1.0/24'
                }
            )
        }
        TestGroup NoMatchingSubnetOutput

        class BooleanOutput {
            [string] $CommandName = 'Test-IpAddressInSubnet'
            [hashtable] $BoundParameters = @{
                Subnets = '192.168.1.1/32','192.168.1.0/24'
            }
            [type] $ExpectedInputType = [string]
            [hashtable[]] $IO = @(
                @{
                    Input = '192.168.1.1'
                    Output = $true
                }
                @{
                    Input = '192.168.1.10'
                    Output = $true
                }
                @{
                    Input = '192.168.5.1'
                    Output = $false
                }
            )
        }
        TestGroup BooleanOutput
    }
}
