[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = ".\src\*.psd1"
)

BeforeAll {
    $CriticalError = $null
    $PSModule = Import-Module $ModulePath -Force -PassThru -ErrorVariable CriticalError
    if ($CriticalError) { throw $CriticalError }
}

Describe 'Get-X509Certificate' {

    BeforeAll {
        ## Stage Input Data
        [string] $Base64Cert = 'MIIFmTCCA4GgAwIBAgIQea0WoUqgpa1Mc1j0BxMuZTANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZImiZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQDEyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMDEwNTA5MjMxOTIyWhcNMjEwNTA5MjMyODEzWjBfMRMwEQYKCZImiZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQDEyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDzXfqAZ9Rap6kMLJAg0DUIPHWEzbcHiZyJ2t7Ow2D6kWhanpRxKRh2fMLgyCV2lA5Y+gQ0Nubfr/eAuulYCyuT5Z0F43cikfc0ZDwikR1e4QmQvBT+/HVYGeF5tweSo66IWQjYnwfKA1j8aCltMtfSqMtL/OELSDJP5uu4rU/kXG8TlJnbldV126gat5SRtHdb9UgMj2p5fRRwBH1tr5D12nDYR7e/my9s5wW34RFgrHmRFHzF1qbk4X7Vw37lktI8ALU2gt554W3ztW74nzPJy1J9c5g224uha6KVl5uj3sJNJv8GlmclBsjnrOTuEjOVMZnINQhONMp5U9W1vmMyWUA2wKVOBE0921sHM+RYv+8/U2TYQlk1V/0PRXwkBE2e1jh0EZcikM5oRHSSb9VLb7CG48c2QqDQ/MHAWvmjYbkwR3GWChawkcBCle8Qfyhq4yofseTNAz93cQTHIPxJDx1FiKTXy36IrY4t7EXbxFEEySr87IaemhGXW97OU4jm4rf9rJXCKEDb7wSQ34EzOdmyRaUjhwalVYkxuwYtYA5BGH0fLrWXyxHrFdUkpZTvFRSJ/Utz+jJb/NEzAPlZYnAHMuouq0Ate8rdIWcbMJmPFqojqEHRsG4RmzbE3kB0nOFYZcFgHnpbOMiPuwQmfNQWQOW2a2yqhv0Av87BNQIDAQABo1EwTzALBgNVHQ8EBAMCAcYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUDqyCYEBWJ5flJRP8KuEKU5VZ5KQwEAYJKwYBBAGCNxUBBAMCAQAwDQYJKoZIhvcNAQEFBQADggIBAMURTQM6YN1dUhF3j7K7NsiyBb+0t6jYIJ1cEwO2HCL6BhM1tshj1JpHbyZX0lXxBLEmX9apUGigvNK4bszD6azfGc14rFl0rGY0NsQbPmw4TDMOMBINoyb+UVMA/69aToQNDx/kbQUuToVLjWwzb1TSZKu/UK99ejmgN+1jAw/8EwbOFjbUVDuVG1FiOuVNF9QFOZKaJ6hbqr3su77jIIlgcWxWs6UT0G0OI36VA+1oPfLYY7hrTbboMLXhypRL96KqXZkwsj2nwlFsKCABJCcrSwC3nRFrcL6yEIK8DJto0I07JIeqmShynTNfWZC99d6TnjpiWjQ54ohVHbkGsMGJay3XacMZEjaE0Mmg2v8vaXiy5Xra69cMwPe9Yxe4ORM4ojZbe/KFVmodZGLBOOKqv1FmopT1EpxmIhBr8rcwki3yKfA9OxRDaKLxnCk3y844ICVtfGfzfiQSJAMIgUfspZ6X9RjXz7vV73aW7/3O21adlaBC+ZdY4dcxItNfWeY+biIA6kOEtiXb2fMIVmjAZGsdfOy2k6JiV24u2OdYj8QxSSbd3ik1h/UwcXBbFDxpvYkSfesuo/7Yf56CWlIKK8FDK9kwiJ/IEPuJjeahhXUzfmye23MTZGJppS99ypZtn/gETTCSPW4hFCHJPeDD/YprnUr90aGdmUN3P7Da'
        [string] $Base64CertThumbnail = 'CDD4EEAE6000AC7F40C3802C171E30148030C072'
        [byte[]] $DERCert = @(48, 130, 5, 237, 48, 130, 3, 213, 160, 3, 2, 1, 2, 2, 16, 40, 204, 58, 37, 191, 186, 68, 172, 68, 154, 155, 88, 107, 67, 57, 170, 48, 13, 6, 9, 42, 134, 72, 134, 247, 13, 1, 1, 11, 5, 0, 48, 129, 136, 49, 11, 48, 9, 6, 3, 85, 4, 6, 19, 2, 85, 83, 49, 19, 48, 17, 6, 3, 85, 4, 8, 19, 10, 87, 97, 115, 104, 105, 110, 103, 116, 111, 110, 49, 16, 48, 14, 6, 3, 85, 4, 7, 19, 7, 82, 101, 100, 109, 111, 110, 100, 49, 30, 48, 28, 6, 3, 85, 4, 10, 19, 21, 77, 105, 99, 114, 111, 115, 111, 102, 116, 32, 67, 111, 114, 112, 111, 114, 97, 116, 105, 111, 110, 49, 50, 48, 48, 6, 3, 85, 4, 3, 19, 41, 77, 105, 99, 114, 111, 115, 111, 102, 116, 32, 82, 111, 111, 116, 32, 67, 101, 114, 116, 105, 102, 105, 99, 97, 116, 101, 32, 65, 117, 116, 104, 111, 114, 105, 116, 121, 32, 50, 48, 49, 48, 48, 30, 23, 13, 49, 48, 48, 54, 50, 51, 50, 49, 53, 55, 50, 52, 90, 23, 13, 51, 53, 48, 54, 50, 51, 50, 50, 48, 52, 48, 49, 90, 48, 129, 136, 49, 11, 48, 9, 6, 3, 85, 4, 6, 19, 2, 85, 83, 49, 19, 48, 17, 6, 3, 85, 4, 8, 19, 10, 87, 97, 115, 104, 105, 110, 103, 116, 111, 110, 49, 16, 48, 14, 6, 3, 85, 4, 7, 19, 7, 82, 101, 100, 109, 111, 110, 100, 49, 30, 48, 28, 6, 3, 85, 4, 10, 19, 21, 77, 105, 99, 114, 111, 115, 111, 102, 116, 32, 67, 111, 114, 112, 111, 114, 97, 116, 105, 111, 110, 49, 50, 48, 48, 6, 3, 85, 4, 3, 19, 41, 77, 105, 99, 114, 111, 115, 111, 102, 116, 32, 82, 111, 111, 116, 32, 67, 101, 114, 116, 105, 102, 105, 99, 97, 116, 101, 32, 65, 117, 116, 104, 111, 114, 105, 116, 121, 32, 50, 48, 49, 48, 48, 130, 2, 34, 48, 13, 6, 9, 42, 134, 72, 134, 247, 13, 1, 1, 1, 5, 0, 3, 130, 2, 15, 0, 48, 130, 2, 10, 2, 130, 2, 1, 0, 185, 8, 158, 40, 228, 228, 236, 6, 78, 80, 104, 179, 65, 197, 123, 235, 174, 182, 142, 175, 129, 186, 34, 68, 31, 101, 52, 105, 76, 190, 112, 64, 23, 242, 22, 123, 226, 121, 253, 134, 237, 13, 57, 244, 27, 168, 173, 146, 144, 30, 203, 61, 118, 143, 90, 217, 181, 145, 16, 46, 60, 5, 141, 138, 109, 36, 84, 231, 31, 237, 86, 173, 131, 180, 80, 156, 21, 165, 23, 116, 136, 89, 32, 252, 8, 197, 132, 118, 211, 104, 212, 111, 40, 120, 206, 92, 184, 243, 80, 144, 68, 255, 227, 99, 95, 190, 161, 154, 44, 150, 21, 4, 214, 7, 254, 30, 132, 33, 224, 66, 49, 17, 196, 40, 54, 148, 207, 80, 164, 98, 158, 201, 214, 171, 113, 0, 178, 91, 12, 230, 150, 212, 10, 36, 150, 245, 255, 198, 213, 183, 27, 215, 203, 183, 33, 98, 175, 18, 220, 161, 93, 55, 227, 26, 251, 26, 70, 152, 192, 155, 192, 231, 99, 31, 42, 8, 147, 2, 126, 30, 106, 142, 242, 159, 24, 137, 228, 34, 133, 162, 177, 132, 87, 64, 255, 245, 14, 216, 111, 156, 237, 226, 69, 49, 1, 205, 23, 233, 127, 176, 129, 69, 227, 170, 33, 64, 38, 161, 114, 170, 167, 79, 60, 1, 5, 126, 238, 131, 88, 177, 94, 6, 99, 153, 98, 145, 120, 130, 183, 13, 147, 12, 36, 106, 180, 27, 219, 39, 236, 95, 149, 4, 63, 147, 74, 48, 245, 151, 24, 179, 167, 249, 25, 167, 147, 51, 29, 1, 200, 219, 34, 82, 92, 215, 37, 201, 70, 249, 162, 251, 135, 89, 67, 190, 155, 98, 177, 141, 45, 134, 68, 26, 70, 172, 120, 97, 126, 48, 9, 250, 174, 137, 196, 65, 42, 34, 102, 3, 145, 57, 69, 156, 199, 139, 12, 168, 202, 13, 47, 251, 82, 234, 12, 247, 99, 51, 35, 157, 254, 176, 31, 173, 103, 214, 167, 80, 3, 198, 4, 112, 99, 181, 44, 177, 134, 90, 67, 183, 251, 174, 249, 110, 41, 110, 33, 33, 65, 38, 6, 140, 201, 195, 238, 176, 194, 133, 147, 161, 185, 133, 217, 230, 50, 108, 75, 76, 63, 214, 93, 163, 229, 181, 157, 119, 195, 156, 192, 85, 183, 116, 0, 227, 184, 56, 171, 131, 151, 80, 225, 154, 66, 36, 29, 198, 192, 163, 48, 209, 26, 90, 200, 82, 52, 247, 115, 241, 199, 24, 31, 51, 173, 122, 236, 203, 65, 96, 243, 35, 148, 32, 194, 72, 69, 172, 92, 81, 198, 46, 128, 194, 226, 119, 21, 189, 133, 135, 237, 54, 157, 150, 145, 238, 0, 181, 163, 112, 236, 159, 227, 141, 128, 104, 131, 118, 186, 175, 93, 112, 82, 34, 22, 226, 102, 251, 186, 179, 197, 194, 247, 62, 47, 119, 166, 202, 222, 193, 166, 198, 72, 76, 195, 55, 81, 35, 211, 39, 215, 184, 78, 112, 150, 240, 161, 68, 118, 175, 120, 207, 154, 225, 102, 19, 2, 3, 1, 0, 1, 163, 81, 48, 79, 48, 11, 6, 3, 85, 29, 15, 4, 4, 3, 2, 1, 134, 48, 15, 6, 3, 85, 29, 19, 1, 1, 255, 4, 5, 48, 3, 1, 1, 255, 48, 29, 6, 3, 85, 29, 14, 4, 22, 4, 20, 213, 246, 86, 203, 143, 232, 162, 92, 98, 104, 209, 61, 148, 144, 91, 215, 206, 154, 24, 196, 48, 16, 6, 9, 43, 6, 1, 4, 1, 130, 55, 21, 1, 4, 3, 2, 1, 0, 48, 13, 6, 9, 42, 134, 72, 134, 247, 13, 1, 1, 11, 5, 0, 3, 130, 2, 1, 0, 172, 165, 150, 140, 191, 187, 174, 166, 246, 215, 113, 135, 67, 49, 86, 136, 253, 28, 50, 113, 91, 53, 183, 212, 240, 145, 242, 175, 55, 226, 20, 241, 243, 2, 38, 5, 62, 22, 20, 127, 20, 186, 184, 79, 251, 137, 178, 178, 231, 212, 9, 204, 109, 185, 91, 59, 100, 101, 112, 102, 183, 242, 177, 90, 223, 26, 2, 243, 245, 81, 184, 103, 109, 121, 243, 191, 86, 123, 228, 132, 185, 43, 30, 155, 64, 156, 38, 52, 249, 71, 24, 152, 105, 216, 28, 215, 182, 209, 191, 143, 97, 194, 103, 196, 181, 239, 96, 67, 142, 16, 27, 54, 73, 228, 32, 202, 173, 167, 193, 177, 39, 101, 9, 248, 205, 245, 91, 42, 208, 132, 51, 243, 239, 31, 242, 245, 156, 11, 88, 147, 55, 160, 117, 160, 222, 114, 222, 108, 117, 42, 102, 34, 245, 140, 6, 48, 86, 159, 64, 185, 48, 170, 64, 119, 21, 130, 215, 139, 236, 192, 211, 178, 189, 131, 197, 119, 12, 30, 174, 175, 25, 83, 160, 77, 121, 113, 159, 15, 175, 48, 206, 103, 249, 214, 44, 204, 34, 65, 122, 7, 242, 151, 66, 24, 206, 89, 121, 16, 85, 222, 111, 16, 228, 184, 218, 131, 102, 64, 22, 9, 104, 35, 91, 151, 46, 38, 154, 2, 187, 87, 140, 197, 184, 186, 105, 98, 50, 128, 137, 158, 161, 253, 192, 146, 124, 123, 43, 51, 25, 132, 42, 99, 197, 0, 104, 98, 250, 159, 71, 141, 153, 122, 69, 58, 167, 233, 237, 238, 105, 66, 181, 243, 129, 155, 71, 86, 16, 123, 252, 112, 54, 132, 24, 115, 234, 239, 249, 151, 77, 158, 51, 35, 221, 38, 11, 186, 42, 183, 63, 68, 220, 131, 39, 255, 189, 97, 89, 43, 17, 183, 202, 79, 219, 197, 139, 12, 28, 49, 174, 50, 248, 248, 185, 66, 247, 127, 220, 97, 154, 118, 177, 90, 4, 225, 17, 61, 102, 69, 183, 24, 113, 190, 201, 36, 133, 214, 243, 212, 186, 65, 52, 93, 18, 45, 37, 185, 141, 166, 19, 72, 109, 75, 176, 7, 125, 153, 147, 9, 97, 129, 116, 87, 38, 138, 171, 105, 227, 228, 217, 199, 136, 204, 36, 216, 236, 82, 36, 92, 30, 188, 145, 20, 226, 150, 222, 235, 10, 218, 158, 221, 95, 179, 91, 219, 212, 130, 236, 198, 32, 80, 135, 37, 64, 58, 251, 199, 238, 205, 254, 51, 229, 110, 195, 132, 9, 85, 3, 37, 57, 192, 233, 53, 93, 101, 49, 168, 246, 191, 160, 9, 205, 41, 199, 179, 54, 50, 46, 220, 149, 243, 131, 193, 90, 207, 139, 141, 246, 234, 179, 33, 248, 164, 237, 30, 49, 14, 182, 76, 17, 171, 96, 11, 164, 18, 35, 34, 23, 163, 54, 100, 130, 145, 4, 18, 224, 171, 111, 30, 203, 80, 5, 97, 180, 64, 255, 89, 134, 113, 209, 213, 51, 105, 124, 169, 115, 138, 56, 215, 100, 12, 241, 105)
        [string] $DERCertThumbnail = '3B1EFD3A66EA28B16697394703A72CA340A05BD5'

        Set-Content TestDrive:\Base64Cert.cer -Value @'
-----BEGIN CERTIFICATE-----
MIIF7TCCA9WgAwIBAgIQP4vItfyfspZDtWnWbELhRDANBgkqhkiG9w0BAQsFADCB
iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMp
TWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEw
MzIyMjIwNTI4WhcNMzYwMzIyMjIxMzA0WjCBiDELMAkGA1UEBhMCVVMxEzARBgNV
BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
aWNhdGUgQXV0aG9yaXR5IDIwMTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
AoICAQCygEGqNThNE3IyaCJNuLLx/9VSvGzH9dJKjDbu0cJcfoyKrq8TKG/Ac+M6
ztAlqFo6be+ouFmrEyNozQwph9FvgFyPRH9dkAFSWKxRxV8qh9zc2AodwQO5e7BW
6KPeZGHCnvjzfLnsDbVU/ky2ZU+I8JxImQxCCwl8MVkXeQZ4KI2JOkwDJb5xalwL
54RgpJki49KvhKSn+9GY7Qyp3pSJ4Q6g3MDOmT3qCFK7VnnkH4S6Hri0xElcTzFL
h93dBWcmmYDgcRGjuKVB4qRTufcyKYMME782XgSzS0NHL2vikR7TmE/dQgfI6B0S
/Jmpaz6SfsjWaTr8ZL22CZ3K/QwLopt3YEsDlKQwaRLWQi3BQUzK3Kr9j1uDRprZ
/LHR47PJf0h6zSTwQY9cdNCssBAgBkm3xy0hyFfj0IbzA2j70M5xwYmZSmQBbP3s
MJHPQTySx+W6hh1hhMdfgzlirrSSL0fzC/hV66AfWdC7dJse0Hbm8ukG1xDo+mTe
acY1logC8Ea4PyeZb8txiSk190gWAjWP1Xl8TQLPX+uKg09FcYj5qQ1OcunCnAfP
SRtOBA5jUYxe2ADBVSy2xuDCZU7JNDn1nLPEfuhhbhNfFcRf2X7tHc7uROzLLoax
7Dj2cO2rXBPB2Q8Nx4CyVe0096yb5MPa50c8prWPMd/FS6/r8QIDAQABo1EwTzAL
BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUci06AjGQQ7kU
BU7h6qfHMdEjiTQwEAYJKwYBBAGCNxUBBAMCAQAwDQYJKoZIhvcNAQELBQADggIB
AH9yzw+3xRXbm8BJyiZb/p4T5tPw0tuXX/JLP02zrhmu7deXoKzvqTqjwkGw5biR
nhOBJAPmCf0/V0A5ISRW0RAvS0CpNoZLtFNXmvvxfomPEf4YbFGq6O0JlbXlccmh
6Yd1phV/yX43VF50k8XDZ8wNT2uoFwxtCJJ+i92Bqi1wIcM9BhS7vyRep4TXPw8h
Ir1LAAbblxzYXtTFC1yHblCk6MM4pPvLLMWSZpuFXst6bJN8gClYW1e1QGm6CHmm
ZGIVnYeWRbVmIyADixxzoNOieTPgUFmG2y/lAiXqcyqfABTINseSO+lOAOzYVgm5
M0kS0lQLAausR7aRKX1MtHWAUgHoyoL2n8ysnI8X6i8msKtyrAv+nlEex0NVZ09R
s1fWtuzuUrc66U7h14GIvE+OdbtLqPA1qibUZ2dJsnBMO5PcHd94kIZysjik0dyS
TclY6ysSXNQ7roxrsIPlAT/4CTL2kzU0Iq/dNw13CYArzUgA8YyZGUcFAenRv9FO
0OYoQzeZpApKCNmacXPSqs0xE2N2oTdvkjgefRI8ZjLny23h/FKJ3crWZgWalmG+
oijHHKOnNlA8OqTfSm7mhzvO6/DggTedEzxSjr25HTTGHdUKaj2YKXCMiSrRq4IQ
SB/c9O+lxbtVGjhjhE63bK2VVOxlIhBJF7jAHscPrFRH
-----END CERTIFICATE-----
'@
        [System.IO.FileInfo] $Base64CertFile = Get-Item TestDrive:\Base64Cert.cer
        [string] $Base64CertFileThumbnail = '8F43288AD272F3103B6FB1428485EA3014C0BCFE'

        [byte[]] $DERCertFileContent = @(45, 45, 45, 45, 45, 66, 69, 71, 73, 78, 32, 67, 69, 82, 84, 73, 70, 73, 67, 65, 84, 69, 45, 45, 45, 45, 45, 13, 10, 77, 73, 73, 69, 69, 106, 67, 67, 65, 118, 113, 103, 65, 119, 73, 66, 65, 103, 73, 80, 65, 77, 69, 65, 105, 122, 119, 56, 105, 66, 72, 82, 80, 118, 90, 106, 55, 78, 57, 65, 77, 65, 48, 71, 67, 83, 113, 71, 83, 73, 98, 51, 68, 81, 69, 66, 66, 65, 85, 65, 77, 72, 65, 120, 13, 10, 75, 122, 65, 112, 66, 103, 78, 86, 66, 65, 115, 84, 73, 107, 78, 118, 99, 72, 108, 121, 97, 87, 100, 111, 100, 67, 65, 111, 89, 121, 107, 103, 77, 84, 107, 53, 78, 121, 66, 78, 97, 87, 78, 121, 98, 51, 78, 118, 90, 110, 81, 103, 81, 50, 57, 121, 99, 67, 52, 120, 72, 106, 65, 99, 13, 10, 66, 103, 78, 86, 66, 65, 115, 84, 70, 85, 49, 112, 89, 51, 74, 118, 99, 50, 57, 109, 100, 67, 66, 68, 98, 51, 74, 119, 98, 51, 74, 104, 100, 71, 108, 118, 98, 106, 69, 104, 77, 66, 56, 71, 65, 49, 85, 69, 65, 120, 77, 89, 84, 87, 108, 106, 99, 109, 57, 122, 98, 50, 90, 48, 13, 10, 73, 70, 74, 118, 98, 51, 81, 103, 81, 88, 86, 48, 97, 71, 57, 121, 97, 88, 82, 53, 77, 66, 52, 88, 68, 84, 107, 51, 77, 68, 69, 120, 77, 68, 65, 51, 77, 68, 65, 119, 77, 70, 111, 88, 68, 84, 73, 119, 77, 84, 73, 122, 77, 84, 65, 51, 77, 68, 65, 119, 77, 70, 111, 119, 13, 10, 99, 68, 69, 114, 77, 67, 107, 71, 65, 49, 85, 69, 67, 120, 77, 105, 81, 50, 57, 119, 101, 88, 74, 112, 90, 50, 104, 48, 73, 67, 104, 106, 75, 83, 65, 120, 79, 84, 107, 51, 73, 69, 49, 112, 89, 51, 74, 118, 99, 50, 57, 109, 100, 67, 66, 68, 98, 51, 74, 119, 76, 106, 69, 101, 13, 10, 77, 66, 119, 71, 65, 49, 85, 69, 67, 120, 77, 86, 84, 87, 108, 106, 99, 109, 57, 122, 98, 50, 90, 48, 73, 69, 78, 118, 99, 110, 66, 118, 99, 109, 70, 48, 97, 87, 57, 117, 77, 83, 69, 119, 72, 119, 89, 68, 86, 81, 81, 68, 69, 120, 104, 78, 97, 87, 78, 121, 98, 51, 78, 118, 13, 10, 90, 110, 81, 103, 85, 109, 57, 118, 100, 67, 66, 66, 100, 88, 82, 111, 98, 51, 74, 112, 100, 72, 107, 119, 103, 103, 69, 105, 77, 65, 48, 71, 67, 83, 113, 71, 83, 73, 98, 51, 68, 81, 69, 66, 65, 81, 85, 65, 65, 52, 73, 66, 68, 119, 65, 119, 103, 103, 69, 75, 65, 111, 73, 66, 13, 10, 65, 81, 67, 112, 65, 114, 51, 66, 99, 79, 89, 55, 56, 107, 52, 98, 75, 74, 43, 88, 101, 70, 52, 119, 54, 113, 75, 112, 106, 83, 86, 102, 43, 80, 54, 86, 84, 75, 79, 51, 47, 112, 50, 105, 73, 68, 53, 56, 85, 97, 75, 98, 111, 111, 57, 103, 77, 109, 118, 82, 81, 109, 82, 53, 13, 10, 55, 113, 120, 50, 121, 86, 84, 97, 56, 117, 117, 99, 104, 104, 121, 80, 110, 52, 82, 109, 115, 56, 86, 114, 101, 109, 73, 106, 49, 104, 48, 56, 51, 103, 56, 66, 107, 117, 105, 87, 120, 76, 56, 116, 90, 112, 113, 97, 97, 67, 97, 90, 48, 68, 111, 115, 118, 119, 121, 49, 87, 67, 98, 66, 13, 10, 82, 117, 99, 75, 80, 106, 105, 87, 76, 75, 107, 111, 79, 97, 106, 115, 83, 89, 78, 67, 52, 52, 81, 80, 117, 53, 112, 115, 86, 87, 71, 115, 103, 110, 121, 104, 89, 67, 49, 51, 84, 79, 109, 90, 116, 71, 81, 55, 109, 108, 65, 99, 77, 81, 103, 107, 70, 74, 43, 112, 53, 53, 69, 114, 13, 10, 71, 79, 89, 57, 109, 71, 77, 85, 89, 70, 103, 70, 90, 90, 56, 100, 78, 49, 75, 72, 57, 54, 102, 118, 108, 65, 76, 71, 71, 57, 79, 47, 86, 85, 87, 122, 105, 89, 67, 47, 79, 117, 120, 85, 108, 69, 54, 117, 47, 97, 100, 54, 98, 88, 82, 79, 114, 120, 106, 77, 108, 103, 107, 111, 13, 10, 73, 81, 66, 88, 107, 71, 66, 112, 78, 55, 116, 76, 69, 103, 99, 56, 86, 118, 57, 98, 43, 54, 82, 109, 67, 103, 105, 109, 48, 111, 70, 87, 86, 43, 43, 50, 79, 49, 52, 87, 103, 88, 99, 69, 50, 118, 97, 43, 114, 111, 67, 86, 47, 114, 68, 78, 102, 57, 97, 110, 71, 110, 74, 99, 13, 10, 80, 77, 113, 56, 56, 65, 105, 106, 73, 106, 67, 122, 66, 111, 88, 74, 115, 121, 66, 51, 69, 52, 88, 102, 65, 103, 77, 66, 65, 65, 71, 106, 103, 97, 103, 119, 103, 97, 85, 119, 103, 97, 73, 71, 65, 49, 85, 100, 65, 81, 83, 66, 109, 106, 67, 66, 108, 52, 65, 81, 87, 57, 66, 119, 13, 10, 55, 50, 108, 121, 110, 105, 78, 82, 102, 104, 83, 121, 84, 89, 55, 47, 121, 54, 70, 121, 77, 72, 65, 120, 75, 122, 65, 112, 66, 103, 78, 86, 66, 65, 115, 84, 73, 107, 78, 118, 99, 72, 108, 121, 97, 87, 100, 111, 100, 67, 65, 111, 89, 121, 107, 103, 77, 84, 107, 53, 78, 121, 66, 78, 13, 10, 97, 87, 78, 121, 98, 51, 78, 118, 90, 110, 81, 103, 81, 50, 57, 121, 99, 67, 52, 120, 72, 106, 65, 99, 66, 103, 78, 86, 66, 65, 115, 84, 70, 85, 49, 112, 89, 51, 74, 118, 99, 50, 57, 109, 100, 67, 66, 68, 98, 51, 74, 119, 98, 51, 74, 104, 100, 71, 108, 118, 98, 106, 69, 104, 13, 10, 77, 66, 56, 71, 65, 49, 85, 69, 65, 120, 77, 89, 84, 87, 108, 106, 99, 109, 57, 122, 98, 50, 90, 48, 73, 70, 74, 118, 98, 51, 81, 103, 81, 88, 86, 48, 97, 71, 57, 121, 97, 88, 82, 53, 103, 103, 56, 65, 119, 81, 67, 76, 80, 68, 121, 73, 69, 100, 69, 43, 57, 109, 80, 115, 13, 10, 51, 48, 65, 119, 68, 81, 89, 74, 75, 111, 90, 73, 104, 118, 99, 78, 65, 81, 69, 69, 66, 81, 65, 68, 103, 103, 69, 66, 65, 74, 88, 111, 67, 56, 67, 78, 56, 53, 99, 89, 78, 101, 50, 52, 65, 83, 84, 89, 100, 120, 72, 122, 88, 71, 65, 121, 110, 53, 52, 76, 121, 122, 52, 70, 13, 10, 107, 89, 105, 80, 121, 84, 114, 109, 73, 102, 76, 119, 86, 53, 77, 115, 116, 97, 66, 72, 121, 71, 76, 118, 47, 78, 102, 77, 79, 122, 116, 97, 113, 84, 90, 85, 97, 102, 52, 107, 98, 84, 47, 74, 122, 75, 114, 101, 66, 88, 122, 100, 77, 89, 48, 57, 110, 120, 66, 119, 97, 114, 118, 43, 13, 10, 69, 107, 56, 89, 97, 99, 68, 56, 48, 69, 80, 106, 69, 86, 111, 103, 84, 43, 112, 105, 101, 54, 43, 113, 71, 99, 103, 114, 78, 121, 85, 116, 118, 109, 87, 104, 69, 111, 111, 108, 68, 50, 79, 106, 57, 49, 81, 99, 43, 83, 72, 74, 49, 104, 88, 122, 85, 113, 120, 117, 81, 122, 73, 72, 13, 10, 47, 89, 73, 88, 43, 79, 86, 110, 98, 65, 49, 82, 57, 114, 51, 120, 85, 115, 101, 57, 53, 56, 81, 119, 47, 67, 65, 120, 67, 89, 103, 100, 108, 83, 107, 97, 84, 100, 85, 100, 65, 113, 88, 120, 103, 79, 65, 68, 116, 70, 118, 48, 115, 100, 51, 73, 86, 43, 53, 108, 83, 99, 100, 83, 13, 10, 86, 76, 97, 48, 65, 121, 103, 83, 47, 53, 68, 87, 56, 65, 105, 80, 102, 114, 105, 88, 120, 97, 115, 51, 76, 79, 82, 54, 53, 75, 104, 51, 52, 51, 97, 103, 65, 78, 66, 113, 80, 56, 72, 83, 78, 111, 114, 103, 81, 82, 75, 111, 78, 87, 111, 98, 97, 116, 115, 49, 52, 100, 81, 99, 13, 10, 66, 79, 83, 111, 82, 81, 84, 73, 87, 106, 77, 52, 98, 107, 48, 99, 68, 87, 75, 51, 67, 113, 75, 77, 48, 57, 86, 85, 80, 48, 98, 78, 72, 70, 87, 109, 99, 78, 115, 83, 79, 111, 101, 84, 100, 90, 43, 110, 48, 113, 65, 61, 13, 10, 45, 45, 45, 45, 45, 69, 78, 68, 32, 67, 69, 82, 84, 73, 70, 73, 67, 65, 84, 69, 45, 45, 45, 45, 45, 13, 10)
        if ($PSVersionTable.PSVersion -ge [version]'6.0') {
            Set-Content TestDrive:\DERCert.cer -Value $DERCertFileContent -AsByteStream
        }
        else {
            Set-Content TestDrive:\DERCert.cer -Value $DERCertFileContent -Encoding Byte
        }
        [System.IO.FileInfo] $DERCertFile = Get-Item TestDrive:\DERCert.cer
        [string] $DERCertFileThumbnail = 'A43489159A520F0D93D032CCAF37E7FE20A8B419'
    }
    
    ## Begin Assertions
    It 'parses base64-encoded string' {
        $Base64Cert | Should -BeOfType [System.String]
        $X509Certificate = Get-X509Certificate $Base64Cert
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $Base64CertThumbnail
    }

    It 'parses base64-encoded string via pipeline' {
        $Base64Cert | Should -BeOfType [System.String]
        $X509Certificate = $Base64Cert | Get-X509Certificate
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $Base64CertThumbnail
    }

    It 'parses DER-encoded byte array' {
        Write-Output $DERCert -NoEnumerate | Should -BeOfType [System.Byte[]]
        $X509Certificate = Get-X509Certificate $DERCert
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $DERCertThumbnail
    }

    It 'parses DER-encoded byte array via pipeline' {
        $DERCert | Should -BeOfType [System.Byte]
        $X509Certificate = $DERCert | Get-X509Certificate
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $DERCertThumbnail
    }

    It 'parses DER-encoded byte array via pipeline with no enumerate' {
        Write-Output $DERCert -NoEnumerate | Should -BeOfType [System.Byte[]]
        $X509Certificate = Write-Output $DERCert -NoEnumerate | Get-X509Certificate -Verbose
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $DERCertThumbnail
    }

    It 'parses base64-encoded file' {
        $Base64CertFile | Should -BeOfType [System.IO.FileInfo]
        $X509Certificate = Get-X509Certificate $Base64CertFile
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $Base64CertFileThumbnail
    }

    It 'parses base64-encoded file via pipeline' {
        $Base64CertFile | Should -BeOfType [System.IO.FileInfo]
        $X509Certificate = $Base64CertFile | Get-X509Certificate
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $Base64CertFileThumbnail
    }

    It 'parses DER-encoded file' {
        $DERCertFile | Should -BeOfType [System.IO.FileInfo]
        $X509Certificate = Get-X509Certificate $DERCertFile
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $DERCertFileThumbnail
    }

    It 'parses DER-encoded file via pipeline' {
        $DERCertFile | Should -BeOfType [System.IO.FileInfo]
        $X509Certificate = $DERCertFile | Get-X509Certificate
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 1
        $X509Certificate.Thumbprint | Should -BeExactly $DERCertFileThumbnail
    }

    It 'parses base64-encoded string, base64-encoded file, DER-encoded byte array, and DER-encoded file' {
        $Base64Cert | Should -BeOfType [System.String]
        $Base64CertFile | Should -BeOfType [System.IO.FileInfo]
        Write-Output $DERCert -NoEnumerate | Should -BeOfType [System.Byte[]]
        $DERCertFile | Should -BeOfType System.IO.FileInfo
        Write-Output $Base64Cert, $Base64CertFile, $DERCert, $DERCertFile -NoEnumerate | Should -BeOfType [System.Object[]]
        $X509Certificate = Get-X509Certificate $Base64Cert, $Base64CertFile, $DERCert, $DERCertFile
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 4
        $X509Certificate[0].Thumbprint | Should -BeExactly $Base64CertThumbnail
        $X509Certificate[1].Thumbprint | Should -BeExactly $Base64CertFileThumbnail
        $X509Certificate[2].Thumbprint | Should -BeExactly $DERCertThumbnail
        $X509Certificate[3].Thumbprint | Should -BeExactly $DERCertFileThumbnail
    }

    It 'parses base64-encoded string, base64-encoded file, DER-encoded byte array, and DER-encoded file via pipeline' {
        $Base64Cert | Should -BeOfType [System.String]
        $Base64CertFile | Should -BeOfType [System.IO.FileInfo]
        Write-Output $DERCert -NoEnumerate | Should -BeOfType [System.Byte[]]
        $DERCertFile | Should -BeOfType System.IO.FileInfo
        $Base64Cert, $Base64CertFile, $DERCert, $DERCertFile | Should -BeOfType System.Object
        $X509Certificate = $Base64Cert, $Base64CertFile, $DERCert, $DERCertFile | Get-X509Certificate
        $X509Certificate | Should -BeOfType [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate | Should -HaveCount 4
        $X509Certificate[0].Thumbprint | Should -BeExactly $Base64CertThumbnail
        $X509Certificate[1].Thumbprint | Should -BeExactly $Base64CertFileThumbnail
        $X509Certificate[2].Thumbprint | Should -BeExactly $DERCertThumbnail
        $X509Certificate[3].Thumbprint | Should -BeExactly $DERCertFileThumbnail
    }

    It 'throws exception for int array' {
        $IntArray = @(48, 130, 5, 237, 48, 130, 3, 213, 160, 3, 2, 1, 2, 2, 16, 40, 204, 58, 37, 191, 186, 68, 172, 68, 154, 155, 88, 107, 67, 57, 170, 48, 13, 6, 9, 42, 134, 72, 134, 247, 13, 1, 1, 11, 5, 0, 48, 129, 136, 49, 11, 48, 9, 6, 3, 85, 4, 6, 19, 2, 85, 83, 49, 19, 48, 17, 6, 3, 85, 4, 8, 19, 10, 87, 97, 115, 104, 105, 110, 103, 116, 111, 110, 49, 16, 48, 14, 6, 3, 85, 4, 7, 19, 7, 82, 101, 100, 109, 111, 110, 100, 49, 30, 48, 28, 6, 3, 85, 4, 10, 19, 21, 77, 105, 99, 114, 111, 115, 111, 102, 116, 32, 67, 111, 114, 112, 111, 114, 97, 116, 105, 111, 110, 49, 50, 48, 48, 6, 3, 85, 4, 3, 19, 41, 77, 105, 99, 114, 111, 115, 111, 102, 116, 32, 82, 111, 111, 116, 32, 67, 101, 114, 116, 105, 102, 105, 99, 97, 116, 101, 32, 65, 117, 116, 104, 111, 114, 105, 116, 121, 32, 50, 48, 49, 48, 48, 30, 23, 13, 49, 48, 48, 54, 50, 51, 50, 49, 53, 55, 50, 52, 90, 23, 13, 51, 53, 48, 54, 50, 51, 50, 50, 48, 52, 48, 49, 90, 48, 129, 136, 49, 11, 48, 9, 6, 3, 85, 4, 6, 19, 2, 85, 83, 49, 19, 48, 17, 6, 3, 85, 4, 8, 19, 10, 87, 97, 115, 104, 105, 110, 103, 116, 111, 110, 49, 16, 48, 14, 6, 3, 85, 4, 7, 19, 7, 82, 101, 100, 109, 111, 110, 100, 49, 30, 48, 28, 6, 3, 85, 4, 10, 19, 21, 77, 105, 99, 114, 111, 115, 111, 102, 116, 32, 67, 111, 114, 112, 111, 114, 97, 116, 105, 111, 110, 49, 50, 48, 48, 6, 3, 85, 4, 3, 19, 41, 77, 105, 99, 114, 111, 115, 111, 102, 116, 32, 82, 111, 111, 116, 32, 67, 101, 114, 116, 105, 102, 105, 99, 97, 116, 101, 32, 65, 117, 116, 104, 111, 114, 105, 116, 121, 32, 50, 48, 49, 48, 48, 130, 2, 34, 48, 13, 6, 9, 42, 134, 72, 134, 247, 13, 1, 1, 1, 5, 0, 3, 130, 2, 15, 0, 48, 130, 2, 10, 2, 130, 2, 1, 0, 185, 8, 158, 40, 228, 228, 236, 6, 78, 80, 104, 179, 65, 197, 123, 235, 174, 182, 142, 175, 129, 186, 34, 68, 31, 101, 52, 105, 76, 190, 112, 64, 23, 242, 22, 123, 226, 121, 253, 134, 237, 13, 57, 244, 27, 168, 173, 146, 144, 30, 203, 61, 118, 143, 90, 217, 181, 145, 16, 46, 60, 5, 141, 138, 109, 36, 84, 231, 31, 237, 86, 173, 131, 180, 80, 156, 21, 165, 23, 116, 136, 89, 32, 252, 8, 197, 132, 118, 211, 104, 212, 111, 40, 120, 206, 92, 184, 243, 80, 144, 68, 255, 227, 99, 95, 190, 161, 154, 44, 150, 21, 4, 214, 7, 254, 30, 132, 33, 224, 66, 49, 17, 196, 40, 54, 148, 207, 80, 164, 98, 158, 201, 214, 171, 113, 0, 178, 91, 12, 230, 150, 212, 10, 36, 150, 245, 255, 198, 213, 183, 27, 215, 203, 183, 33, 98, 175, 18, 220, 161, 93, 55, 227, 26, 251, 26, 70, 152, 192, 155, 192, 231, 99, 31, 42, 8, 147, 2, 126, 30, 106, 142, 242, 159, 24, 137, 228, 34, 133, 162, 177, 132, 87, 64, 255, 245, 14, 216, 111, 156, 237, 226, 69, 49, 1, 205, 23, 233, 127, 176, 129, 69, 227, 170, 33, 64, 38, 161, 114, 170, 167, 79, 60, 1, 5, 126, 238, 131, 88, 177, 94, 6, 99, 153, 98, 145, 120, 130, 183, 13, 147, 12, 36, 106, 180, 27, 219, 39, 236, 95, 149, 4, 63, 147, 74, 48, 245, 151, 24, 179, 167, 249, 25, 167, 147, 51, 29, 1, 200, 219, 34, 82, 92, 215, 37, 201, 70, 249, 162, 251, 135, 89, 67, 190, 155, 98, 177, 141, 45, 134, 68, 26, 70, 172, 120, 97, 126, 48, 9, 250, 174, 137, 196, 65, 42, 34, 102, 3, 145, 57, 69, 156, 199, 139, 12, 168, 202, 13, 47, 251, 82, 234, 12, 247, 99, 51, 35, 157, 254, 176, 31, 173, 103, 214, 167, 80, 3, 198, 4, 112, 99, 181, 44, 177, 134, 90, 67, 183, 251, 174, 249, 110, 41, 110, 33, 33, 65, 38, 6, 140, 201, 195, 238, 176, 194, 133, 147, 161, 185, 133, 217, 230, 50, 108, 75, 76, 63, 214, 93, 163, 229, 181, 157, 119, 195, 156, 192, 85, 183, 116, 0, 227, 184, 56, 171, 131, 151, 80, 225, 154, 66, 36, 29, 198, 192, 163, 48, 209, 26, 90, 200, 82, 52, 247, 115, 241, 199, 24, 31, 51, 173, 122, 236, 203, 65, 96, 243, 35, 148, 32, 194, 72, 69, 172, 92, 81, 198, 46, 128, 194, 226, 119, 21, 189, 133, 135, 237, 54, 157, 150, 145, 238, 0, 181, 163, 112, 236, 159, 227, 141, 128, 104, 131, 118, 186, 175, 93, 112, 82, 34, 22, 226, 102, 251, 186, 179, 197, 194, 247, 62, 47, 119, 166, 202, 222, 193, 166, 198, 72, 76, 195, 55, 81, 35, 211, 39, 215, 184, 78, 112, 150, 240, 161, 68, 118, 175, 120, 207, 154, 225, 102, 19, 2, 3, 1, 0, 1, 163, 81, 48, 79, 48, 11, 6, 3, 85, 29, 15, 4, 4, 3, 2, 1, 134, 48, 15, 6, 3, 85, 29, 19, 1, 1, 255, 4, 5, 48, 3, 1, 1, 255, 48, 29, 6, 3, 85, 29, 14, 4, 22, 4, 20, 213, 246, 86, 203, 143, 232, 162, 92, 98, 104, 209, 61, 148, 144, 91, 215, 206, 154, 24, 196, 48, 16, 6, 9, 43, 6, 1, 4, 1, 130, 55, 21, 1, 4, 3, 2, 1, 0, 48, 13, 6, 9, 42, 134, 72, 134, 247, 13, 1, 1, 11, 5, 0, 3, 130, 2, 1, 0, 172, 165, 150, 140, 191, 187, 174, 166, 246, 215, 113, 135, 67, 49, 86, 136, 253, 28, 50, 113, 91, 53, 183, 212, 240, 145, 242, 175, 55, 226, 20, 241, 243, 2, 38, 5, 62, 22, 20, 127, 20, 186, 184, 79, 251, 137, 178, 178, 231, 212, 9, 204, 109, 185, 91, 59, 100, 101, 112, 102, 183, 242, 177, 90, 223, 26, 2, 243, 245, 81, 184, 103, 109, 121, 243, 191, 86, 123, 228, 132, 185, 43, 30, 155, 64, 156, 38, 52, 249, 71, 24, 152, 105, 216, 28, 215, 182, 209, 191, 143, 97, 194, 103, 196, 181, 239, 96, 67, 142, 16, 27, 54, 73, 228, 32, 202, 173, 167, 193, 177, 39, 101, 9, 248, 205, 245, 91, 42, 208, 132, 51, 243, 239, 31, 242, 245, 156, 11, 88, 147, 55, 160, 117, 160, 222, 114, 222, 108, 117, 42, 102, 34, 245, 140, 6, 48, 86, 159, 64, 185, 48, 170, 64, 119, 21, 130, 215, 139, 236, 192, 211, 178, 189, 131, 197, 119, 12, 30, 174, 175, 25, 83, 160, 77, 121, 113, 159, 15, 175, 48, 206, 103, 249, 214, 44, 204, 34, 65, 122, 7, 242, 151, 66, 24, 206, 89, 121, 16, 85, 222, 111, 16, 228, 184, 218, 131, 102, 64, 22, 9, 104, 35, 91, 151, 46, 38, 154, 2, 187, 87, 140, 197, 184, 186, 105, 98, 50, 128, 137, 158, 161, 253, 192, 146, 124, 123, 43, 51, 25, 132, 42, 99, 197, 0, 104, 98, 250, 159, 71, 141, 153, 122, 69, 58, 167, 233, 237, 238, 105, 66, 181, 243, 129, 155, 71, 86, 16, 123, 252, 112, 54, 132, 24, 115, 234, 239, 249, 151, 77, 158, 51, 35, 221, 38, 11, 186, 42, 183, 63, 68, 220, 131, 39, 255, 189, 97, 89, 43, 17, 183, 202, 79, 219, 197, 139, 12, 28, 49, 174, 50, 248, 248, 185, 66, 247, 127, 220, 97, 154, 118, 177, 90, 4, 225, 17, 61, 102, 69, 183, 24, 113, 190, 201, 36, 133, 214, 243, 212, 186, 65, 52, 93, 18, 45, 37, 185, 141, 166, 19, 72, 109, 75, 176, 7, 125, 153, 147, 9, 97, 129, 116, 87, 38, 138, 171, 105, 227, 228, 217, 199, 136, 204, 36, 216, 236, 82, 36, 92, 30, 188, 145, 20, 226, 150, 222, 235, 10, 218, 158, 221, 95, 179, 91, 219, 212, 130, 236, 198, 32, 80, 135, 37, 64, 58, 251, 199, 238, 205, 254, 51, 229, 110, 195, 132, 9, 85, 3, 37, 57, 192, 233, 53, 93, 101, 49, 168, 246, 191, 160, 9, 205, 41, 199, 179, 54, 50, 46, 220, 149, 243, 131, 193, 90, 207, 139, 141, 246, 234, 179, 33, 248, 164, 237, 30, 49, 14, 182, 76, 17, 171, 96, 11, 164, 18, 35, 34, 23, 163, 54, 100, 130, 145, 4, 18, 224, 171, 111, 30, 203, 80, 5, 97, 180, 64, 255, 89, 134, 113, 209, 213, 51, 105, 124, 169, 115, 138, 56, 215, 100, 12, 241, 105)
        $IntArray | Should -BeOfType [System.Int32]
        $X509Certificate = { $IntArray | Get-X509Certificate } | Should -Throw
        $X509Certificate | Should -BeNullOrEmpty
    }
}
