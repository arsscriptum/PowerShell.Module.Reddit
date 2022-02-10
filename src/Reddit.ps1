<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Reddit Module
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



function Script:AutoUpdateProgress {        # NOEXPORT
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber / $Script:TotalSteps) * 100)
    if($Script:StepNumber -lt $Script:TotalSteps){$Script:StepNumber++}
}


function Get-RedditUrl {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present", Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]$Action     
    )
    $baseoauth = 'https://oauth.reddit.com/'
    $base = 'https://www.reddit.com/'
    $result=''
    switch ( $Action )
    {
        'auth'   { $result = $base + 'api/v1/access_token' }
        'me'     { $result = $baseoauth + 'api/v1/me'    }
        'comments'  { $result = $baseoauth + 'user/cybercastor/comments'    }
        'auth4'  { $result = '' }
        'auth5'  { $result = ''  }
        'auth6'  { $result = ''    }
        'auth7'  { $result = ''  }
        default { throw "invalid action"  }
    }

    return $result
}

function Test-RedditLog{ 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $Path = Get-RedditModuleRegistryPath
    Write-MOk "Path is $Path"
    Write-ChannelMessage "Path is $Path"
    Write-ChannelResult "Path is $Path"
}

function Get-RedditModuleUserAgent { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Agent = "User-Agent $ModuleName. Custom Module."
   
    return $Agent
}

function Get-RedditModuleRegistryPath { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Path = "$ENV:OrganizationHKCU\$ModuleName\Reddit.com"
   
    return $Path
}

function Set-RedditAppSecret {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Token,        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$Force      
    )
    $RegPath = Get-RedditModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
    
    if( $TokenPresent ){ 
        Write-Verbose "Token already configured"
        if($Force -eq $False){
            return;
        }
    }
    $ret = New-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $Token -Type 'string'
    return $ret
}

function Get-RedditAppSecret {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-RedditModuleRegistryPath
    $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
    if( $TokenPresent -eq $true ) {
        $Token = Get-RegistryValue -Path "$RegPath" -Entry 'access_token'
        return $Token
    }
    if( $Env:REDDIT_ACCESSTOKEN -ne $null ) { return $Env:REDDIT_ACCESSTOKEN  }
    return $null
}

function Set-RedditDefaultUsername {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$User      
    )
    $RegPath = Get-RedditModuleRegistryPath
    $ok = Set-RegistryValue  "$RegPath" "default_username" "$User"
    [environment]::SetEnvironmentVariable('DEFAULT_REDDIT_USERNAME',"$User",'User')
    return $ok
}

<#
    RedditDefaultUsername
    New-ItemProperty -Path "$ENV:OrganizationHKCU\Reddit.com" -Name 'default_username' -Value 'codecastor'
 #>
function Get-RedditDefaultUsername {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-RedditModuleRegistryPath
    $User = (Get-ItemProperty -Path "$RegPath" -Name 'default_username' -ErrorAction Ignore).default_username
    if( $User -ne $null ) { return $User  }
    if( $Env:DEFAULT_GIT_USERNAME -ne $null ) { return $Env:DEFAULT_GIT_USERNAME ; }    
    if( $Env:USERNAME -ne $null ) { return $Env:USERNAME ; }
    return $null
}


function Get-RedditServer {      
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-RedditModuleRegistryPath
    $Server = (Get-ItemProperty -Path "$RegPath" -Name 'hostname' -ErrorAction Ignore).hostname
    if( $Server -ne $null ) { return $Server }
     
    if( $Env:DEFAULT_REDDIT_SERVER -ne $null ) { return $Env:DEFAULT_REDDIT_SERVER  }
    return $null
}

function Set-RedditDefaultServer {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$Hostname      
    )
    $RegPath = Get-RedditModuleRegistryPath
    $ok = Set-RegistryValue  "$RegPath" "hostname" "$Hostname"
    [environment]::SetEnvironmentVariable('DEFAULT_REDDIT_SERVER',"$Hostname",'User')
    return $ok
}



