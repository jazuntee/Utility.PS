<#
.SYNOPSIS
    Get path relative to working directory.

.EXAMPLE
    PS >Get-RelativePath 'C:\DirectoryA\File1.txt'

    Get path relative to current directory.

.EXAMPLE
    PS >Get-RelativePath 'C:\DirectoryA\File1.txt' -WorkingDirectory 'C:\DirectoryB' -CompareCase

    Get path relative to specified working directory with case-sensitive directory comparison.

.INPUTS
    System.String

.LINK
    https://github.com/jasoth/Utility.PS
#>
function Get-RelativePath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Input paths
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string[]] $InputObjects,
        # Working directory for relative paths. Default is current directory.
        [Parameter(Mandatory = $false, Position = 2)]
        [string] $WorkingDirectory = (Get-Location).ProviderPath,
        # Compare directory names as case-sensitive.
        [Parameter(Mandatory = $false)]
        [switch] $CompareCase,
        # Directory separator used in paths.
        [Parameter(Mandatory = $false)]
        [char] $DirectorySeparator = [System.IO.Path]::DirectorySeparatorChar
    )

    begin {
        ## Adapted From:
        ##  https://github.com/dotnet/runtime/blob/6072e4d3a7a2a1493f514cdf4be75a3d56580e84/src/libraries/System.Private.Uri/src/System/Uri.cs#L5037
        function PathDifference([string] $path1, [string] $path2, [bool] $compareCase, [char] $directorySeparator = [System.IO.Path]::DirectorySeparatorChar) {
            [int] $i = 0
            [int] $si = -1

            for ($i = 0; ($i -lt $path1.Length) -and ($i -lt $path2.Length); $i++) {
                if (($path1[$i] -cne $path2[$i]) -and ($compareCase -or ([char]::ToLowerInvariant($path1[$i]) -cne [char]::ToLowerInvariant($path2[$i])))) {
                    break
                }
                elseif ($path1[$i] -ceq $directorySeparator) {
                    $si = $i
                }
            }

            if ($i -ceq 0) {
                return $path2
            }
            if (($i -ceq $path1.Length) -and ($i -ceq $path2.Length)) {
                return [string]::Empty
            }

            [System.Text.StringBuilder] $relPath = New-Object System.Text.StringBuilder
            ## Walk down several dirs
            for (; $i -lt $path1.Length; $i++) {
                if ($path1[$i] -ceq $directorySeparator) {
                    [void] $relPath.Append("..$directorySeparator")
                }
            }
            ## Same path except that path1 ended with a file name and path2 didn't
            if ($relPath.Length -ceq 0 -and $path2.Length - 1 -ceq $si) {
                return ".$directorySeparator" ## Truncate the file name
            }
            return $relPath.Append($path2.Substring($si + 1)).ToString()
        }
    }

    process {
        foreach ($InputObject in $InputObjects) {
            if (!$WorkingDirectory.EndsWith($DirectorySeparator)) { $WorkingDirectory += $DirectorySeparator }
            [string] $RelativePath = '.{0}{1}' -f $DirectorySeparator, (PathDifference $WorkingDirectory $InputObject $CompareCase $DirectorySeparator)
            Write-Output $RelativePath
        }
    }
}
