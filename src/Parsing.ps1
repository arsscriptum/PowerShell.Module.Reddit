
<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Reddit Module
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


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
        $link_title = $post.data.link_title ; 
        $bodytext = $post.data.body ; 
        $score = $post.data.score ; 
        $created_utc = $post.data.created_utc ; 
        $author = $post.data.author ; 
        $selftext = $post.data.selftext ; 
        [datetime]$When =  ConvertFrom-Ctime -ctime $created_utc
        [String]$WhenStr = '{0}' -f ([system.string]::format('{0:MM-dd HH:mm}',$When))
        [pscustomobject]$obj = @{
            Id = $name
            Title = $title
            Score = $Score
            Date = $WhenStr
            LinkTitle = $link_title
            BodyText = $bodytext
            SelfText = $selftext
        }
        $Null=$AllNames.Add($obj)
    }
    return $AllNames
}





