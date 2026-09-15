<#
.SYNOPSIS
    Frequency to Midi Note
.DESCRIPTION
    Converts a Frequency to a Midi Note
.LINK
    https://en.wikipedia.org/wiki/MIDI_tuning_standard
#>
param($Frequency)

69 + 12 * [Math]::Log2($Frequency / 440)