function Get-RedditAuthenticationToken{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [switch]$Force
    ) 

    try{
        $RegPath = Get-RedditModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
        $RegPath = Join-Path $RegPath 'oAuth'

        $Exists = $False
        if($Force -eq $False) {
            $Exists = Test-RegistryValue -Path "$RegPath" -Name 'access_token'    
        }
        if($Exists){
            $NowTime = Get-Date 
            $NowTimeString = '{0}' -f ([system.string]::format('{0:yyyyMMddHHmmss.000000+000}',$NowTime))
            $TimeExpired = Get-RegistryValue -Path "$RegPath" -Name 'expiration_time'
            $ntm = [System.Management.ManagementDateTimeConverter]::ToDateTime( $NowTimeString )
            $ext = [System.Management.ManagementDateTimeConverter]::ToDateTime( $TimeExpired )
            Write-Verbose "Previous expires on $ExpirationTime"
            $Diff = $ntm-$ext
            Write-Verbose "Diff $Diff"
            $Token = Get-RegistryValue -Path "$RegPath" -Name 'access_token'
            if($Diff -gt 0){
                Write-Verbose "Use existing $Token"
                return $Token
            }
        }
        $UserCredz = Get-AppCredentials PowerShell.Module.Reddit
        $AppCredz = Get-AppCredentials RedditScript
        [String]$AuthBaseUrl =  Get-RedditUrl -Action 'auth'

        $Params = @{
            Uri             = $AuthBaseUrl
            Body            = @{
                grant_type = 'password'
                username   = $UserCredz.UserName
                password   = $UserCredz.GetNetworkCredential().Password
            }
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = @{
                Authorization = $AppCredz | Get-AuthorizationHeader 
            }
            Method          = 'POST'
            UseBasicParsing = $true
        }
        Write-Verbose "Invoke-WebRequest $Params"
        $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json
        $AccessToken = $Response.access_token
        $TokenType = $Response.token_type
        $ExpiresInSecs = $Response.expires_in
        $Scope = $Response.scope
        Write-Verbose "Invoke-WebRequest Response: $Response"
       
        [DateTime]$NowTime = Get-Date
        [DateTime]$ExpirationTime = $NowTime.AddSeconds(-$ExpiresInSecs)

        $NowTimeString = '{0}' -f ([system.string]::format('{0:yyyyMMddHHmmss.000000+000}',$NowTime))
        $ExpirationTimeString = '{0}' -f ([system.string]::format('{0:yyyyMMddHHmmss.000000+000}',$ExpirationTime))
   
       
        $Null=New-Item -Path $RegPath -ItemType Directory -Force
        Set-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $AccessToken 
        Set-RegistryValue -Path "$RegPath" -Name 'created_on' -Value $NowTimeString 
        Set-RegistryValue -Path "$RegPath" -Name 'expiration_time' -Value $ExpirationTimeString 
        Set-RegistryValue -Path "$RegPath" -Name 'scope' -Value $Scope

        return $AccessToken
    }catch{
        Show-ExceptionDetails $_
    }
}




function Get-RedditMe{
    [CmdletBinding(SupportsShouldProcess)]
    param ()    


        $RegPath = Get-RedditModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
        $RegPath = Join-Path $RegPath 'oAuth'

       
        $UserCredz = Get-AppCredentials PowerShell.Module.Reddit
        $AppCredz = Get-AppCredentials RedditScript
        [String]$Url =  Get-RedditUrl -Action 'me'
 
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken)
        $Params = @{
            Uri             = $Url
             Body            = @{
                grant_type = 'password'
                username   = $UserCredz.UserName
                password   = $UserCredz.GetNetworkCredential().Password
            }
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = @{
                Authorization = $AuStr
            }
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}

function Get-RedditComments{
    [CmdletBinding(SupportsShouldProcess)]
    param ()    
        $UserCredz = Get-AppCredentials PowerShell.Module.Reddit
        $AppCredz = Get-AppCredentials RedditScript
        $User = $UserCredz.UserName
        [String]$Url = "https://oauth.reddit.com/user/$User/comments"
        $BodyData = @{
            grant_type  = 'password'
            username    = $UserCredz.UserName
            password    = $UserCredz.GetNetworkCredential().Password    
            context     = 2
            sort        = 'top'
            t           = 'all'
            type        = 'comments'
        }
        $Params = @{
            Uri             = $Url
            Body            = $BodyData
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = Get-RedditDefaultHeaders
            Method          = 'GET'
            UseBasicParsing = $true
        }      




        $P = $Params | ConvertTo-Json
        Write-Verbose "Invoke-WebRequest Url: $Url P = $P"
         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         write-host "$Response"
         Write-Verbose "Invoke-WebRequest Response: $Response"
}



function Get-RedditDefaultHeaders { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $AuStr = 'bearer ' + (Get-RedditAuthenticationToken)
    $Params = @{
        Authorization = $AuStr
    }
   
    return $Params
}
function Get-RedditDefaultBody { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $Params = @{
        grant_type = 'password'
        username   = $UserCredz.UserName
        password   = $UserCredz.GetNetworkCredential().Password    
    }
   
    return $Params
}


