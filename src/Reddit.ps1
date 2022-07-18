<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

function Initialize-PersonalRedditModule{
    $coded_par="YJgcD5IelqqGHo62EHJOOaCeyFFfNe+Kl7zJ2G4kV8DsdOyYuWRaFslikpMxnBDxCBWjCzWQr5zvc6DAtoK7oqpeWAhp1cpZhX2iI8PQ1gV92jLaK0AzRnsAq/4amL6thnmef/O2FnXa3t6iYwgTbEGpfk7v44CPGSsMQ7TzYhCvuGn/U6EK9l37PI1nn0GMPD0MgtlDrYQgR3ZMPm044eFXvsGrk2uslXS5AlgAeuU6eaSFoDoxI3NhwJKbnHmrX3X12mPl1Yw3B0kjynnqewdL16l/gi7uY6r+besKw34="
    $coded_lap='tcguZ1ELVkMGAwlbwHVOjrddjhoM1h5RyblvpGTc78Kjtg1nrOTW/9qA7/xLG9PXPYFd58hQlORRxNRnsC+ntTf+xexW9LVevyBBZsEjtTiy+5Do/S9gf+tb9ylNOQjqkr6m7Ay9s+hAAWSHPKlHVpHsNfYL8EqABo0cM8uSgo0GqJPW75RqRO2ODDZmA7sQZovGa43xLwtZZ6a+Z4tu87d4NrbngazA705tAeyj1Ov66nScCWd+aIrv6v+R5qrE'
    $exec = Decrypt-String -EncryptedString $coded_par -UseSystemUUID
    Invoke-Expression "$exec"
} 

function Initialize-RedditModule{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)][String]$Username,
        [Parameter(Mandatory=$true,Position=1)][String]$Password,
        [Parameter(Mandatory=$true,Position=2)][String]$Client,
        [Parameter(Mandatory=$true,Position=3)][String]$Secret
    ) 
    Register-AppCredentials -Id (Get-RedditUserCredentialID) -Username $Username -Password $Password
    Register-AppCredentials -Id (Get-RedditAppCredentialID) -Username $Client -Password $Secret
}

function Write-ProgressHelper{

    param () 
    try{
        if($Script:TotalSteps -eq 0){return}
        Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber /  $Script:TotalSteps) * 100)
    }catch{
        Write-Host "⌛ StepNumber $Script:StepNumber" -f DarkYellow
        Write-Host "⌛ ScriptSteps $Script:TotalSteps" -f DarkYellow
        $val = (($Script:StepNumber / $Script:TotalSteps) * 100)
        Write-Host "⌛ PercentComplete $val" -f DarkYellow
        Show-ExceptionDetails $_ -ShowStack
    }
}

