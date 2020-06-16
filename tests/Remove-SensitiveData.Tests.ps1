[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

Describe 'Remove-SensitiveData' {

    class DefaultReplacement {
        [string] $CommandName = 'Remove-SensitiveData'
        [hashtable] $BoundParameters = @{
            FilterValues = 'Super', 'String'
            PassThru     = $true
        }
        [type] $ExpectedInputType = [object]
        [hashtable[]] $IO = @(
            @{
                Input  = 'My password is: "SuperSecretString"'
                Output = 'My password is: "********Secret********"'
            }
            @{
                Input  = [object[]]@(
                    'My password is: "SuperSecretString"'
                    'Just a Super string...'
                )
                Output = [object[]]@(
                    'My password is: "********Secret********"'
                    'Just a ******** string...'
                )
            }
            @{
                Input      = [System.Collections.ArrayList]@(
                    'My password is: "SuperSecretString"'
                    'Just a Super string...'
                )
                Output     = [System.Collections.ArrayList]@(
                    'My password is: "********Secret********"'
                    'Just a ******** string...'
                )
                PipeOutput = [object[]]@(
                    'My password is: "********Secret********"'
                    'Just a ******** string...'
                )
            }
            @{
                Input      = [System.Collections.Generic.List[string]]@(
                    'My password is: "SuperSecretString"'
                    'Just a Super string...'
                )
                Output     = [System.Collections.Generic.List[string]]@(
                    'My password is: "********Secret********"'
                    'Just a ******** string...'
                )
                PipeOutput = [object[]]@(
                    'My password is: "********Secret********"'
                    'Just a ******** string...'
                )
            }
            @{
                Input  = [hashtable]@{ MyKey = 'My password is: "SuperSecretString"'; Key2 = 'Just a Super string...'; Blank = $null }
                Output = [hashtable]@{ MyKey = 'My password is: "********Secret********"'; Key2 = 'Just a ******** string...'; Blank = $null }
            }
            @{
                Input  = [ordered]@{ MyKey = 'My password is: "SuperSecretString"'; Key2 = 'Just a Super string...'; Blank = '' }
                Output = [ordered]@{ MyKey = 'My password is: "********Secret********"'; Key2 = 'Just a ******** string...'; Blank = '' }
            }
            @{
                Input  = Invoke-Command { $D = New-Object 'System.Collections.Generic.Dictionary[string,object]'; $D.Add('MyKey', 'My password is: "SuperSecretString"'); $D.Add('Key2', 'Just a Super string...'); $D }
                Output = Invoke-Command { $D = New-Object 'System.Collections.Generic.Dictionary[string,object]'; $D.Add('MyKey', 'My password is: "********Secret********"'); $D.Add('Key2', 'Just a ******** string...'); $D }
            }
            @{
                Input  = [pscustomobject]@{ MyKey = 'My password is: "SuperSecretString"'; Key2 = 'Just a Super string...'; Number = 1 }
                Output = [pscustomobject]@{ MyKey = 'My password is: "********Secret********"'; Key2 = 'Just a ******** string...'; Number = 1 }
            }
        )
    }
    TestGroup DefaultReplacement

    class NoFilterValues {
        [string] $CommandName = 'Remove-SensitiveData'
        [hashtable] $BoundParameters = @{
            FilterValues = '', $null, 0
            PassThru     = $true
        }
        [type] $ExpectedInputType = [object]
        [hashtable[]] $IO = @(
            @{
                Input  = 'My password is: "SuperSecretString"'
                Output = 'My password is: "SuperSecretString"'
            }
        )
    }
    TestGroup NoFilterValues
}
