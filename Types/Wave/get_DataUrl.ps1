<#
.SYNOPSIS
    Wave Data Url
.DESCRIPTION
    Gets the Wave as a Data Url.
    
    This can be used as an audio source `<audio src>`.
#>
"data:audio/wav;base64,$(
    [Web.HttpUtility]::UrlPathEncode(
        [Convert]::ToBase64String(            
            $this.ToArray()                
        )
    )
)"