function Get-RedditUserAvailable{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username     
    )   
        $UserCredz = Get-AppCredentials PowerShell.Module.Reddit
        $AppCredz = Get-AppCredentials RedditScript
        $User = $UserCredz.UserName
        $base = 'https://oauth.reddit.com'
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken)
        [String]$Url = "$base/api/username_available"
        $HeadersData = @{
            Authorization = $AuStr
            user        = $Username
        }
        $BodyData = @{
            grant_type  = 'password'
            username    = $UserCredz.UserName
            password    = $UserCredz.GetNetworkCredential().Password    
            user = $Username
        }
        $Params = @{
            Uri             = $Url
            Body            = $BodyData
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = $HeadersData
            Method          = 'GET'
            UseBasicParsing = $true
        }      


        $P = $Params | ConvertTo-Json
        Write-Verbose "Invoke-WebRequest Url: $Url P = $P"
        $ResponseJson = (Invoke-WebRequest @Params).Content
        $ResponseList = $ResponseJson | ConvertFrom-Json | Out-String
        write-host -f DarkRed "=================================="
        write-host -f DarkYellow "ResponseJson: $ResponseJson"
        write-host -f DarkCyan "--------------"
        write-host -f DarkYellow "ResponseList: $ResponseList"    
        write-host -f DarkRed "=================================="    
        Write-Verbose "Invoke-WebRequest Response: $Response"
}


function Get-RedditUserInfo{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username     
    )   
        $UserCredz = Get-AppCredentials PowerShell.Module.Reddit
        $AppCredz = Get-AppCredentials RedditScript
        $User = $UserCredz.UserName
        $base = 'https://oauth.reddit.com'
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken)
        [String]$Url = "$base/$Username/about"
        $HeadersData = @{
            Authorization = $AuStr
            user        = $Username
        }
        $BodyData = @{
            grant_type  = 'password'
            username    = $UserCredz.UserName
            password    = $UserCredz.GetNetworkCredential().Password    
            user = $Username
        }
        $Params = @{
            Uri             = $Url
            Body            = $BodyData
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = $HeadersData
            Method          = 'GET'
            UseBasicParsing = $true
        }      


        $P = $Params | ConvertTo-Json
        Write-Verbose "Invoke-WebRequest Url: $Url P = $P"
        $ResponseJson = (Invoke-WebRequest @Params).Content
        $ResponseList = $ResponseJson | ConvertFrom-Json | Out-String
        write-host -f DarkRed "=================================="
        write-host -f DarkYellow "ResponseJson: $ResponseJson"
        write-host -f DarkCyan "--------------"
        write-host -f DarkYellow "ResponseList: $ResponseList"    
        write-host -f DarkRed "=================================="    
        Write-Verbose "Invoke-WebRequest Response: $Response"
}



function Invoke-GetNewPowerShell{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username     
    )   

        $UserCredz = Get-AppCredentials PowerShell.Module.Reddit
        $AppCredz = Get-AppCredentials RedditScript
        $ThisUser = $UserCredz.UserName
        $base = 'https://oauth.reddit.com'
        
        if(($Username -eq $Null)-Or($Username -eq '')){
            $Username = $ThisUser
        }
        [String]$Url = "$base/r/powershell/new"
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken)
        $HeadersData = @{
            Authorization = $AuStr
            user        = $Username
        }
        $BodyData = @{
            grant_type  = 'password'
            username    = $UserCredz.UserName
            password    = $UserCredz.GetNetworkCredential().Password    
            user        = $Username
        }
        $Params = @{
            Uri             = $Url
            Body            = $BodyData
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = $HeadersData
            Method          = 'GET'
            UseBasicParsing = $true
        }      


        $P = $Params | ConvertTo-Json
        Write-Verbose "Invoke-WebRequest Url: $Url P = $P"
        $ResponseJson = (Invoke-WebRequest @Params).Content
        $ResponseList = $ResponseJson | ConvertFrom-Json

        return $ResponseList
}


function Get-PostList{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [Array]$Data     
    )   
    if($Data -eq $Null){
        $Data = Invoke-GetNewPowerShell
        $Temp = (New-TemporaryFile).Fullname
        $Data | Export-Clixml -Path $Temp
    }
    [datetime]$epoch = '1970-01-01 00:00:00'    
    
    $List = $Data.data.children | Sort -Property 'created_utc'
    foreach($post in $List){
        $url = $post.data.url ; 
        $title = $post.data.title ; 
        $num_comments = $post.data.num_comments ; 
        $created_utc = $post.data.created_utc ; 
        $author = $post.data.author ; 
        $selftext = $post.data.selftext ; 
        [datetime]$When = $epoch.AddSeconds($created_utc)
        [String]$WhenStr = '{0}' -f ([system.string]::format('{0: MM-dd HH:mm}',$When))
        write-host -f DarkRed "==================================" ; 
        write-host -f DarkCyan "author $author" ; 
        write-host -f DarkCyan "num_comments $num_comments" ; 
        write-host -f Magenta "-- title $title" ; 
        write-host -f DarkGray "-- WhenStr $WhenStr" ; 
        write-host -f DarkYellow "`n$selftext" ; 
        write-host -f DarkRed "=================================="  ;
    }
    return $Temp
}