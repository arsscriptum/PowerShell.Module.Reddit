<#	
    .NOTES
    
     Created with: 	Plaster
     Created on:   	8/11/2017 6:00 PM
     Edited on:     8/11/2017
     Created by:   	Mark Kraus
     Organization: 	 
     Filename:     	Connect-Reddit.ps1
    
    .DESCRIPTION
        Connect-Reddit Function
#>
[CmdletBinding()]
param()

function Connect-Reddit {
    [CmdletBinding(
        ConfirmImpact = 'Low',
        HelpUri = 'https://psraw.readthedocs.io/en/latest/Module/Connect-Reddit'
    )]
    [OutputType([Void])]
    param
    (
        [pscredential]$ClientCredential,
        [pscredential]$UserCredential,
        [uri]$RedirectUri
    )
    Process {
        $ClientID = $ClientCredential.UserName
        if ([string]::IsNullOrEmpty($ClientID)) {
            $ClientID = Read-Host 'Enter your Reddit Script Application Client ID'
        }
        $ClientSecret = $ClientCredential.Password
        if(
            $null -eq $ClientSecret -or
            $ClientSecret.Length -eq 0
        ) {
            $ClientSecret = Read-Host 'Enter your Reddit Script Application Client Secret' -AsSecureString
        }
        if([string]::IsNullOrEmpty($RedirectUri.AbsoluteUri)){
            [uri]$RedirectUri = Read-Host 'Enter your Reddit Application Redirect URI'
        }
        $Username = $UserCredential.UserName
        if (
            $Null -eq $Username -or 
            $Username -eq [string]::Empty
        ) {
            $Username = Read-Host 'Enter your Reddit User ID'
        }
        $Password = $UserCredential.Password
        if(
            $null -eq $Password -or
            $Password.Length -eq 0
        ) {
            $Password = Read-Host 'Enter your Reddit Password' -AsSecureString
        }
        $AppParams = @{
            Script = $True
            ClientCredential = [pscredential]::New($ClientID,$ClientSecret)
            UserCredential = [pscredential]::New($Username,$Password)
            RedirectUri = $RedirectUri
        }
        $Application = New-RedditApplication @AppParams 
        Request-RedditOAuthToken -Script -Application $Application
    }
}
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQmNGQp1gpW7a11XX8c9NhuYG
# 8V6gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjAyMDkyMzI4NDRaFw0zOTEyMzEyMzU5NTlaMCUxIzAhBgNVBAMTGkFyc1Nj
# cmlwdHVtIFBvd2VyU2hlbGwgQ1NDMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA60ec8x1ehhllMQ4t+AX05JLoCa90P7LIqhn6Zcqr+kvLSYYp3sOJ3oVy
# hv0wUFZUIAJIahv5lS1aSY39CCNN+w47aKGI9uLTDmw22JmsanE9w4vrqKLwqp2K
# +jPn2tj5OFVilNbikqpbH5bbUINnKCDRPnBld1D+xoQs/iGKod3xhYuIdYze2Edr
# 5WWTKvTIEqcEobsuT/VlfglPxJW4MbHXRn16jS+KN3EFNHgKp4e1Px0bhVQvIb9V
# 3ODwC2drbaJ+f5PXkD1lX28VCQDhoAOjr02HUuipVedhjubfCmM33+LRoD7u6aEl
# KUUnbOnC3gVVIGcCXWsrgyvyjqM2WQIDAQABo3YwdDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBdBgNVHQEEVjBUgBD8gBzCH4SdVIksYQ0DovzKoS4wLDEqMCgGA1UEAxMh
# UG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBSb290ghABvvi0sAAYvk29NHWg
# Q1DUMAkGBSsOAwIdBQADggEBAI8+KceC8Pk+lL3s/ZY1v1ZO6jj9cKMYlMJqT0yT
# 3WEXZdb7MJ5gkDrWw1FoTg0pqz7m8l6RSWL74sFDeAUaOQEi/axV13vJ12sQm6Me
# 3QZHiiPzr/pSQ98qcDp9jR8iZorHZ5163TZue1cW8ZawZRhhtHJfD0Sy64kcmNN/
# 56TCroA75XdrSGjjg+gGevg0LoZg2jpYYhLipOFpWzAJqk/zt0K9xHRuoBUpvCze
# yrR9MljczZV0NWl3oVDu+pNQx1ALBt9h8YpikYHYrl8R5xt3rh9BuonabUZsTaw+
# xzzT9U9JMxNv05QeJHCgdCN3lobObv0IA6e/xTHkdlXTsdgxggHhMIIB3QIBATBA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# mkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUXxPcjOyntvlFbTLwxi3k
# /f0K8EMwDQYJKoZIhvcNAQEBBQAEggEAStfzXJQMdmNBWpoloNTRpi8MSLscYwL1
# UJMiunUCLoU+TNUwx1mNHoBVL1M8ReXbCnOEUPw7tQw55gaqvLhIVkKKKiYH0eke
# uYp+kH55AivHorzqKJ+Uuva2aySsrmYJcapIadI9I6A7VjuAtZ3hkXDYdR02R3dp
# +QKKHYHGpzni+GwqF+xVFX0JJZFPMJO3Hd80XqZ9tsAq9qv6LJaD8q9iazz6ykr0
# u9dC575SCVjCOYplhMs2aEaBkuKgwJC1Z5roEgoRyaWra3e1G227f5OGnCwvBs7N
# xTIeVUVDaIITmUKxoVxbjfbmPpalD9w+HJkM+Mfp6IznKbEzJMa/JQ==
# SIG # End signature block
