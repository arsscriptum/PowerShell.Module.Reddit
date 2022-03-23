<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Reddit Module
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

#===============================================================================
# 
#===============================================================================

class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'Reddit'
    [ConsoleColor]$TitleColor = 'DarkRed'
    [ConsoleColor]$MessageColor = 'Gray'
    [ConsoleColor]$HighlightColor = 'Yellow'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}
$Script:ChannelProps = [ChannelProperties]::new()



function Write-ModLog{                
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight      
    )

    if($Highlight){
        Write-Host "[$($Script:ChannelProps.Channel)] " -f $($Script:ChannelProps.TitleColor) -NoNewLine
        Write-Host "$Message" -f $($Script:ChannelProps.HighlightColor)
    }else{
        Write-Host "[$($Script:ChannelProps.Channel)] " -f $($Script:ChannelProps.TitleColor) -NoNewLine
        Write-Host "$Message" -f $($Script:ChannelProps.MessageColor)
    }

}


function Write-Result{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [switch]$Result
    )

    if($Result -eq $True){
        Write-Host -n -f DarkGreen "✅ SUCCESS " 
        Write-Host "$Message"
    }else{
        Write-Host -n -f DarkRed  "❗❗❗ Error "
        Write-Host -f DarkYellow  "$Message"
    }
}


