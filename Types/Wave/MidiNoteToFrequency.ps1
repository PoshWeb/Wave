<#
.SYNOPSIS
    Midi Note to Frequency 
.DESCRIPTION
    Converts a Midi Note to a Frequency
#>
param(
# The midi note
[double]
$midiNote
)

440.0 * [Math]::Pow(
    2,
    (($MidiNote - 69)/12)
)