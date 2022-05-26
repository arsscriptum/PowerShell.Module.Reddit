<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-WGetExecutable{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    $Cmd = Get-Command -Name 'wget.exe' -ErrorAction Ignore
    if($Cmd -eq $Null) { throw "Cannot find wget.exe" }
    $WgetExe = $Cmd.Source
    if(-not(Test-Path $WgetExe)){ throw "cannot live" }
    return $WgetExe
}



function Invoke-BypassPaywall{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    $WgetExe = Get-WGetExecutable
    $fn = New-RandomFilename -Extension 'html'
  
    Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkYellow "wget $WgetExe url $Url"

    $Content = Invoke-WebRequest -Uri "$Url"
    $sc = $Content.StatusCode    
    if($sc -eq 200){
        $cnt = $Content.Content
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkGreen "StatusCode $sc OK"
        Set-Content -Path "$fn" -Value "$cnt"
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkYellow "ERROR StatusCode $sc"
    }
}


function Save-RedditAudio{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    try{
        $Null =  Add-Type -AssemblyName System.webURL -ErrorAction Stop | Out-Null    
    }catch{}
    
    $urlToEncode = $Url
    $encodedURL = [System.Web.HttpUtility]::UrlEncode($urlToEncode) 

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"

    #Encode URL code ends here

    $RequestUrl = "https://www.redditsave.com/info?url=$encodedURL"
    $Content = Invoke-RestMethod -Uri $RequestUrl -Method 'GET'

    $i = $Content.IndexOf('<a onclick="gtag')
    $j = $Content.IndexOf('"/d/',$i+1)
    $k = $Content.IndexOf('"',$j+1)
    $l = $k-$j
    $NewRequest = $Content.substring($j+1,$l-1)
    $RequestUrl = "https://www.redditsave.com$NewRequest"

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"
    $WgetExe = Get-WGetExecutable

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "wget $WgetExe url $Url"

    $fn = New-RandomFilename -Extension 'mp4'
    $a = @("$RequestUrl","-O","$fn")
    $p = Invoke-Process -ExePath "$WgetExe" -ArgumentList $a 
    $ec = $p.ExitCode    
    if($ec -eq 0){
        $timeStr = "$($p.ElapsedSeconds) : $($p.ElapsedMs)"
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkGreen "Downloaded in $timeStr s"
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "ERROR ExitCode $ec"
    }
}


function Save-RedditVideo{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    try{
        $Null =  Add-Type -AssemblyName System.webURL -ErrorAction Stop | Out-Null    
    }catch{}
    
    $urlToEncode = $Url
    $encodedURL = [System.Web.HttpUtility]::UrlEncode($urlToEncode) 

    Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"

    #Encode URL code ends here

    $RequestUrl = "https://www.redditsave.com/info?url=$encodedURL"
    $Content = Invoke-RestMethod -Uri $RequestUrl -Method 'GET'

    $i = $Content.IndexOf('"https://sd.redditsave.com/download.php')
    $j = $Content.IndexOf('"',$i+1)
    $l = $j-$i
    $RequestUrl = $Content.Substring($i+1, $l-1)
    
    $WgetExe = Get-WGetExecutable
    Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "Please wait...."

    $fn = New-RandomFilename -Extension 'mp4'
    $a = @("$RequestUrl","-O","$fn")
    $p = Invoke-Process -ExePath "$WgetExe" -ArgumentList $a 
    $ec = $p.ExitCode    
    if($ec -eq 0){
        $timeStr = "$($p.ElapsedSeconds) : $($p.ElapsedMs)"
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkGreen "Downloaded in $timeStr s"
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "ERROR ExitCode $ec"
    }
}