function Get-AuthorizationHeader{
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

function Get-RedditUrl{
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

    $DevAccount = Get-RedditDevAccountOverride
    if(($Id -eq 'radicaltronic')-or($DevAccount -eq 'radicaltronic')){
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
    $DevAccount = Get-RedditDevAccountOverride

    if(($Id -eq 'radicaltronic')-or($DevAccount -eq 'radicaltronic')){
        $Credz = "RedditPowerShell_radicaltronic"   
    }

    return $Credz
}
function Get-RedditDevAccountOverride { 
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $RegPath = Get-RedditModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    $DevAccount = ''
    $DevAccountOverride = Test-RegistryValue -Path "$RegPath" -Entry 'override_dev_account'
    if($DevAccountOverride){
        $DevAccount = Get-RegistryValue -Path "$RegPath" -Entry 'override_dev_account'
    }
    
    return $DevAccount
}

function Set-RedditDevAccountOverride { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Id
    )

    $RegPath = Get-RedditModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    New-RegistryValue -Path "$RegPath" -Entry 'override_dev_account' -Value "$Id" 'String'
    Set-RegistryValue -Path "$RegPath" -Entry 'override_dev_account' -Value "$Id"
    
    return $DevAccount
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




function Set-RedditServer {
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


function Get-RedditServer {      
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-RedditModuleRegistryPath
    $Server = (Get-ItemProperty -Path "$RegPath" -Name 'hostname' -ErrorAction Ignore).hostname
    if( $Server -ne $null ) { return $Server }
     
    if( $Env:DEFAULT_REDDIT_SERVER -ne $null ) { return $Env:DEFAULT_REDDIT_SERVER  }
    return $null
}

function Get-RedditModuleRegistryPath { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Path = "$ENV:OrganizationHKCU\$ModuleName"
   
    return $Path
}



function Get-RedditModuleInformation{
    [CmdletBinding()]
    param ()
    try{
        if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
        $ModuleName = $ExecutionContext.SessionState.Module
        $ModuleScriptPath = $MyInvocation.MyCommand.Path
        $ModuleInstallPath = (Get-Item "$ModuleScriptPath").DirectoryName
        $CurrentScriptName = $MyInvocation.MyCommand.Name
        $RegistryPath = "$ENV:OrganizationHKCU\$ModuleName"
        $ModuleSystemPath = (Resolve-Path "$ModuleInstallPath\..").Path
        $ModuleInformation = @{
            ModuleName        = $ModuleName
            ModulePath        = $ModuleScriptPath
            ScriptName        = $CurrentScriptName
            RegistryRoot      = $RegistryPath
            ModuleSystemPath  = $ModuleSystemPath
        }
        return $ModuleInformation        
    }catch{
        Show-ExceptionDetails $_ 
    }
}

function Uninstall-RedditModule { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModInfo = Get-RedditModuleInformation
    $RedditModPath = $ModInfo.ModulePath
    $RegistryPath = $ModInfo.RegistryPath
    $ModuleSystemPath = $ModInfo.ModuleSystemPath
    Write-ModLog "Uninstall Reddit Module : Delete Registry Data in $RegistryPath"
    $Null = Remove-Item "$RegistryPath" -Force -Recurse -ErrorAction Ignore
    Write-ModLog "Uninstall Reddit Module : Remove Module in memory: $ModuleName"
    Remove-Module -Name "$ModuleName" -Force
    Write-ModLog "Uninstall Reddit Module : Uninstall Module from profile : $ModuleName"
    Uninstall-Module -Name "$ModuleName" -Force

    Push-location "$ModuleSystemPath"
    $Null = Remove-Item "$RedditModPath" -Force -Recurse -ErrorAction Ignore
    Pop-Location
    Write-ModLog "Uninstall-RedditModule Done"
}




function Get-RedditModuleInformation{
    [CmdletBinding()]
    param ()
    try{
        if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
        $ModuleName = $ExecutionContext.SessionState.Module
        $ModuleScriptPath = $ScriptMyInvocation = $Script:MyInvocation.MyCommand.Path
        $ModuleScriptPath = (Get-Item "$ModuleScriptPath").DirectoryName
        $CurrentScriptName = $Script:MyInvocation.MyCommand.Name
        $RegistryPath = "$ENV:OrganizationHKCU\$ModuleName"
        $ModuleInformation = @{
            ModuleName        = $ModuleName
            ModulePath        = $ModuleScriptPath
            ScriptName        = $CurrentScriptName
            RegistryRoot      = $RegistryPath
        }
        return $ModuleInformation        
    }catch{
        Show-ExceptionDetails $_ 
    }
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
        $ErrorType = $Response.error
        if($ErrorType -ne $Null){
            throw "ERROR RETURNED $ErrorType"
            return $Null
        }

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



function Remove-AllRedditEntries{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    )

    $Deleted = Remove-AllRedditPosts
    $Deleted += Remove-AllRedditComments
    return $Deleted
}


function Remove-AllRedditPosts{
[CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$ForceDeleteAll,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$Test
    )   
    $TestMode = $False
    if ($PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host '[Remove-AllRedditPosts] ' -f DarkRed -NoNewLine
        Write-Host "Verbose OUTPUT" -f DarkYellow            
    }
    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or($PSBoundParameters.ContainsKey('Test')))) {
        Write-Host '[Remove-AllRedditPosts] ' -f DarkRed -NoNewLine
        Write-Host "TEST ONLY" -f DarkYellow            
        $TestMode = $True
    }
    $RedditPermanentComments = Get-RegListItemList -Id "RedditPermanentPosts"

    
    $allposts = Get-RedditSubmittedPosts
    $NumPosts = $allposts.Count
    Write-Host -n -f DarkRed "[REDDIT] " ; Write-Host -f DarkYellow "Remove $NumPosts Submitted Posts"
   
    $Script:StepNumber = 0
    $Script:TotalSteps = $allposts.Count
    $Script:ProgressMessage = "Removing Posts"
    $Script:ProgressTitle = "Removing Submitted Posts ($Script:TotalSteps)"
    $Script:DeletedPosts = @()
    Write-ProgressHelper    
    ForEach($p in $allposts){ 
        $idp = $p.name ; 

        
        if($ForceDeleteAll -eq $False){
            $ShouldKeep = $RedditPermanentComments.Contains($idp)
            if($ShouldKeep -eq $True){
                Write-Host '[Remove-AllRedditPosts] ' -f DarkCyan -NoNewLine
                Write-Host "Post $idp is permanent, keeping..." -f DarkGreen
                continue;
            }
        }
        if($TestMode -eq $False){
            Remove-RedditPost -Id "$idp";   
            $Script:DeletedPosts += $idp
        }else{
            Write-Host '[TESTMODE] ' -f DarkRed -NoNewLine
            Write-Host "Would Delete $idp" -f DarkYellow
        }

        $Script:ProgressMessage = "Deleting $idp ($Script:StepNumber / $Script:TotalSteps)"
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            write-Verbose "$Script:ProgressMessage"
        }
        else{
                Write-ProgressHelper    
                $Script:StepNumber++
        }
    }
   
    $numdeleted = $Script:DeletedPosts.Count
    Write-Host "Deleted $numdeleted posts ($numdeleted / $NumPosts total)"
    return $Script:DeletedPosts
}


