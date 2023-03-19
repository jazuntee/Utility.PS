<#
.SYNOPSIS
    Get the strict mode version of the current session scope.
    
.DESCRIPTION
    Get the strict mode version of the current session scope.
    1.0
        Prohibits references to uninitialized variables, except for uninitialized variables in strings.
    2.0
        Prohibits references to uninitialized variables. This includes uninitialized variables in strings.
        Prohibits references to non-existent properties of an object.
        Prohibits function calls that use the syntax for calling methods.
    3.0
        Prohibits references to uninitialized variables. This includes uninitialized variables in strings.
        Prohibits references to non-existent properties of an object.
        Prohibits function calls that use the syntax for calling methods.
        Prohibit out of bounds or unresolvable array indexes.

.EXAMPLE
    PS >Get-StrictModeVersion

    Get the strict mode version of the current session scope.

.INPUTS
    None

.LINK
    https://github.com/jasoth/Utility.PS
#>
function Get-StrictModeVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param ()

    try { $null = @()[0] }
    catch { return [version]'3.0' }

    try { $null = $null.NonExistentProperty }
    catch { return [version]'2.0' }

    try { $null = $UninitializedVariable }
    catch { return [version]'1.0' }

    return [version]'0.0'
}
