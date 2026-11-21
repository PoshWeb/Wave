<#
.SYNOPSIS
    Wave Speed
.DESCRIPTION
    Creates a new wave at a different speed.

    This stretches time, which bends the frequencies.

    Roughly speaking, every 1.05x increase in speed will move notes up a semitone.
.NOTES
    Speed can be any number.  
    
    Providing negative speeds will reverse the audio.
.EXAMPLE
    # Speeds a4 up by 1.05, roughly turning it into a#4
    wave note a4 speed 1.05 play
.EXAMPLE
    # Plays a4 backward
    wave note a4 speed -1 play
.EXAMPLE
    # Speeds cafe up by 1.10, roughly going up a tone
    wave note cafe speed 1.10 play
.EXAMPLE
    # Backmasks cafe
    wave note cafe speed -1 play
.EXAMPLE    
    # Plays cafe at twice the speed
    # Halves the time and goes up an octave
    wave note cafe speed 2 play
.EXAMPLE
    # Plays cafe at -2x speed
    # Halves the time, goes up an octave, and backmasks
    wave note cafe speed 2 play
#>
param(
# The new speed
[double]
$Speed = 1
)

$newWave = $this
if (-not $newWave) {
    $newWave = wave
}

if ($speed -eq 1) { return $newWave }

$waveFormat = $newWave.WaveFormat
$speedChange = wave @waveFormat -Samples @(
    [Wave.WaveLinq]::Speed([double[]]$newWave.Samples, $Speed)
)
$speedChange.Metadata = $newWave.Metadata
return $speedChange