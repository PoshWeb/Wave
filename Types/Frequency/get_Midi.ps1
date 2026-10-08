<#
.SYNOPSIS
    Frequency to Midi Note
.DESCRIPTION
    Converts a Frequency to a Midi Note
.LINK
    https://en.wikipedia.org/wiki/MIDI_tuning_standard
#>
param()

69 + 12 * [Math]::Log2($this / 440)