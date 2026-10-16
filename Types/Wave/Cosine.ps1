<#
.SYNOPSIS
    Cosine Tone Generator
.DESCRIPTION
    Generates a Cosine Tone of a `-Frequency`, for `-Duration`, at `-Volume`
.NOTES
    A cosine tone generator generates a wave with Cosine instead of Sine.

    This will be the opposite of a Sine tone.

    It will usually sound very similar to a sine tone, 
    but may seem like it is coming from below, not above.
#>
[OutputType('Wave')]
param(
# The frequency
[Alias('Hz')]
$Frequency = 440,

# The duration to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume.
# If the current wave has set a `volume`, 
# will use that volume.
# Otherwise, will default to 0.5
[double]$Volume = $(
    if ($this.Volume) { $this.Volume } else { 1/([Math]::PI * 2) }
),

# The start time
$Time,

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
$numberOfSamples = [Math]::Round(
    $Duration.TotalSeconds * $SampleRate * $channelCount
)

# Measure our angles
$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Our object pipeline will consist of two steps:

# 1. A polycosine
# 2. An envelope

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
            $Sample += [Math]::Cos($angle * $t) * $angleWeight
            # Then half the weight               
            $angleWeight/=2
        }
        #endregion Polysine
        
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
    $time = $CurrentWave.Duration
}

if ($Time) {
    return $CurrentWave.Add($samples, $time)
}
else {
    $waveFormat = $CurrentWave.WaveFormat
    if (-not $waveFormat) {
        $waveFormat = @{}
    }
    return wave @waveFormat -Samples $Samples
}