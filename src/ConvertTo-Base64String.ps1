<#
.SYNOPSIS
    Convert Byte Array or Plain Text String to Base64 String.

.EXAMPLE
    PS >ConvertTo-Base64String "A string with base64 encoding"

    Convert String with Default Encoding to Base64 String.

.EXAMPLE
    PS >"ASCII string with base64url encoding" | ConvertTo-Base64String -Base64Url -Encoding Ascii

    Convert String with Ascii Encoding to Base64Url String.

.EXAMPLE
    PS >ConvertTo-Base64String ([guid]::NewGuid())

    Convert GUID to Base64 String.

.INPUTS
    System.Object
    
.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertTo-Base64String {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Value to convert
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object] $InputObjects,
        # Use base64url variant
        [Parameter (Mandatory = $false)]
        [switch] $Base64Url,
        # Output encoding to use for text strings
        [Parameter (Mandatory = $false)]
        [ValidateSet('Ascii', 'UTF32', 'UTF7', 'UTF8', 'BigEndianUnicode', 'Unicode')]
        [string] $Encoding = 'Default'
    )

    begin {
        function Transform ([byte[]]$InputBytes) {
            [string] $outBase64String = [System.Convert]::ToBase64String($InputBytes)
            if ($Base64Url) { $outBase64String = $outBase64String.Replace('+', '-').Replace('/', '_').Replace('=', '') }
            return $outBase64String
        }

        ## Create list to capture byte stream from piped input.
        [System.Collections.Generic.List[byte]] $listBytes = New-Object System.Collections.Generic.List[byte]
    }

    process {
        if ($InputObjects -is [byte[]]) {
            Write-Output (Transform $InputObjects)
        }
        else {
            foreach ($InputObject in $InputObjects) {
                [byte[]] $InputBytes = $null
                if ($InputObject -is [byte]) {
                    ## Populate list with byte stream from piped input.
                    if ($listBytes.Count -eq 0) {
                        Write-Verbose 'Creating byte array from byte stream.'
                        Write-Warning ('For better performance when piping a single byte array, use "Write-Output $byteArray -NoEnumerate | {0}".' -f $MyInvocation.MyCommand)
                    }
                    $listBytes.Add($InputObject)
                }
                elseif ($InputObject -is [byte[]]) {
                    $InputBytes = $InputObject
                }
                elseif ($InputObject -is [string]) {
                    $InputBytes = [Text.Encoding]::$Encoding.GetBytes($InputObject)
                }
                elseif ($InputObject -is [bool] -or $InputObject -is [char] -or $InputObject -is [single] -or $InputObject -is [double] -or $InputObject -is [int16] -or $InputObject -is [int32] -or $InputObject -is [int64] -or $InputObject -is [uint16] -or $InputObject -is [uint32] -or $InputObject -is [uint64]) {
                    $InputBytes = [System.BitConverter]::GetBytes($InputObject)
                }
                elseif ($InputObject -is [guid]) {
                    $InputBytes = $InputObject.ToByteArray()
                }
                elseif ($InputObject -is [System.IO.FileSystemInfo]) {
                    if ($PSVersionTable.PSVersion -ge [version]'6.0') {
                        $InputBytes = Get-Content $InputObject.FullName -Raw -AsByteStream
                    }
                    else {
                        $InputBytes = Get-Content $InputObject.FullName -Raw -Encoding Byte
                    }
                }
                else {
                    ## Non-Terminating Error
                    $Exception = New-Object ArgumentException -ArgumentList ('Cannot convert input of type {0} to Base64 string.' -f $InputObject.GetType())
                    Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::ParserError) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'ConvertBase64StringFailureTypeNotSupported' -TargetObject $InputObject
                }

                if ($null -ne $InputBytes -and $InputBytes.Count -gt 0) {
                    Write-Output (Transform $InputBytes)
                }
            }
        }
    }

    end {
        ## Output captured byte stream from piped input.
        if ($listBytes.Count -gt 0) {
            Write-Output (Transform $listBytes.ToArray())
        }
    }
}
