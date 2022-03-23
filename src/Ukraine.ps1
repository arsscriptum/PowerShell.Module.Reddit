


function Invoke-DownloadVideos{
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

    Write-Host -n "[DownloadVideos] " -f DarkRed
    Write-Host "Get $NumberPost last posts..." -f DarkYellow

    $DownloadListCount = 0
    
    $Posts = (Request-LatestUkrainePosts -Number $NumberPost).post_url
    ForEach($item in $Posts){ 
        $TxtUrl = [Uri]$item
        $hoststr = $TxtUrl.Host
        if($hoststr -eq 'www.reddit.com'){ 
            Write-Host -n -f DarkRed "[DownloadVideos] " 
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
    Write-Host -n "[DownloadVideos] " -f DarkRed
    Write-Host "Found $TotalPosts Posts" -f DarkYellow

    write-host "`n[DownloadVideos] " -f Red -n ; $a=Read-Host -Prompt "Do you want to get the videos ? (y/N)?" ; if($a -notmatch "y") {return;}
    $Downloaded = 0
    ForEach($item in $List){ 
        Write-Host -n "[DownloadVideos] " -f DarkRed
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
            Write-Host -n "[DownloadVideos] " -f DarkCyan
            Write-Host "SUCCESS in $sec,$msec s" -f DarkGreen  
        }else{
            Write-Host -n "[DownloadVideos] " -f DarkRed
            Write-Host "FAILED in $sec,$msec s . $cmdExitCode,$stdErr" -f DarkYellow  
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



