<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Reddit Module
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



function Script:AutoUpdateProgress {        # NOEXPORT
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber / $Script:TotalSteps) * 100)
    if($Script:StepNumber -lt $Script:TotalSteps){$Script:StepNumber++}
}

function Get-AuthorizationHeader { # NOEXPORT
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [PSCredential]
        [System.Management.Automation.CredentialAttribute()]$Credential
    )
    
    process {
        'Basic {0}' -f (
            [System.Convert]::ToBase64String(
                [System.Text.Encoding]::ASCII.GetBytes(
                    ('{0}:{1}' -f $Credential.UserName, $Credential.GetNetworkCredential().Password)
                )# End [System.Text.Encoding]::ASCII.GetBytes(
            )# End [System.Convert]::ToBase64String(
        )# End 'Basic {0}' -f
    }# End process
}# End Get-AuthorizationHeader

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

function Get-RedditUserCredentialID { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Id
    )
    $Credz = "PowerShell.Module.Reddit"

    if($Id -eq 'radicaltronic'){
        $Credz = "Reddit_radicaltronic"
    }
    
    return $Credz
}

function Get-RedditAppCredentialID { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Id
    )
    $Credz = "RedditScript"
   
    if($Id -eq 'radicaltronic'){
        $Credz = "RedditPowerShell_radicaltronic"   
    }
    
    return $Credz
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
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$CredId,        
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
            $NowTimeSeconds = ConvertTo-CTime($NowTime)
            $TimeExpiredSeconds = Get-RegistryValue -Path "$RegPath" -Name 'expiration_time'
        
            $Diff = $NowTimeSeconds-$TimeExpiredSeconds
            Write-Verbose "NowTimeSeconds $NowTimeSeconds, TimeExpiredSeconds $TimeExpiredSeconds, Diff $Diff"
            $Token = Get-RegistryValue -Path "$RegPath" -Name 'access_token'
            if($Diff -lt 0){
                $UpdateWhen = 1 - $Diff 
                Write-Verbose "Use existing $Token, Update in $UpdateWhen seconds"
                return $Token
            }
        }
        
        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID)
        if ($CredId -ne $Null) {
            $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID -Id $CredId)
            $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID -Id $CredId)
        }
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
        [DateTime]$ExpirationTime = $NowTime.AddSeconds($ExpiresInSecs)

        $NowTimeSeconds = ConvertTo-CTime($NowTime)
        $ExpirationTimeSeconds = ConvertTo-CTime($ExpirationTime)
   
       
        $Null=New-Item -Path $RegPath -ItemType Directory -Force
        $Null = Set-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $AccessToken 
        $Null = Set-RegistryValue -Path "$RegPath" -Name 'created_on' -Value $NowTimeSeconds
        $Null = Set-RegistryValue -Path "$RegPath" -Name 'expiration_time' -Value $ExpirationTimeSeconds
        $Null = Set-RegistryValue -Path "$RegPath" -Name 'scope' -Value $Scope

        return $AccessToken
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}




function Get-RedditMe{
    [CmdletBinding(SupportsShouldProcess)]
    param ()    


        $RegPath = Get-RedditModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
        $RegPath = Join-Path $RegPath 'oAuth'

       
        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID)
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




function Get-RedditUserData{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username,   
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("overview","submitted","comments","upvoted","downvoted","saved","hidden","gilded")]
        [String]$Type,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$CredId,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [int]$Count=100
    )   

        $RegPath = Get-RedditModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
        $RegPath = Join-Path $RegPath 'oAuth'
        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID)
        if ($PSBoundParameters.ContainsKey('CredId')) {
            $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID -Id $CredId)
            $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID -Id $CredId)
        }
        $ThisUser = $UserCredz.UserName
        $base = 'https://oauth.reddit.com'
        Write-Verbose "Using User Credentials: $($UserCredz.UserName) / $($UserCredz.GetNetworkCredential().Password)"
        Write-Verbose "Using App Credentials: $($AppCredz.UserName) / $($AppCredz.GetNetworkCredential().Password)"
        if(($Username -eq $Null)-Or($Username -eq '')){
            $Username = $ThisUser
        }
        $base = 'https://oauth.reddit.com'
        [String]$Url = "$base/user/$Username/$Type"

 
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken -CredId $CredId)
        $Params = @{
            Uri             = $Url
             Body            = @{
                username   = $Username
                limit      = $Count
            }
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = @{
                Authorization = $AuStr
            }
            Method          = 'GET'
            UseBasicParsing = $true
        }      
       
        $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
        Write-Verbose "Invoke-WebRequest Response: $Response"
        $Response
}

function Get-RedditComments{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username      
    )   

    $Response = Get-RedditUserData -Username $Username -Type "comments"   
    $Response
}

function Get-RedditPosts{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username     
    )   

    $Response = Get-RedditUserData -Username $Username -Type "submitted"
    $Response
}

