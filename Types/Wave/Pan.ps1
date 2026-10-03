<#
.SYNOPSIS
    Pans a Wave
.DESCRIPTION
    Pans a wave between even and odd samples.    
.NOTES
    A pan is effectively a selective gain.

    If we provide a ratio of 0, 
    we will multiply each even sample by 0, 
    and each odd sample by 1.

    This will give us the left channel in stereo.

    Alternatively, if we provide a ratio of 1,
    we will multiply each odd sample by 0, 
    and each even sample by 1.

    This will give us the right channel in stereo.
#>
param(
# The pan ratio.
# Providing values greater than zero or less 
# than one will alternate the phase of the opposite channel.
[double]
$Ratio
)

# Collect our samples
[double[]]$Samples = $this.Samples

# Generate our pan
[double[]]$Panned = for ($index = 0 ; $index -lt $samples.Length; $index++) {
    $odd = $index % 2
    if ($odd) {
        $samples[$index] * $ratio
    } else {
        $samples[$index] * (1 - $ratio)
    }    
}

$waveFormat = $this.WaveFormat
wave @waveFormat -Samples $Panned
