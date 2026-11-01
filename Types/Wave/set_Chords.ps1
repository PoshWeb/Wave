<#
.SYNOPSIS
    Sets the chords in a wave
.DESCRIPTION
    Sets any custom chords applied to a wave.

    A frequency can be played on any number of "chords"

    We can think of each vibration within a sound as a literal string, 
    vibrating at a frequency.  
    
    That's what a lot of "real" music actually is.

    Each string is a harmonic vibration.

    Chords can be present on the note or on the wave.

    If chords is a positive number, each string will vibrate at half the frequency.

    If chords is a negative number, each string will vibrate at twice the frequency.

    If chords can be a list of `[double[]]`, 
    each frequency will be generated at that ratio.
#>

if ($args.Length -eq 1 -and $args[0] -as [int]) {
    $this | Add-Member NoteProperty '#chords' ($args[0] -as [int]) -Force
} else {
    # If we have a variable number of non-integer chords
    # unroll our list of arguments
    $unrollArgs = $args | . { process { $_ } }    
    # and pick out any items that are nonzero `[double]`
    $doublechords = foreach ($arg in $unrollArgs) {
        if ($null -ne ($arg -as [double])) {
            $arg -as [double]
        }
    }
    # these are each of the chords.    
    $this | Add-Member NoteProperty '#chords' $doublechords -Force
}


