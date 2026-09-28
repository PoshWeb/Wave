<#
.SYNOPSIS
    Sets the strings in a wave
.DESCRIPTION
    Sets any custom strings applied to a wave.

    A frequency can be played on any number of "strings"

    We can think of each vibration within a sound as a literal string, 
    vibrating at a frequency.  
    
    That's what a lot of "real" music actually is.

    Each string is a harmonic vibration.

    Strings can be present on the note or on this wave.

    If strings is a positive number, each string will vibrate at half the frequency.

    If strings is a negative number, each string will vibrate at twice the frequency.

    If strings can be a list of `[double[]]`, 
    each frequency will be generated at that ratio.
#>

if ($args.Length -eq 1 -and $args[0] -as [int]) {
    $this | Add-Member NoteProperty '#Strings' ($args[0] -as [int]) -Force
} else {
    # If we have a variable number of non-integer strings
    # unroll our list of arguments
    $unrollArgs = $args | . { process { $_ } }    
    # and pick out any items that are nonzero `[double]`
    $doubleStrings = foreach ($arg in $unrollArgs) {
        if ($null -ne ($arg -as [double])) {
            $arg -as [double]
        }
    }
    # these are each of the strings.    
    $this | Add-Member NoteProperty '#Strings' $doubleStrings -Force
}


