<#
.SYNOPSIS
    Midi Note to Frequency 
.DESCRIPTION
    Converts a Midi Note to a Frequency
.LINK
    https://en.wikipedia.org/wiki/MIDI_tuning_standard
#>
param(
# The midi note
[double]
$midiNote
)

$frequency = 440.0 * [Math]::Pow(
    2,
    (($MidiNote - 69)/12)
)
$frequency.pstypenames.add('Frequency')
$frequency