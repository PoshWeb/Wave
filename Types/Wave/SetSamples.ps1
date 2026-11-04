<#
.SYNOPSIS
    Sets Wave Samples
.DESCRIPTION
    Sets the samples in the Wave.

    This changes the wave.
#>
param(
# The new samples
[double[]]
$Samples
)

$this.Samples = $samples
return $this

