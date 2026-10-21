<#
.SYNOPSIS
    Sawtooth tone Generator
.DESCRIPTION
    Generates a sawtooth tone of a `-Frequency`, for `-Duration`, at `-Volume`
.NOTES
    A sawtooth wave is calculated given at a given angle using:

    ~~~PowerShell
    [Math]::atan([Math]::Tan($angle/2))
    ~~~
.LINK
    https://en.wikipedia.org/wiki/Sawtooth_wave
#>
[OutputType('Wave')]
param(
# The frequency.
# Defaults to A4 (440hz)
[Alias('Hz')]
$Frequency = 440,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume.
# If the current wave has set a `volume`, 
# will use that volume.
# Otherwise, will default to 1/([Math]::PI * 2)
[double]$Volume = $(
    if ($this.Volume) { $this.Volume } else { 1/([Math]::PI * 2) }    
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

# Measure our angles
$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Calculate the number of samples
$numberOfSamples = [Math]::Round(    
    $Duration.TotalSeconds * $SampleRate * $channelCount
)

# Our audio pipeline will consist of two steps:

# 1. A polysaw 
# 2. An envelope

# Saws peak sharply, so adjust volume accordingly
$Volume /= 2

# Now let's make our samples
[double[]]$Samples = @(
    # in the object pipeline

    # Starting at zero, go up to the number of samples we want
    # This will be `$t`
    $t = 0    
    foreach ($t in 0..($numberOfSamples - 1)) {
        #region Polysaw
        # Start it at zero
        [double]$Sample = 0.0
        # Each successive angle will have a weighted volume
        # starting at full volume
        $angleWeight = 1.0
        # Take each of our angles and Add it Up
        foreach ($angle in $angles) {
            # The sample at this moment is the arc tangent of half the time.
            $sample += [Math]::atan([Math]::Tan($t/2 * $angle)) * $angleWeight
            # Then half the weight so the next frequency does not overpower this one.
            $angleWeight/=2
        }
        #endregion Polysaw

        #region Envelope
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