function Remove-AllRedditComments{
 [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$ForceDeleteAll,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$Test
    )   
    $TestMode = $False
    if ($PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host '[Remove-AllRedditComments] ' -f DarkRed -NoNewLine
        Write-Host "Verbose OUTPUT" -f DarkYellow            
    }
    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or($PSBoundParameters.ContainsKey('Test')))) {
        Write-Host '[Remove-AllRedditComments] ' -f DarkRed -NoNewLine
        Write-Host "TEST ONLY" -f DarkYellow            
        $TestMode = $True
    }
    $RedditPermanentComments = Get-RegListItemList -Id "RedditPermanentComments"

    $allposts = Get-RedditComments
    $NumComments = $allposts.Count
    Write-Host -n -f DarkRed "[REDDIT] " ; Write-Host -f DarkYellow "Remove $NumComments Comments"

    $Script:ProgressTitle = "Removing Comments"
    $Script:DeletedPosts = @()
    $Script:StepNumber = 0
    $Script:TotalSteps = $allposts.Count
    $Script:ProgressMessage = "Removing Comments ($Script:TotalSteps)"
    Write-ProgressHelper    
    ForEach($p in $allposts){ 
        $idp = $p.name ; 
        
        if($ForceDeleteAll -eq $False){
            $ShouldKeep = $RedditPermanentComments.Contains($idp)
            if($ShouldKeep -eq $True){
                Write-Host '[Remove-AllRedditComments] ' -f DarkCyan -NoNewLine
                Write-Host "Post $idp is permanent, keeping..." -f DarkGreen
                continue;
            }
        }
        if($TestMode -eq $False){
            Remove-RedditPost -Id "$idp";   
            $Script:DeletedPosts += $idp
        }else{
            Write-Host '[TESTMODE] ' -f DarkRed -NoNewLine
            Write-Host "Would Delete $idp" -f DarkYellow
        }
        
        $Script:ProgressMessage = "Deleting $idp ($Script:StepNumber / $Script:TotalSteps)"
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            write-Verbose "$Script:ProgressMessage"
        }
        else{
                Write-ProgressHelper    
                $Script:StepNumber++
        }
    }

    $numtotal = $allposts.Count
    $numdeleted = $Script:DeletedPosts.Count
    Write-Host "Deleted $numdeleted posts ($numdeleted / $numtotal total)"
    return $Script:DeletedPosts
}

function Get-RedditCommentsCount{
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
            Write-Host '[Get-RedditCommentsCount] ' -f DarkRed -NoNewLine
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
            $PostNames = Get-ParsedPostData $Response
            $PostNamesCount = $PostNames.Count
            Write-Verbose "$PostNamesCount post to remove"
            $index = $Response.data.children.Count - 1
            $after = $Response.data.children[$index].data.name
            
            $Response =  Get-RedditUserData -Username $Username -Type "comments" -Count $GroupBy -After $after
        }
        
    return $TotalCount
}


function Get-RedditComments{
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
            Write-Host '[Get-RedditComments] ' -f DarkRed -NoNewLine
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
            $PostNames = Get-ParsedPostData $Response
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


function Get-RedditSubmittedPosts{
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
            Write-Host '[Get-RedditSubmittedPosts] ' -f DarkRed -NoNewLine
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
        $Response =  Get-RedditUserData -Username $Username -Type "submitted" -Count $GroupBy
        $Count = $Response.data.children.Count
        while($Count -gt 0){
            $Count = $Response.data.children.Count
            if($Count -eq 0){break;}
            $TotalCount += $Count
            $PostNames = Get-ParsedPostData $Response
            $PostNamesCount = $PostNames.Count
            Write-Verbose "$PostNamesCount post to remove"
            $index = $Response.data.children.Count - 1
            $after = $Response.data.children[$index].data.name
            ForEach($postdata in $PostNames){
                $Null = $ToBeDeleted.Add($postdata)
            }            
            $Response =  Get-RedditUserData -Username $Username -Type "submitted" -Count $GroupBy -After $after
        }
        
    return $ToBeDeleted
}
