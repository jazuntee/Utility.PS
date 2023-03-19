<#
.SYNOPSIS
    Get content encoding of byte array for file

.EXAMPLE
    PS >Get-ContentEncoding ([byte[]](0xFE, 0xFF, 0x00, 0x00))

    Get content encoding of byte array.

.EXAMPLE
    PS >Get-ContentEncoding 'file.txt'
    
    Get content encoding of file.

.INPUTS
    System.Object

.LINK
    https://github.com/jasoth/Utility.PS
#>
function Get-ContentEncoding {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        # Content represented as byte array
        [Parameter(Mandatory = $true, ParameterSetName = 'ByteArray', Position = 0, ValueFromPipeline = $true)]
        [byte[]] $InputBytes,
        # Content file path
        [Parameter(Mandatory = $true, ParameterSetName = 'File', Position = 0)]
        [string] $Path,
        # Number of bytes to read from beginning of file
        [Parameter(Mandatory = $false, ParameterSetName = 'File')]
        [int] $NumberOfBytesToRead = 8000
    )

    begin {
        function New-ContentEncodingOutput ($Encoding) {
            $Output = [pscustomobject][ordered]@{
                CodePage     = $null
                Name         = $null
                DisplayName  = $null
                TextEncoding = $null
            }
            if ($Encoding -is [System.Text.Encoding]) {
                $Output.CodePage = $Encoding.CodePage
                $Output.Name = $Encoding.WebName
                $Output.DisplayName = $Encoding.EncodingName
                $Output.TextEncoding = $Encoding
            }
            else {
                $Output.Name = $Output.DisplayName = $Encoding
            }
            return $Output
        }

        $CriticalError = $null
        if ($PSCmdlet.ParameterSetName -eq 'File') {
            [byte[]] $InputBytes = $null
            if (Resolve-Path $Path -ErrorVariable CriticalError) {
                #Get-Content $Path -AsByteStream -ReadCount $NumberOfBytesToRead
                $FileStream = [System.IO.File]::OpenRead($Path)
                try {
                    $BinaryReader = New-Object System.IO.BinaryReader -ArgumentList $FileStream
                    $InputBytes = $BinaryReader.ReadBytes($NumberOfBytesToRead)
                }
                finally {
                    $FileStream.Close()
                }
            }
        }
        
        ## Intialize
        $EncodingInfo = [System.Text.Encoding]::GetEncodings()
        [System.Collections.Generic.List[System.Text.Encoding]] $listEncodings = $EncodingInfo.GetEncoding() | Where-Object { $_.GetPreamble() } | Sort-Object { $_.GetPreamble().Count } -Descending
        [int] $MaxPreambleCount = $listEncodings[0].GetPreamble().Count

        Set-Variable NullByte -Option Constant -Value ([byte]0x00)
        [bool] $ContainsNull = $false
        [int] $Position = 0
    }

    process {
        if ($CriticalError) { return }

        foreach ($byte in $InputBytes) {
            ## Break out of loop if null was found and any potential preambles are complete
            if ($ContainsNull -eq $true -and $Position -ge $MaxPreambleCount) { return }

            ## Check for BOM preamble to determine text encoding
            if ($Position -lt $MaxPreambleCount) {
                for ($i = 0; $i -lt $listEncodings.Count; $i++) {
                    [byte[]]$Preamble = $listEncodings[$i].GetPreamble()
                    if ($Position -lt $Preamble.Count -and $byte -ne $Preamble[$Position]) {
                        $listEncodings.RemoveAt($i)
                        $i--
                    }
                }
            }

            ## Check for null byte as it could mean binary data
            if ($byte.Equals($NullByte)) {
                $ContainsNull = $true
            }
            
            ## Advance position
            $Position++
        }
    }

    end {
        if ($CriticalError) { return }

        ## Produce output object
        if ($listEncodings.Count -gt 0) {
            New-ContentEncodingOutput $listEncodings[0]
        }
        elseif ($ContainsNull) {
            New-ContentEncodingOutput 'Binary'
        }
        else {
            New-ContentEncodingOutput 'Unknown'
        }
    }
}
