<#
.SYNOPSIS
    Midi Note Frequency
.DESCRIPTION
    Gets the frequency of this midi note.
.LINK
    https://en.wikipedia.org/wiki/MIDI_tuning_standard
#>
$frequency = 440.0 * [Math]::Pow(
    2,
    (($This - 69)/12)
)
$frequency.pstypenames.add('Frequency')
$frequency