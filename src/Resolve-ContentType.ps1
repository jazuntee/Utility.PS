<#
.SYNOPSIS
    Parse content type

.EXAMPLE
    PS >Resolve-ContentType "A string with base64 encoding"

    Parse data type

.INPUTS
    System.Object

.LINK
    https://github.com/jasoth/Utility.PS
#>
function Resolve-ContentType {
    [CmdletBinding()]
    [Alias('Parse-ContentType')]
    [OutputType()]
    param (
        # Value to parse
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object] $InputObject,
        # Content types to check
        [Parameter(Mandatory = $false)]
        [ValidateSet('Guid','Uri','DirectoryPath','FilePath','Json','Xml')]
        [string[]] $ContentChecks,
        # Decode if possible
        [Parameter(Mandatory = $false)]
        [ValidateSet('HexadecimalString', 'Base64String', 'Base64UrlString')]
        [string[]] $Decode
    )

    begin {
        function New-ContentTypeOutput ($ContentValue, $ContentType) {
            if (!$ContentType) { $ContentType = $ContentValue.GetType() }
            return [pscustomobject][ordered]@{
                #InputValue         = $null
                #InputType         = $null
                #InputEncoding = $null
                ContentType     = $ContentType
                ContentValue  = $ContentValue
                #ContentEncoding  = $null
                #ContentString = $null
                DecodedContent   = $null
            }
        }

        ## Create list to capture byte stream from piped input.
        [System.Collections.Generic.List[byte]] $listBytes = New-Object System.Collections.Generic.List[byte]
    }

    process {
        if ($InputObject -is [uri]) {
            $InputData = Invoke-RestMethod $InputObject
            $InputObject = $InputData
        }
        elseif ($InputObject -is [System.IO.FileInfo]) {
            $Encoding = Get-ContentEncoding $InputObject.FullName
            if ($Encoding.Name -eq 'Binary') {
                [byte[]]$InputData = Get-Content $InputObject -AsByteStream
            }
            else {
                [string]$InputData = Get-Content $InputObject -Raw
            }
            $InputObject = $InputData
        }
        
        [bool] $ContentTypeDetected = $false
        if ($InputObject -is [string]) {
            if (!$ContentChecks -or $ContentChecks -contains 'Guid') {
                ## GUID RegEx: '^[{(]?[A-Fa-f0-9]{8}-?[A-Fa-f0-9]{4}-?[A-Fa-f0-9]{4}-?[A-Fa-f0-9]{4}-?[A-Fa-f0-9]{12}[)}]?$'
                [guid] $guid = [guid]::Empty
                if ([guid]::TryParse($InputObject, [ref]$guid)) {
                    $Output = New-ContentTypeOutput $guid
                    #$Output.InputValue = $InputObject
                    #$Output.InputType = $InputObject.GetType()
                    #$Output.ContentType = $guid.GetType()
                    #$Output.ContentValue = $guid
                    Write-Output $Output
                    $ContentTypeDetected = $true
                }
            }

            if (!$ContentChecks -or $ContentChecks -contains 'Uri') {
                ## URI RegEx: '^[A-Za-z0-9\-._~:/?#[\]@!$&''()*+,;=]+://[A-Za-z0-9\-._~:/?#[\]@!$&''()*+,;=]+$'
                if ([uri]::IsWellFormedUriString($InputObject, [System.UriKind]::Absolute)) {
                    [uri] $uri = $InputObject
                    $Output = New-ContentTypeOutput $uri
                    #$Output.InputValue = $InputObject
                    #$Output.InputType = $InputObject.GetType()
                    #$Output.ContentType = $uri.GetType()
                    #$Output.ContentValue = $uri
                    Write-Output $Output
                    $ContentTypeDetected = $true
                }
            }

            if (!$ContentChecks -or $ContentChecks -contains 'DirectoryPath' -or $ContentChecks -contains 'FilePath') {
                $InvalidPathChars = ([System.IO.Path]::GetInvalidPathChars() | ForEach-Object { '\u{0:X4}' -f [int]$_ }) -join ''
                $InvalidFileNameChars = ([System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object { '\u{0:X4}' -f [int]$_ }) -join ''
                $PathRegEx = '^(?![A-Za-z0-9\-._~:/?#[\]@!$&''()*+,;=]+://)[^{0}]*[\\/][^{1}]+$' -f $InvalidPathChars, $InvalidFileNameChars
                if ($InputObject -match $PathRegEx) {
                    $Output = New-ContentTypeOutput
                    #$Output.InputValue = $InputObject
                    #$Output.InputType = $InputObject.GetType()

                    $FileRegEx = '[\\/](?!.*[\\/])[^{0}]+\.(?!\.*$)[^{0}]*[^\\/]$' -f $InvalidFileNameChars
                    if ($InputObject -match $FileRegEx) {
                        [System.IO.FileInfo] $FileInfo = $InputObject
                        $Output = New-ContentTypeOutput $FileInfo
                        #$Output.ContentType = $FileInfo.GetType()
                        #$Output.ContentValue = $FileInfo
                        if ($FileInfo.Extension -eq '') {
                            ## Resolve common extensions?
                        }
                        elseif ($FileInfo.Exists) {
                            $Output.ContentEncoding = Get-ContentEncoding $FileInfo.FullName
                        }
                    }
                    else {
                        [System.IO.DirectoryInfo] $DirectoryInfo = $InputObject
                        $Output = New-ContentTypeOutput $DirectoryInfo
                        #$Output.ContentType = $DirectoryInfo.GetType()
                        #$Output.ContentValue = $DirectoryInfo
                    }
                    Write-Output $Output
                    $ContentTypeDetected = $true

                    # if ($Output.ContentValue -is [System.IO.FileInfo] -and $Output.ContentValue.Exists) {
                    #     Resolve-ContentType $Output.ContentValue
                    # }
                }
            }

            if (!$ContentChecks -or $ContentChecks -contains 'Json') {
                if ($InputObject -match '^[[{][\S\s]*[}\]]$') {
                    $json = $InputObject | ConvertFrom-Json -Depth 100
                    $Output = New-ContentTypeOutput $json 'application/json'
                    #$Output.InputValue = $InputObject
                    #$Output.InputType = $InputObject.GetType()
                    #$Output.ContentType = 'application/json'
                    #$Output.ContentValue = $json
                    Write-Output $Output
                    $ContentTypeDetected = $true
                }
            }

            ## Add xml and html checks

            ## Decode binary-to-text encoded strings
            if (!$ContentTypeDetected) {
                $Output = New-ContentTypeOutput $InputObject
                #$Output.ContentValue = $InputObject
                #$Output.ContentType = $InputObject.GetType()

                [byte[]] $bytes = $null
                switch -Regex ($InputObject) {
                    '^[A-Fa-f0-9\r\n]+$' {
                        $bytes = ConvertFrom-HexString $InputObject -RawBytes
                        $Output.ContentType = 'HexadecimalString'
                        #$Output.ContentEncoding = 'HexadecimalString'
                        break
                    }
                    '^(?:[A-Za-z0-9+/\r\n]{4})*(?:[A-Za-z0-9+/\r\n]{2}==|[A-Za-z0-9+/\r\n]{3}=)?$' {
                        $bytes = ConvertFrom-Base64String $InputObject -RawBytes
                        $Output.ContentType = 'Base64String'
                        #$Output.ContentEncoding = 'Base64String'
                        break
                    }
                    '^[A-Za-z0-9-_\r\n]*$' {
                        $bytes = ConvertFrom-Base64String $InputObject -RawBytes -Base64Url
                        $Output.ContentType = 'Base64UrlString'
                        #$Output.ContentEncoding = 'Base64UrlString'
                        break
                    }
                }

                if ($bytes) {
                    $Output.DecodedContent = Resolve-ContentType $bytes
                    Write-Output $Output
                }
            }
        }
        elseif ($InputObject -is [byte[]]) {

            if (!$ContentChecks -or $ContentChecks -contains 'Guid') {
                if ($InputObject.Count -eq 16) {
                    [guid] $guid = $InputObject
                    $Output = New-ContentTypeOutput $guid
                    #$Output.InputValue = $InputObject
                    #$Output.InputType = $InputObject.GetType()
                    #$Output.ContentEncoding = Get-ContentEncoding $InputObject
                    #$Output.ContentType = $guid.GetType()
                    #$Output.ContentValue = $guid
                    #$Output.ContentString = [System.Text.Encoding]::UTF8.GetString($InputObject)
                    Write-Output $Output
                    $ContentTypeDetected = $true
                }
            }

            if (!$ContentChecks -or $ContentChecks -contains 'Certificate') {
                if ($InputObject[0] -eq ([byte]0x30) -and $InputObject[1] -eq ([byte]0x82)) {
                    $Certificate = Get-X509Certificate $InputObject
                    $Output = New-ContentTypeOutput $Certificate
                    #$Output.InputValue = $InputObject
                    #$Output.InputType = $InputObject.GetType()
                    #$Output.ContentEncoding = Get-ContentEncoding $InputObject
                    #$Output.ContentType = $Certificate.GetType()
                    #$Output.ContentValue = $Certificate
                    #$Output.ContentString = [System.Text.Encoding]::UTF8.GetString($InputObject)
                    Write-Output $Output
                    $ContentTypeDetected = $true
                }
            }

            if (!$ContentTypeDetected) {
                $Encoding = Get-ContentEncoding $InputObject
                #$Output = New-ContentTypeOutput
                #$Output.InputValue = $InputObject
                #$Output.InputType = $InputObject.GetType()
                #$Output.InputEncoding = $Encoding
                if ($Encoding.Name -eq 'Binary') {
                    $Output = New-ContentTypeOutput $InputObject
                    #$Output.ContentEncoding = $Encoding
                    #$Output.ContentType = $InputObject.GetType()
                    #$Output.ContentValue = $InputObject
                    #$Output.ContentString = [System.Text.Encoding]::UTF8.GetString($InputObject)
                    Write-Output $Output
                }
                else {
                    $TextEncoding = $Encoding.TextEncoding
                    if ($TextEncoding) {
                        $String = [System.Text.Encoding]::$TextEncoding.GetString($InputObject)
                    }
                    else {
                        $String = [System.Text.Encoding]::UTF8.GetString($InputObject)
                    }
                    #$Output.ContentEncoding = $Encoding
                    #$Output.ContentType = $String.GetType()
                    #$Output.ContentValue = $String
                    #$Output.ContentString = [System.Text.Encoding]::UTF8.GetString($InputObject)
                    #Write-Output $Output
                    Resolve-ContentType $String
                }
            }

        }

        return #$Output

        # if ($InputObjects -is [byte[]]) {
        #     Write-Output (Transform $InputObjects)
        # }
        # else {
        #     foreach ($InputObject in $InputObjects) {
        #         [byte[]] $InputBytes = $null
        #         if ($InputObject -is [byte]) {
        #             ## Populate list with byte stream from piped input.
        #             if ($listBytes.Count -eq 0) {
        #                 Write-Verbose 'Creating byte array from byte stream.'
        #                 Write-Warning ('For better performance when piping a single byte array, use "Write-Output $byteArray -NoEnumerate | {0}".' -f $MyInvocation.MyCommand)
        #             }
        #             $listBytes.Add($InputObject)
        #         }
        #         elseif ($InputObject -is [byte[]]) {
        #             $InputBytes = $InputObject
        #         }
        #         elseif ($InputObject -is [string]) {
        #             $InputBytes = [Text.InputEncoding]::$Encoding.GetBytes($InputObject)
        #         }
        #         elseif ($InputObject -is [bool] -or $InputObject -is [char] -or $InputObject -is [single] -or $InputObject -is [double] -or $InputObject -is [int16] -or $InputObject -is [int32] -or $InputObject -is [int64] -or $InputObject -is [uint16] -or $InputObject -is [uint32] -or $InputObject -is [uint64]) {
        #             $InputBytes = [System.BitConverter]::GetBytes($InputObject)
        #         }
        #         elseif ($InputObject -is [guid]) {
        #             $InputBytes = $InputObject.ToByteArray()
        #         }
        #         elseif ($InputObject -is [System.IO.FileSystemInfo]) {
        #             if ($PSVersionTable.PSVersion -ge [version]'6.0') {
        #                 $InputBytes = Get-Content $InputObject.FullName -Raw -AsByteStream
        #             }
        #             else {
        #                 $InputBytes = Get-Content $InputObject.FullName -Raw -Encoding Byte
        #             }
        #         }
        #         else {
        #             ## Non-Terminating Error
        #             $Exception = New-Object ArgumentException -ArgumentList ('Cannot convert input of type {0} to Base64 string.' -f $InputObject.GetType())
        #             Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::ParserError) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'ConvertBase64StringFailureTypeNotSupported' -TargetObject $InputObject
        #         }

        #         if ($null -ne $InputBytes -and $InputBytes.Count -gt 0) {
        #             Write-Output (Transform $InputBytes)
        #         }
        #     }
        # }
    }

    end {
        ## Output captured byte stream from piped input.
        # if ($listBytes.Count -gt 0) {
        #     Write-Output (Transform $listBytes.ToArray())
        # }
    }
}
