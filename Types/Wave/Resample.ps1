<#
.SYNOPSIS
    Resamples Waves
.DESCRIPTION
    Resamples a Wave to a new sample rate.
.NOTES
    The difference between resampling and 
    changing speed comes down if we extrapolate.

    Adjusting speed will using linear interpolation to fill in the gaps.
        
    Resampling simply rounds time, which will duplicate or drop samples.
#>
param(
# The new sample rate
[double]
$SampleRate
)

# This is the current wave.
$currentWave = $this
# If there is no current wave
if (-not $currentWave) {
    $currentWave = wave # initialize an empty wave.
}

# If the sample rate is zero,
if ($SampleRate -eq 0) {
    # return the current wave.
    return $currentWave
}

# Collect our current samples
[double[]]$Current = $currentWave.Samples

# We want to use _almost_ the same wave format.
$waveFormat = $currentWave.WaveFormat
# The sample rate needs to change, because we are resampling
$waveFormat.SampleRate = [Math]::Round([Math]::Abs($SampleRate))
# and the bytes per second needs to change, 
# or else things will sound fuzzy and wrong.
$waveFormat.BytesPerSecond = $waveFormat.SampleRate * $currentWave.ChannelCount * $currentWave.BytesPerBlock

# Compute our new sample count
$newSampleCount = [Math]::Round(
    $currentWave.Duration.TotalSeconds * $currentWave.ChannelCount * [Math]::Abs($SampleRate)
)

# Determine where we start.
$startAtSample =     
    # If we are going forwards in time
    if ($SampleRate -gt 0) {
        0 # start at zero
    } else {
        # If we are going backwards in time
        $newSampleCount - 1 # start at the last sample
    }

# Determine our increment
$sampleIncrement =
    # Going forward?  Positive increment.
    if ($sampleRate -gt 1) { 1 } 
    # Going backward?  Negative increment.
    else { -1 } 


# Create new samples
[double[]]$newSamples = @(    
    for (
        # starting at either end
        $sampleNumber = $startAtSample ; 
        # going until we've reached the start or end.
        $sampleNumber -ge 0 -and ($sampleNumber -lt $newSampleCount);
        # and incrementing by 1 or -1
        $sampleNumber += $sampleIncrement
    ) {        
        # The difference between resampling and 
        # speed adjustment comes down if we extrapolate.

        # Adjusting speed will using linear interpolation to fill in the gaps.
        
        # Resampling simply rounds time, which will duplicate or drop samples. 
        $current[
            [Math]::Round(
                $sampleNumber/$newSampleCount * $Current.Length
            )
        ]                
        continue 
    }    
)

# Create a new wave using our samples.
wave @waveFormat -Samples $newSamples