function Save-LastXVideos{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [int]$NumberToDownload=10,
        [Parameter(Mandatory=$false)]
        [int]$NumberPost=100        
    ) 

    $ExecutionResults = [System.Collections.ArrayList]::new()
    $List = [System.Collections.ArrayList]::new()
    $DlExe = (Get-Command 'youtube-dl.exe').Source
    $curdate = $(get-date -Format "yyyy-MM-dd_\hhh\mmmm")

    if(($Path -eq $Null) -or ($Path.Length -eq 0)){
        $Path = [Environment]::GetFolderPath("MyVideos")
        $Path = Join-Path $Path 'Ukraine'
        $Path = Join-Path $Path $curdate
        $Null = New-Item -Path "$Path" -ItemType "Directory" -Force
        Write-Host -n "[DownloadVideos] " -f DarkRed
        Write-Host "Go in $Path" -f DarkYellow
        Push-Location $Path
    }

    Write-Host -n "[SaveLastX] " -f DarkRed
    Write-Host "Get $NumberPost last posts..." -f DarkYellow

    $DownloadListCount = 0
    
    $Posts = (Request-LatestUkrainePosts -Number $NumberPost).post_url
    ForEach($item in $Posts){ 
        $TxtUrl = [Uri]$item
        $hoststr = $TxtUrl.Host
        if($hoststr -eq 'www.reddit.com'){ 
            Write-Host -n -f DarkRed "[SaveLastX] " 
            Write-Host -f DarkYellow "Found $item"
            $Null = $List.Add($item)
            $DownloadListCount++
            if($DownloadListCount -ge $NumberToDownload){ break ; }
        }
    }
    $FNameOut=New-RandomFilename -Extension 'log' -CreateDirectory
    $FNameErr=New-RandomFilename -Extension 'log' -CreateDirectory

    $startProcessParams = @{
        FilePath               = $DlExe
        RedirectStandardError  = $FNameErr
        RedirectStandardOutput = $FNameOut
        Wait                   = $true
        PassThru               = $true
        NoNewWindow            = $true
        WorkingDirectory       = $Path
    }

    $cmdName=""
    $cmdId=0
    $cmdExitCode=0


    $TotalPosts = $List.Count
    Write-Host -n "[SaveLastX] " -f DarkRed
    Write-Host "Found $TotalPosts Posts" -f DarkYellow

    write-host "`n[DownloadVideos] " -f Red -n ; $a=Read-Host -Prompt "Do you want to get the videos ? (y/N)?" ; if($a -notmatch "y") {return;}
    $Downloaded = 0
    ForEach($item in $List){ 
        Write-Host -n "[SaveLastX] " -f DarkRed
        Write-Host "Getting $item" -f DarkYellow        
                
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $ArgumentList = @("$item")
        $cmd = Start-Process @startProcessParams -ArgumentList $ArgumentList| Out-null
        $cmdExitCode = $cmd.ExitCode
        $cmdId = $cmd.Id 
        $cmdName=$cmd.Name 

        $stdOut = Get-Content -Path $FNameOut -Raw
        $stdErr = Get-Content -Path $FNameErr -Raw
        if ([string]::IsNullOrEmpty($stdOut) -eq $false) {
           $stdOut = $stdOut.Trim()
        }
        if ([string]::IsNullOrEmpty($stdErr) -eq $false) {
           $stdErr = $stdErr.Trim()
        }
        $res = [PSCustomObject]@{
           Name            = $cmdName
           Id              = $cmdId
           ExitCode        = $cmdExitCode
           Output          = $stdOut
           Error           = $stdErr
           ElapsedSeconds  = $stopwatch.Elapsed.Seconds
           ElapsedMs       = $stopwatch.Elapsed.Milliseconds
        }
        $sec = $stopwatch.Elapsed.Seconds
        $msec = $stopwatch.Elapsed.Milliseconds
        $Null = $ExecutionResults.Add($res)
        if($cmdExitCode -eq 0){
            $Downloaded++
            Write-Host -n "[SaveLastX] " -f DarkCyan
            Write-Host "SUCCESS in $sec,$msec s" -f DarkGreen  
        }else{
            Write-Host -n "[SaveLastX] " -f DarkRed
            Write-Host "FAILED [$cmdExitCode] [$stdErr]" -f DarkYellow  
        }
        <#$Out = &"$DlExe" "$item" | Out-Null
        $ReturnValue = $?
        if($ReturnValue){
            $Downloaded++
            Write-Host -n "[DownloadVideos] " -f DarkCyan
            Write-Host "SUCCESS" -f DarkGreen  
        }else{
            Write-Host -n "[DownloadVideos] " -f DarkRed
            Write-Host "FAILED" -f DarkYellow  
        }
        #>
    }
    popd
    if($Downloaded -eq 0){
        $Null = Remove-Item -Path $Path -Recurse -Force
        Write-Host -n "[DownloadVideos] " -f DarkCyan
        Write-Host "$Path empty, delete..." -f DarkGreen  
    }
}



