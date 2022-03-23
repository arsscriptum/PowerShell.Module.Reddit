

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