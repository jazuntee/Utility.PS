<#
.SYNOPSIS
    Output the first non-null value from list of input values.

.EXAMPLE
    PS >Skip-NullValue $null, 'winner', 'loser'

    Return the first non-null value which is 'winner'.

.EXAMPLE
    PS >Get-Module 'NonExistentModuleName' | Skip-NullValue -DefaultValue @()

    Return the first non-null value which is 'winner'.

.EXAMPLE
    PS >Skip-NullValue $null, '', ([guid]::Empty), @(), 0, ([int]-1), 'winner', 'loser' -SkipEmpty -SkipZero -SkipNegative

    Return the first non-null, non-empty, non-zero, and non-negative value which is 'winner'.

.INPUTS
    System.Object

.LINK
    https://github.com/jasoth/Utility.PS
#>
function Skip-NullValue {
    [CmdletBinding()]
    [Alias('Coalesce')]
    param (
        # Values to coalesce
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [AllowNull()]
        [object] $InputObject,
        # Skip over empty values
        [Parameter(Mandatory = $false)]
        [switch] $SkipEmpty,
        # Skip over zero values
        [Parameter(Mandatory = $false)]
        [switch] $SkipZero,
        # Skip over negative values
        [Parameter(Mandatory = $false)]
        [switch] $SkipNegative,
        # Default value when no other values 
        [Parameter(Mandatory = $false)]
        [object] $DefaultValue = $null,
        # Enumerate pipeline input rather than treat it as a single input
        [Parameter(Mandatory = $false)]
        [switch] $EnumeratePipelineInput
    )

    begin {
        function HasValue ($Object) {
            if ($null -ne $Object) {
                Write-Debug "ObjectType: $($Object.psobject.TypeNames[0]) | Object: $Object"

                ## Additional Tests (these could leak errors into $Error variable)
                [bool]$TestEmptyArray = try { $SkipEmpty -and $Object -is [array] -and $Object.Count -eq 0 } catch { $false }
                [bool]$TestEmpty = try { $SkipEmpty -and $Object -eq ($Object.GetType())::Empty } catch { $false }
                [bool]$TestZero = try { $SkipZero -and $Object -eq 0 } catch { $false }
                [bool]$TestNegative = try { $SkipNegative -and $Object -lt 0 } catch { $false }

                Write-Debug "TestEmptyArray: $TestEmptyArray | TestEmpty: $TestEmpty | TestZero: $TestZero | TestNegative: $TestNegative"

                if (!($TestEmptyArray -or $TestEmpty -or $TestZero -or $TestNegative)) {
                    return $true
                }
            }
            return $false
        }

        ## Initialize
        $InputObjects = @()
        $OutputObject = $null
        [bool]$IsPipelineInput = $false
        if ($null -eq $InputObject) { $IsPipelineInput = $true }
    }

    process {
        ## Save pipeline input to process at end if not enumerating pipeline input.
        $InputObjects += $InputObject
        if ($IsPipelineInput -and !$EnumeratePipelineInput) { return }

        ## Skip enumerated input if previous input already satisfied condition.
        if ($null -ne $OutputObject) { return }
        
        ## Loop through input objects and return the first value.
        foreach ($Object in $InputObject) {
            if (HasValue $Object) {
                $OutputObject = $Object
                return
            }
        }
    }

    end {
        ## Remove array if count is 1 or less.
        if ($InputObjects.Count -eq 0) { $InputObjects = $null }
        elseif ($InputObjects.Count -eq 1) { $InputObjects = $InputObjects[0] }

        ## If pipeline input was detected, treat the input array as one value like ?? operator.
        if ($IsPipelineInput -and !$EnumeratePipelineInput) {
            if (HasValue $InputObjects) {
                $OutputObject = $InputObjects
            }
        }

        ## If no acceptable values were found, use default value.
        if ($null -eq $OutputObject) { $OutputObject = $DefaultValue }

        Write-Output $OutputObject -NoEnumerate
    }
}
