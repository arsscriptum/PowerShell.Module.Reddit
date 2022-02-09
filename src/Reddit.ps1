<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Reddit Module
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



function Script:AutoUpdateProgress {        # NOEXPORT
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber / $Script:TotalSteps) * 100)
    if($Script:StepNumber -lt $Script:TotalSteps){$Script:StepNumber++}
}


function Test-RedditLog{ 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $Path = Get-RedditModuleRegistryPath
    Write-MOk "Path is $Path"
    Write-ChannelMessage "Path is $Path"
    Write-ChannelResult "Path is $Path"
}


function Get-RedditModuleRegistryPath { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Path = "$ENV:OrganizationHKCU\$ModuleName\Reddit.com"
   
    return $Path
}

function Set-RedditAccessToken {
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

function Get-RedditAccessToken {
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