<#
.SYNOPSIS
    Wave Gain
.DESCRIPTION
    Gains volume in a wave.

    A gain multiplies each sample in the wave by a ratio, 
    increasing overall loudness.

    Applying a Gain of 1 would leave the audio unchanged.

    Applying a Gain of 0.5 would half the loudness of the audio.

    Applying a Gain of 1.05 would be 5% louder.

    Applying a Gain of 2 would double the loudness of the audio.

    Please do not provide high values to this function.
    
    The speakers and eardrums you save may be your own.
#>
param(
# By default, applys a 5% gain
[double]
$Gain = 1.05
)

# Collect our samples
[double[]]$Samples = $this.Samples

# Apply the gain
[double[]]$Gained = for ($index = 0 ; $index -lt $samples.Length; $index++) {
    $samples[$index] * $gain
}

$waveFormat = $this.WaveFormat
wave @waveFormat -Samples $Gained

