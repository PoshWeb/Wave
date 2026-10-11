<#
.SYNOPSIS
    Adds Samples
.DESCRIPTION
    Adds Samples to a wave.

    If the wave has no samples, this will simply set the samples.

    If a wave has samples, this will add the samples to the wave, 
    mixing the audio together.
#>
param(
# The other wave
$OtherWave, 
# The start time for the addition
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
    $this.Samples = $samples
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

# Collect our new samples
[double[]]$NewSamples = @(    
    # If the current sample is larger than the offset
    if ($current.Length -ge $Offset) {
        $current[0..$Offset] # get the samples until the offset
    } else {
        # Otherwise, include the current samples        
        if ($current.Length) {
            $current
        }
        # and pad the remainder of the time until start with silence
        $deltaSamples = [Math]::Floor($Offset - $current.Length)
        @(0) * $deltaSamples    
    }
    
    # Add the samples
    for ($index = 0; $index -lt $samples.Count; $index++) {
        # If we are still within the current timeframe
        if ($current.Length -gt ($index + $Offset)) {
            # Add samples in at that point
            $current[$index + $Offset] + ($samples[$index])
        } else {
            # Otherwise, simply include the new sample
            $samples[$index]
        }
    }
    # If we have remaining original samples
    if (($index + $offset) -lt $current.Length) {
        # they should still be part of the audio and be included        
        for ($remaining = $index + $Offset; $remaining -lt $current.Length; $remaining++) {
            $current[$remaining]
        }
    }
)

$this.Samples = $NewSamples
return $this