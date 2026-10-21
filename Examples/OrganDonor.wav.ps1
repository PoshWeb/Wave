<#
.SYNOPSIS
    Organ Donor
.DESCRIPTION
    The Intro and Riff for Organ Donor, by DJ Shadow.
.LINK
    https://youtu.be/bfwXxRNVqi4
#>

wave bpm 256 strings 1.0, 0.5 instrument '<supersaw>,<sine>' note @(   
    "++"
    "
        $Cs5 ~ ~ $Cs5 
            $Gs5 ~ ~ $Gs5
        $fs5 ~ ~ $fs5
            $Gs5 ~ ~ $Gs5
        $e5 ~ ~ $e5
            $fs5 ~ ~ $fs5
        $ds5 ~ ~ $ds5
            $e5 ~ ~ $e5        
    " * 2
    
    "d#5 e5 f#5 g#5 ~ g#5 f#5 e5"

    "c#5 ~ ~ c#5 g#5 ~ ~ g#5"

    "$fs5 ~ ~ $fs5 $Gs5 ~ ~ $Gs5"

    "$e5 ~ ~ $e5 $fs5 ~ ~ $fs5"

    "d#5 ~ ~ d#5 e5 ~ ~ e5"

    "c#5 ~ ~ c#5 g#5 ~ ~ g#5"

    "$fs5 ~ ~ $fs5 $Gs5 ~ ~ $Gs5"
    
    "$e5 ~ ~ $e5 $fs5 ~ ~ $fs5"

    "d#5 e5 f#5 g#5 ~ g#5 f#5 e5"

    "--"

    "c#5 g#5 f#5 g#5 e5 f#5 d#5 e5" * 4
) play

# $riff = "c#5 g#5 f#5 g#5 e5 f#5 d#5 e5" * 2
# wave note $riff