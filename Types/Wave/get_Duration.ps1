<#
.SYNOPSIS
    Gets Wave Duration        
.DESCRIPTION
    Gets the duration of a wave file.

    This should be the length of it's PCM data, divided by bytes per second.
#>
$bps = $this.BytesPerSecond
if ($bps) {
    [TimeSpan]::FromSeconds($this.'#data'.length / $bps)
}

