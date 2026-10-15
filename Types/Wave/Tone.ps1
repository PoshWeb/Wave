<#
.SYNOPSIS
    Tone Generator
.DESCRIPTION
    Generates a Tone of a `-Frequency`, for `-Duration`, at `-Volume`
#>
[OutputType('Wave')]
param(
# The frequency
[Alias('Hz')]
$Frequency = 440.0,

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
    if ($this.Volume) { $this.Volume } else { 0.5 }
),

# The start time.
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

$currentWave = $this
if (-not $currentWave) { $currentWave = wave }

# If we have not been provided a time
if (-not $time) {
    # add it to the end.
    $time = $this.Duration
}

# Calculate the number of samples
$numberOfSamples = [Math]::Round(
    $Duration.TotalSeconds * $SampleRate * $channelCount
)

# Measure our angles
$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Our wave will consist of two steps:

# 1. A polysine
# 2. An envelope

# Now let's make our samples
[double[]]$Samples = @(
    # Start $t at zero
    foreach ($t in 0..($numberOfSamples - 1)) {
        
        #region Polysine
        [double]$Sample = 0.0
        # Each successive angle will have a weighted volume
        # starting at full volume
        $angleWeight = 1.0
        # Take each of our angles and Add it Up
        foreach ($angle in $angles) {
            # Get the sine of the times and multiply by the weight.
            $Sample += [Math]::Sin($angle * $t) * $angleWeight
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

# If we have a time
if ($Time) {
    # add the samples at that time
    $currentWave = $currentWave.Add($samples, $time)
}
else {
    # Otherwise create a new wave
    $waveFormat = $currentWave.WaveFormat
    if (-not $waveFormat) {
        $waveFormat = @{}
    }
    $currentWave = wave @waveFormat -Samples $Samples
}
return $currentWave
