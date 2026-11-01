<#
.SYNOPSIS
    Sets the weights on a wave
.DESCRIPTION
    When we play more than one frequency at a time,
    we can apply a weight to volume of each frequency.

    By default, each additional frequency will 
    have half of the weight of the previous frequency.

    Setting a custom set of weights allows us to change this default,
    and play different frequencies with different weights.        
.NOTES
    By default, each additional frequency will 
    have half of the weight of the previous frequency.

    Providing null or zero arguments will set the weight to one.
#>
param([double[]]$Weights)

if ($weights) {
    $this | Add-Member NoteProperty '#Weights' $weights -Force
} else {
    $this | Add-Member NoteProperty '#Weights' ([double[]]1) -Force
}