function Remove-RedditPost{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username,        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Id
    )   

        $RegPath = Get-RedditModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
        $RegPath = Join-Path $RegPath 'oAuth'
        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID)


        Write-Verbose "Using User Credentials: $($UserCredz.UserName) / $($UserCredz.GetNetworkCredential().Password)"
        Write-Verbose "Using App Credentials: $($AppCredz.UserName) / $($AppCredz.GetNetworkCredential().Password)"

        $ThisUser = $UserCredz.UserName
        $base = 'https://oauth.reddit.com'
        
        if(($Username -eq $Null)-Or($Username -eq '')){
            $Username = $ThisUser
        }
        $base = 'https://oauth.reddit.com'
        [String]$Url = "$base/api/del"

 
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken)
        $Params = @{
            Uri             = $Url
             Body            = @{
                id         = $Id
            grant_type  = 'password'
            username    = $Username  
            password    = $UserCredz.GetNetworkCredential().Password                    
            }
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = @{
                Authorization = $AuStr
            }
            Method          = 'POST'
            UseBasicParsing = $true
        }      
       
        $ResponseContent = (Invoke-WebRequest  @Params).Content
        Write-Verbose "Invoke-WebRequest Response: $ResponseContent"
        $Response
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
        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID)
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
        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID)
        $User = $UserCredz.UserName
        $base = 'https://oauth.reddit.com'
        [String]$Url = "$base/$Username/about"
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken)
       
        $HeadersData = @{
            Authorization = $AuStr
        }
        $BodyData = @{
            grant_type  = 'password'
            username    = $Username  
            password    = $UserCredz.GetNetworkCredential().Password    
            id          = ''
        }
        $Params = @{
            Uri             = $Url
            Body            = $BodyData
            UserAgent       = Get-RedditModuleUserAgent
            Headers         = $HeadersData
            Method          = 'POST'
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

        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID)
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



function Get-PostNames{
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
    $AllNames = [System.Collections.ArrayList]::new()
    $List = $Data.data.children
    foreach($post in $List){
        $name = $post.data.name ; 
        $title = $post.data.title ; 
        $created_utc = $post.data.created_utc ; 
        $author = $post.data.author ; 
        $selftext = $post.data.selftext ; 
        [datetime]$When = $epoch.AddSeconds($created_utc)
        [String]$WhenStr = '{0}' -f ([system.string]::format('{0:MM-dd HH:mm}',$When))
        [pscustomobject]$obj = @{
            Id = $name
            Title = $title
            Date = $WhenStr
        }
        $Null=$AllNames.Add($obj)
    }
    return $AllNames
}





function Remove-AllRedditPosts{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$CredId,
        [switch]$Force
    )   

        if ($PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host '[Remove-AllRedditPosts] ' -f DarkRed -NoNewLine
            Write-Host "Verbose OUTPUT" -f Yellow            
        }
        $RegPath = Get-RedditModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
        $RegPath = Join-Path $RegPath 'oAuth'
        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID -Id $CredId)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID -Id $CredId)

            
        $ThisUser = $UserCredz.UserName

        
        Write-Verbose "Using User Credentials: $($UserCredz.UserName) / $($UserCredz.GetNetworkCredential().Password)"
        Write-Verbose "Using App Credentials: $($AppCredz.UserName) / $($AppCredz.GetNetworkCredential().Password)"

        if(($Username -eq $Null)-Or($Username -eq '')){
            $Username = $ThisUser
        }
 
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken -CredId $CredId -Force:$Force)
           
        $Deleted = [System.Collections.ArrayList]::new()
        do{
            $Response =  Get-RedditUserData -Username $Username -Type "comments" -Count 10
            $Count = $Response.data.children.Count
            $PostNames = Get-PostNames $Response
            $PostNamesCount = $PostNames.Count
            Write-Verbose "$PostNamesCount post to remove"
            $base = 'https://oauth.reddit.com'
            [String]$Url = "$base/api/del"

            $Script:TotalSteps = $PostNames.Count
            $Script:StepNumber = 0
            $Script:ProgressTitle = "Deleting Posts from $Username"


            $HeadersData = @{
                Authorization = $AuStr
            }
            $BodyData = @{
                grant_type  = 'password'
                username    = $Username  
                password    = $UserCredz.GetNetworkCredential().Password    
                id          = ''
            }
            $Params = @{
                Uri             = $Url
                Body            = $BodyData
                UserAgent       = Get-RedditModuleUserAgent
                Headers         = $HeadersData
                Method          = 'POST'
                UseBasicParsing = $true
            }             
            ForEach($postdata in $PostNames){
                $postid = $postdata.Id
                $title = $postdata.Title
                $Date = $postdata.Date
                $Params['Body']['id'] = $postid
                write-Verbose "Deleting $postid [$title]"
                $ResponseContent = (Invoke-WebRequest @Params).Content
                $Script:ProgressMessage = "Deleting $postid ($Script:StepNumber / $Script:TotalSteps)"
                if ($PSBoundParameters.ContainsKey('Verbose')) {
                    write-Verbose "$Script:ProgressMessage"
                }
                else{
                    AutoUpdateProgress    
                }
                
                [pscustomobject]$obj = @{
                    Id = $postid
                    Title = $title
                    Date = $Date
                }
                
                foreach($d in $Deleted){
                    $DId = $d.Id
                    if($DId -eq $postid)
                    {
                        throw "dupe"
                    }
                }
                $Null = $Deleted.Add($obj)
            }            
        }
        while($Count -gt 0)
    return $Deleted
}
