<#
.SYNOPSIS
    Noise Generator
.DESCRIPTION
    Generates a Noise at a `-Frequency`, for `-Duration`, at `-Volume`

    Mixes this tone with a `-Signal` and `-Noise` volume.
#>
[OutputType('Wave')]
param(
# The frequency
[Alias('Hz')]
$Frequency = 440,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume
[double]$Volume = $(
    if ($this.Volume) {
        $this.Volume
    } else {
        1/([Math]::PI*2)
    }
),

# The start time
$Time,

# The signal to noise ratio (by default 0.6)
[ValidateRange(0,1)]
[double]
$SignalToNoise = @(0.6),

# The sample rate.
# Will default to the `.SampleRate` of `$this` wave.
# If there is no `$this` wave, will default to 44100
[uint32]$SampleRate = $(
    if ($this.SampleRate) { $this.SampleRate } else { 44100 }
),


# The channel count.
# Will default to the `.ChannelCount` of `$this` wave.
# If there is no `$this` wave, will default to 1 (mono).
[uint16]$channelCount = $(
    if ($this.ChannelCount) { $this.ChannelCount } else { 1 }
)
)

$CurrentWave = $this
if (-not $CurrentWave) { $CurrentWave = wave }

# Calculate the number of samples
$numberOfSamples = [Math]::Round($Duration.TotalSeconds * $SampleRate * $channelCount) 

# Measure our angles
$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Our object pipeline will consist of three steps:

# 1. Make a polysine
# 2. Inject noise
# 3. Stuff it in an envelope

$Random = [Random]::new()

# Now let's make our samples
[double[]]$Samples = @(
    # Start $t at zero
    foreach ($t in 0..($numberOfSamples - 1)) {
        
        #region Polycosine
        [double]$Sample = 0.0
        # Each successive angle will have a weighted volume
        # starting at full volume
        $angleWeight = 1.0
        # Take each of our angles and Add it Up
        foreach ($angle in $angles) {
            # Get the cosine of the times and multiply by the weight.
            $Sample += [Math]::Sin($angle * $t) * $angleWeight
            # Then half the weight               
            $angleWeight/=2
        }
        #endregion Polysine
    
        #region Noise
        $randomNoise = ($random.NextDouble() * 2) - 1
        $sample = 
            ($sample * $SignalToNoise) + 
            ($randomNoise * (1 - $SignalToNoise))        
        #endregion Noise

        #region Envelope        
        # Output the sum of all samples
        $envelope = 1.0 - ($t / $numberOfSamples)
        $sample * $Volume * $envelope    
        #endregion Envelope
    }    
)

# If we have not been provided a time
if (-not $time) {
    # add it to the end.
    $time = $currentWave.Duration
}

if ($Time) {
    return $currentWave.Add($samples, $time)
}
else {
    $waveFormat = $currentWave.WaveFormat
    if (-not $waveFormat) {
        $waveFormat = @{}
    }
    return wave @waveFormat -Samples $Samples
}