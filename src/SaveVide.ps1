<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Reddit Module
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

function Request-IeVideo{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url")]
        [ValidateNotNullOrEmpty()]
        [String]$Url
    )  

    Write-ModLog "Request to $Url"
    [String]$BaseUrl = "https://www.redditsave.com"
    [String]$CompleteUrl = "$BaseUrl/info?url=$Url"
    $EncodedUrl = [uri]::EscapeUriString($CompleteUrl)

    $ie = New-Object -com InternetExplorer.Application 
    $ie.visible = $false
    Write-ModLog "ie.navigate ...."
    $ie.navigate("$EncodedUrl")
    Write-Host "In Progress ..." -n -f DarkYellow
    while($ie.ReadyState -ne 4) { 
      start-sleep -s 1
      Write-Host "." -n -f DarkRed 
    }
    Write-Host "." -f DarkRed 
    Write-Host "Success!" -f DarkGreen

    #$Link=$ie.Document.getElementsByTagName("input") | where-object {$_.type -eq "button"}
    #$Link.click();
    return $ie 
}

function Request-SaveVideo{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url")]
        [ValidateNotNullOrEmpty()]
        [String]$Url
    )  

    [String]$BaseUrl = "https://www.redditsave.com"
    [String]$CompleteUrl = "$BaseUrl/info?url=$Url"
    $EncodedUrl = [uri]::EscapeUriString($CompleteUrl)
    
    $HeadersData = @{
        Accept          = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp'
        UserAgent       = 'AppleWebKit/111.11 (KHTML, like Gecko) Chrome/123 Safari/222.11'
    }

    $Params = @{
        Uri             = $EncodedUrl
        UserAgent       = Get-RedditModuleUserAgent
        Headers         = $HeadersData
        Method          = 'GET'
        UseBasicParsing = $true
    }      

    Write-Verbose "Invoke-WebRequest Url: $Url"
    Write-Verbose "Params = $Params"
    $ResponseRaw = (Invoke-WebRequest @Params)

    $StatusCode = $ResponseRaw.StatusCode
    $RawContentLength = $ResponseRaw.RawContentLength
    $StatusDescription = $ResponseRaw.StatusDescription



    if($StatusCode -ne 200){
        throw "error"
    }
    return $ResponseRaw
    $AnchorStart = '<!----  START DOWNLOAD BUTTONS---->'
    $AnchorEnd   = '<!----  END DOWNLOAD BUTTONS---->'

    $Content = $ResponseRaw.Content
    $ContentLength = $Content.Length
    $Index1 = $Content.IndexOf($AnchorStart)
    $Index2 = $Content.LastIndexOf($AnchorEnd)
    $NumChar = $Index2 - $Index1

    Write-Verbose "`n---------------------------------------"
    Write-Verbose "StatusCode:        $StatusCode"
    Write-Verbose "StatusDescription: $StatusDescription"
    Write-Verbose "RawContentLength:  $RawContentLength"
    Write-Verbose "Index1:            $Index1"
    Write-Verbose "ContentLength:     $ContentLength"
    Write-Verbose "Index1:            $Index1"
    Write-Verbose "Index2:            $Index2"
    Write-Verbose "NumChar:           $NumChar"
    Write-Verbose "---------------------------------------"

    $SubContent = $Content.SubString($Index1, $NumChar)
    Write-Verbose "---------------------------------------"
    Write-Verbose "SubContent: $SubContent"
    Write-Verbose "---------------------------------------"

    $SubContentLength = $SubContent.Length
    $i1 = $SubContent.IndexOf('href')
    $i2 = $SubContentLength - $i1
    #$SubContent = $SubContent.SubString($i1, $i2)

    #$i2 = $SubContent.IndexOf('>')
    #$SubContent = $SubContent.SubString(0, $i2)

    
    return $SubContent
}


