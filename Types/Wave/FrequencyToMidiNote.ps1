<#
.SYNOPSIS
    Frequency to Midi Note
.DESCRIPTION
    Converts a Frequency to a Midi Note
.LINK
    https://en.wikipedia.org/wiki/MIDI_tuning_standard
#>
param($Frequency)

$midiNote = 69 + 12 * [Math]::Log($Frequency / 440,2)
$midiNote.pstypenames.add('MidiNote')
$midiNote