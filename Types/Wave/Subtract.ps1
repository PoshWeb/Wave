<#
.SYNOPSIS
    Subtracts Samples
.DESCRIPTION
    Subtracts Samples to a wave.

    If the wave has no samples, this will simply set the samples to their inverse.

    If a wave has samples, this will subtract the samples to the wave, 
    mixing the audio together.
#>
param(
# The other wave
$OtherWave, 
# The start time for the subtraction
$Time = 0
)

# Collect our samples from the other wave
[double[]]$Samples = 
    # If the other wave is a `Wave`
    if ($otherWave.pstypenames -contains 'wave') {
        # get it's samples
        $otherWave.Samples
    }
    # If the other wave can be cast to a `[double[]]`
    elseif ($OtherWave -as [double[]]) 
    {
        # treat it as an array of samples
        $OtherWave -as [double[]]
    }

# Get our current samples
[double[]]$current = $this.Samples

# If we have no current samples
if (-not $current) {
    # Then we are just going to add to the samples to the end
    $this.Samples = foreach ($sample in $samples) {
        $sample * -1
    }
    return $this
}

# If a start time was specified
if ($Time) {
    # it could be a `[TimeSpan]`
    if ($time -is [TimeSpan]) {        
        $time = $time.TotalSeconds
    }
    # Or a `[double]`
    else {
        $time = $time -as [double]
    } 
    # Either way, set the start to the time
    $start = $time
} 

# If we have not set a start,
if (-not $start) {
    $Start = 0 # initialize to zero
}

# Get the sample rate and channel count
$SampleRate = $this.SampleRate
$ChannelCount = $this.ChannelCount

# This can be used to compute an offset
$Offset = [Math]::Floor($start * $SampleRate * $ChannelCount)

$this.Samples = [double[]][Wave.WaveLinq]::Subtract(
    $current, 
    [int]$Offset,
    $Samples
)
return $this
