<#
.SYNOPSIS
    Gets an HTML wave
.DESCRIPTION
    Gets a waveform as HTML.  
    
    By default, renders an `<audio>` element with the current wave as the source.
.NOTES
    This can be customized by setting the HTML.
#>
param()
if ($this.'#HTML') {
    @(foreach ($object in $this.'#HTML') {
        if ($object -is [xml]) {
            $object.OuterXml
        }
        elseif ($object.html) {
            $object.html
        } elseif ($object.ToString) {
            $object.ToString()
        }
    }) -join [Environment]::NewLine
    return 
}
return "<audio controls='' src='$($this.DataUrl)'></audio>"