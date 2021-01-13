<#
.SYNOPSIS
    Replace characters with diacritics to their non-diacritic equivilent.
.DESCRIPTION

.EXAMPLE
    PS C:\>Remove-Diacritics 'àáâãäåÀÁÂÃÄÅ'
    Replace characters with diacritics to their non-diacritic equivilent.
.INPUTS
    System.String
.NOTES
    This command has not been validated to remove all diacritics.
#>
function Remove-Diacritics {
    [CmdletBinding()]
    param
    (
        # String value to transform.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [string[]] $InputStrings
    )

    process {
        foreach ($InputString in $InputStrings) {
            $NormalizedString = $InputString.Normalize([System.Text.NormalizationForm]::FormD)
            $OutputString = New-Object System.Text.StringBuilder

            foreach ($char in $NormalizedString.ToCharArray()) {
                if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($char) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                    [void]$OutputString.Append($char)
                }
            }

            Write-Output $OutputString.ToString()
        }
    }
}
