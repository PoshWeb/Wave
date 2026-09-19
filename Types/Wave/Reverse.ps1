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

[double[]]$samples = $this.Samples
[Array]::Reverse($samples)
$waveFormat = $this.WaveFormat
return wave @waveFormat -Samples $samples
