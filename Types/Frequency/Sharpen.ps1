<#
.SYNOPSIS
    Sharpens a frequency
.DESCRIPTION
    Sharpens a frequency by a distance in semitones.

    This will return a higher frequency.

    The distance defaults to 1, which is equivalent to `.Sharp`
#>
param(
# The distance, in semitones.
[double]$Distance=1
)

$Altered =  ($this / [Math]::Pow(2, (($Distance * -1.0)/12)))    
$Altered.pstypenames.add('Frequency')
$Altered

