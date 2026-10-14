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

[int]$StepCount = 0,

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

# Our object pipeline will consist of two steps:
# 1. A polysine
# 2. An envelope

# For our polysine, we want to process each input time.
$PolySine = {
    process {
        # Given an input time, we want to make a sample
        $t = $_

        # Start it at zero
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
        # Output the sum of all samples
        $sample                
    }            
}

# For our envelope, we want to scale by volume and hush over time
$Envelope = {
    process {
        # Our sample is our input
        [double]$Sample = $_
        # Our envelope is 1 - $t as a fraction of the number of samples
        $envelope = 1.0 - ($t / $numberOfSamples)
        $sample * $Volume * $envelope    
    }
}


# Now let's make our samples
[double[]]$Samples = @(
    # in the object pipeline

    # Starting at zero, go up to the number of samples we want
    # This will be `$t`
    $t = 0    
    
    # We will pipe in a series of times
    0..($numberOfSamples - 1) |
        . $PolySine | # and get our polysine
        . $Envelope # and then put it in an envelope.
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
