<#
.SYNOPSIS
    Gets the chords in a wave
.DESCRIPTION
    Gets any custom chords applied to a wave.

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
return $this.'#chords'
