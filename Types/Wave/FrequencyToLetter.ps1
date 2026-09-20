<#
.SYNOPSIS
    Frequency to Letter
.DESCRIPTION
    Converts a Frequency to a Letter Note.
.NOTES
    The shortest path between frequency to friendly note is thru MIDI

    MIDI gives us a linear scale starting at 21 (A0) to 108 (C8).

    Thus we can map a frequency to a friendly note by:

    * Converting Frequency to MIDI
    * Rounding
    * Subtracting 21
    * Looking up the value
.LINK
    https://en.wikipedia.org/wiki/MIDI_tuning_standard
.LINK
    https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Simple_synth

#>
param(
# The frequency.
[double]
$Frequency = 440
)

# The 88 keys in the MIDI standard.
$midi88 = @(
    'A0','A#0','B0',
    'C1','C#1','D1','D#1','E1','F1','F#1','G1','G#1','A1','A#1','B1',
    'C2','C#2','D2','D#2','E2','F2','F#2','G2','G#2','A2','A#2','B2',
    'C3','C#3','D3','D#3','E3','F3','F#3','G3','G#3','A3','A#3','B3',
    'C4','C#4','D4','D#4','E4','F4','F#4','G4','G#4','A4','A#4','B4',
    'C5','C#5','D5','D#5','E5','F5','F#5','G5','G#5','A5','A#5','B5',
    'C6','C#6','D6','D#6','E6','F6','F#6','G6','G#6','A6','A#6','B6',
    'C7','C#7','D7','D#7','E7','F7','F#7','G7','G#7','A7','A#7','B7',
    'C8'
)

# Compute our note
$midiNote = 69 + 12 * [Math]::Log2($Frequency / 440)

# Round it
$rounded = [Math]::Round($midiNote)
# If the rounded note is within the 88 key range
if ($rounded -ge 21 -and $rounded -le (21 + 88)) {
    # output the rounded letter note.
    return $midi88[$rounded - 21]
}



