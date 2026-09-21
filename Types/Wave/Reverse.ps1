<#
.SYNOPSIS
    Reverses waves.
.DESCRIPTION
    Reverses a wave, backmasking the audio.
.NOTES
    This will reverse the samples in the wave, which will play the sound backwards
.LINK
    https://en.wikipedia.org/wiki/Backmasking
.EXAMPLE
    wave note cafe reverse play
#>
[OutputType('audio/wav')]
param()

$waveFormat = $this.WaveFormat
return wave @waveFormat -Samples (
    [Linq.Enumerable]::Reverse([double[]]$this.Samples)
)
