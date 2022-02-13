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

    #if($Id -eq 'radicaltronic'){
    if($true){
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
   
    #if($Id -eq 'radicaltronic'){
    if($true){
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
        [ValidateNotNullOrEmpty()]
        [String]$After="",
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
        if($After -ne ''){
             $Params['Body']['after'] = $after
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


        Write-Verbose "Invoke-WebRequest Url: $Url"
        Write-Verbose "Params = $Params"
        $Response = (Invoke-WebRequest @Params).Content
        $ResponseJson = $Response | ConvertFrom-Json
        Write-Verbose "Invoke-WebRequest Response: $Response"
        $Response
}



function Invoke-GetNewUkraine{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Search
    )   

        $UserCredz = Get-AppCredentials (Get-RedditUserCredentialID)
        $AppCredz = Get-AppCredentials (Get-RedditAppCredentialID)
        $ThisUser = $UserCredz.UserName
        $base = 'https://oauth.reddit.com'
        
        if(($Username -eq $Null)-Or($Username -eq '')){
            $Username = $ThisUser
        }
        [String]$Url = "$base/r/ukraine/new"
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken)
        $HeadersData = @{
            Authorization = $AuStr
            user        = $Username
        }
        $BodyData = @{
            grant_type  = 'password'
            limit        = 100
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

        Write-Host -n -f Cyan "REDDIT SEARCH "      
        Write-Host -f DarkCyan "Searching SubReddit with title like $Search..."
        Write-Verbose "Invoke-WebRequest Url: $Url"
        Write-Verbose "Params = $Params"
        $Response = (Invoke-WebRequest @Params).Content
        $ResponseJson = $Response | ConvertFrom-Json
        Write-Verbose "Invoke-WebRequest Response: $Response"

        $DataList =  $ResponseList.data.children.data
        if($Search -ne $Null){
            ForEach($data in $DataList){
                $Title = $Data.Title
                $Name = $Data.Name
                if($Title -match $Search){
                  return $Data
            }
        }
}




function Remove-AllRedditPosts{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$CredId='',
        [switch]$Force,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [int]$GroupBy = 50
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

    
        Write-Verbose "Using User Credentials: $($UserCredz.UserName) / $($UserCredz.GetNetworkCredential().Password)"
        Write-Verbose "Using App Credentials: $($AppCredz.UserName) / $($AppCredz.GetNetworkCredential().Password)"
    
        $ToBeDeleted=(Get-RedditPosts -Username $Username -CredId $CredId -Force  -GroupBy $GroupBy).Id
        $ToBeDeletedCount = $ToBeDeleted.Count
        Write-Verbose "$PostNamesCount post to remove"
        $base = 'https://oauth.reddit.com'
        [String]$Url = "$base/api/del"
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken -CredId $CredId -Force:$false)

        $Script:TotalSteps = $ToBeDeletedCount
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
     
            ForEach($postid in $ToBeDeleted){
 
                $Params['Body']['id'] = $postid
                write-Verbose "Deleting $postid"
                $ResponseContent = (Invoke-WebRequest @Params).Content
                $Script:ProgressMessage = "Deleting $postid ($Script:StepNumber / $Script:TotalSteps)"
                if ($PSBoundParameters.ContainsKey('Verbose')) {
                    write-Verbose "$Script:ProgressMessage"
                }
                else{
                    AutoUpdateProgress    
                }
        
           
            }            
 

}



function Get-RedditPostsCount{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$CredId,
        [switch]$Force,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [int]$GroupBy = 50
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

        $TotalCount = 0
        $ThisUser = $UserCredz.UserName

        
        Write-Verbose "Using User Credentials: $($UserCredz.UserName) / $($UserCredz.GetNetworkCredential().Password)"
        Write-Verbose "Using App Credentials: $($AppCredz.UserName) / $($AppCredz.GetNetworkCredential().Password)"

        if(($Username -eq $Null)-Or($Username -eq '')){
            $Username = $ThisUser
        }
 
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken -CredId $CredId -Force:$Force)

        $Response =  Get-RedditUserData -Username $Username -Type "comments" -Count $GroupBy
        $Count = $Response.data.children.Count
        while($Count -gt 0){
            $Count = $Response.data.children.Count
            if($Count -eq 0){break;}
            $TotalCount += $Count
            $PostNames = Get-PostNames $Response
            $PostNamesCount = $PostNames.Count
            Write-Verbose "$PostNamesCount post to remove"
            $index = $Response.data.children.Count - 1
            $after = $Response.data.children[$index].data.name
            
            $Response =  Get-RedditUserData -Username $Username -Type "comments" -Count $GroupBy -After $after
        }
        
    return $TotalCount
}


function Get-RedditPosts{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$CredId,
        [switch]$Force,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [int]$GroupBy = 50
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

        $TotalCount = 0
        $ThisUser = $UserCredz.UserName

        
        Write-Verbose "Using User Credentials: $($UserCredz.UserName) / $($UserCredz.GetNetworkCredential().Password)"
        Write-Verbose "Using App Credentials: $($AppCredz.UserName) / $($AppCredz.GetNetworkCredential().Password)"

        if(($Username -eq $Null)-Or($Username -eq '')){
            $Username = $ThisUser
        }
 
        $AuStr = 'bearer ' + (Get-RedditAuthenticationToken -CredId $CredId -Force:$Force)
           
        $ToBeDeleted = [System.Collections.ArrayList]::new()
        $Response =  Get-RedditUserData -Username $Username -Type "comments" -Count $GroupBy
        $Count = $Response.data.children.Count
        while($Count -gt 0){
            $Count = $Response.data.children.Count
            if($Count -eq 0){break;}
            $TotalCount += $Count
            $PostNames = Get-PostNames $Response
            $PostNamesCount = $PostNames.Count
            Write-Verbose "$PostNamesCount post to remove"
            $index = $Response.data.children.Count - 1
            $after = $Response.data.children[$index].data.name
            ForEach($postdata in $PostNames){
                $Null = $ToBeDeleted.Add($postdata)
            }            
            $Response =  Get-RedditUserData -Username $Username -Type "comments" -Count $GroupBy -After $after
        }
        
    return $ToBeDeleted
}
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUh/qVmOrtP5EgTUmFMq2HF9a9
# bO+gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUHyWELLmtXwL3vHP6M6Os
# uOxUbTIwDQYJKoZIhvcNAQEBBQAEggEA5z3mVcTYIuXwmnm0HWddbmvwYHUlE/oN
# HKQjdlym5wV06B7f4VmMkhnbsS0tZ1p7Udgwainl5lHZLhh7M2xDVu1uE/folHwx
# 3YqBWkVXiIKwx3LyEI/f8lZafN2x8tZwDlw6pkjrd0CEGRKENL03FXCH73NJSZKU
# ADDh7giGQA8ty+aLttKEGRBMu2mfd4Q0eFKIeJkWHkscvWUgd/+0CAmz92Em2xCa
# mALXA/Rh03lw6tb+TN4Ax85q1ViIzZ3ph/9MmQScNPt2Lt2dAMtrWI0wqxq5sXEw
# OBai892wbrdb1UP/RRnRTkC1GoVP+1SkkI4Uyhq5HkodAZbyVAiVhw==
# SIG # End signature block
