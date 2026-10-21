<#
.SYNOPSIS
    Gets Wave Melody
.DESCRIPTION
    Gets the melody played by the wave, if one has been set.

    Each step in the melody is effectively
    an instruction for what frequency to play and when.
.NOTES
    At present, this stores a melody in memory.
    
    It does not attempt any detection of melody for existing waves.
#>
[OutputType([PSObject])]
param()

return $This.'#Melody'