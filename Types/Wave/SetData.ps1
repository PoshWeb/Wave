<#
.SYNOPSIS
    Sets Wave Data
.DESCRIPTION
    Sets the PCM data in a wave.
.LINK
    https://en.wikipedia.org/wiki/Pulse-code_modulation
#>
param(
# The Pulse Code Modulation wave data.
[byte[]]$data
)

$this.Data = $data
return $this