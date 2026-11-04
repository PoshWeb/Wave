<#
.SYNOPSIS
    Sets the beats per minute
.DESCRIPTION
    Sets a common BPM used to generate notes in a wave.
#>
param(
$BPM
)

$this.BPM = $BPM
return $this
