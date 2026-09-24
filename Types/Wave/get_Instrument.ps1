<#
.SYNOPSIS
    Gets Wave Instrument
.DESCRIPTION
    Gets the instruments used to play a wave, if any have been set.    
.NOTES
    At present, this stores the instrument list in memory.
    
    It does not attempt any detection of instruments for existing waves.
#>
return $this.'#Instrument'
