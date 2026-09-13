<#
.SYNOPSIS
    The Note Frequencies
.DESCRIPTION
    The frequencies for musical notes.
.NOTES
    Adapted from the [Web Audio API Keyboard Synth](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Simple_synth)
.LINK
    https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Simple_synth
#>
param([byte]$MaxOctave = 7)

if ($this.'#NoteFrequency') {
    return $this.'#NoteFrequency'
}

# We hard code the first octave and below
$noteFrequency = [Ordered]@{
    A0 = 27.5
    "A#0" = 29.13523509488062
    B0 = 30.867706328507754
    C1 = 32.70319566257483
    "C#1" = 34.64782887210901
    D1 = 36.70809598967595
    "D#1" = 38.89087296526011
    E1 = 41.20344461410874
    F1 = 43.65352892912549
    "F#1" = 46.2493028389543
    "G1" = 48.99942949771866
    "G#1" = 51.91308719749314
    "A1" = 55
    "A#1" = 58.27047018976124
    "B1" = 61.73541265701551
}

# For every additional octave
for ($octave = 2; $octave -le $MaxOctave; $octave++) {
    # get our notes in order
    $lastOctaveKeys = @($noteFrequency.Keys -match $($octave - 1))
    # go over each last note
    foreach ($lastOctave in $lastOctaveKeys) {
        # map the next note as double
        $noteFrequency["$($lastOctave -replace $(
            $octave - 1
        ), $octave)"] = $noteFrequency[$lastOctave] * 2
    }
}

# Add one more note for the final C
$noteFrequency["C$($MaxOctave + 1)"] = $noteFrequency."C$($MaxOctave)" * 2

$this | Add-Member NoteProperty '#NoteFrequency' $noteFrequency -Force

return $noteFrequency
