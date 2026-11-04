<#
.SYNOPSIS
    Sets Volume
.DESCRIPTION
    Sets a common volume used to generate the wave.
#>
param(
# The volume
[double]
$Volume = (1/([Math]::PI * 2))
)

$this.Volume = $Volume

return $this
