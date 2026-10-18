<#
.SYNOPSIS
    Flattens a frequency
.DESCRIPTION
    Flattens a frequency by a distance in semitones.

    This will return a lower frequency.

    The distance defaults to 1, which is equivalent to `.Flat`
#>
param(
[double]$Distance=1
)

$Altered =  ($this * [Math]::Pow(2, (($Distance * -1.0)/12)))
$Altered.pstypenames.add('Frequency')
$Altered

