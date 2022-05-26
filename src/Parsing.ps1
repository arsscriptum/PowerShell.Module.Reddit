<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-ParsedPostData{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Data received from Reddit, to be parsed")]
        [ValidateNotNullOrEmpty()]
        [Array]$Data     
    )   
    [datetime]$epoch = '1970-01-01 00:00:00'    
    $AllNames = [System.Collections.ArrayList]::new()
    $List = $Data.data.children
    foreach($post in $List){
        $author_fullname = $post.data.author_fullname;
        $thumbnail      = $post.data.thumbnail;
        $permalink      = $post.data.permalink;
        $post_url        = $post.data.url;
        $subreddit_id   = $post.data.subreddit_id;
        $name           = $post.data.name ; 
        $title          = $post.data.title ; 
        $link_title     = $post.data.link_title ; 
        $bodytext       = $post.data.body ; 
        $score          = $post.data.score ; 
        $created        = $post.data.created; 
        $author         = $post.data.author ; 
        $selftext       = $post.data.selftext ; 

        [datetime]$When =  ConvertFrom-Ctime -ctime $created
        [String]$WhenStr= $When.GetDateTimeFormats()[22]

        [pscustomobject]$obj = @{
            author_fullname     = $author_fullname
            thumbnail           = $thumbnail
            post_url            = $post_url
            subreddit_id        = $subreddit_id
            name                = $name
            title               = $title
            score               = $score
            LinkTitle           = $link_title
            BodyText            = $bodytext
            SelfText            = $selftext
            DateTime            = $When
            DateStr             = $WhenStr            
        }

        $Null=$AllNames.Add($obj)
    }
    return $AllNames | sort -property DateTime
}





