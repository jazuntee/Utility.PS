<#
.SYNOPSIS
    Get X509 certificate extension 2.5.29.31 for CRL Distribution Points.

.EXAMPLE
    PS >Get-X509CertificateCrlDistributionPoints $Certificate

    Get certificate CRL Distribution Points extension.

.INPUTS
    System.Security.Cryptography.X509Certificates.X509Certificate2

.LINK
    https://github.com/jasoth/Utility.PS
#>
function Get-X509CertificateCrlDistributionPoints {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # X.509 Certificate
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2[]] $X509Certificate
    )

    process {
        foreach ($Certificate in $X509Certificate) {

            $ExtCrlDistributionPoints = $Certificate.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.31' }

            if ($null -eq $ExtCrlDistributionPoints -or $null -eq $ExtCrlDistributionPoints.RawData -or $ExtCrlDistributionPoints.RawData.Length -lt 11) {
                continue
            }

            [int] $prev = -2
            [System.Collections.Generic.List[string]] $items = New-Object 'System.Collections.Generic.List[string]'
            while ($prev -ne -1 -and $ExtCrlDistributionPoints.RawData.Length -gt $prev + 1) {
                [int] $startIndex = if ($prev -eq -2) { 8 } else { $prev + 1 }
                [int] $next = [System.Array]::IndexOf($ExtCrlDistributionPoints.RawData, [byte]0x86, $startIndex)
                if ($next -eq -1) {
                    if ($prev -ge 0) {
                        [string] $item = [System.Text.Encoding]::UTF8.GetString($ExtCrlDistributionPoints.RawData, $prev + 2, $ExtCrlDistributionPoints.RawData.Length - ($prev + 2))
                        $items.Add($item)
                    }
                    break
                }

                if ($prev -ge 0 -and $next -gt $prev) {
                    [string] $item = [System.Text.Encoding]::UTF8.GetString($ExtCrlDistributionPoints.RawData, $prev + 2, $next - ($prev + 2))
                    $items.Add($item)
                }

                $prev = $next
            }

            Write-Output $items.ToArray()
        }
    }
}
