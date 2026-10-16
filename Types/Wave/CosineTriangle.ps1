<#
.SYNOPSIS
    Cosine Triangle tone Generator
.DESCRIPTION
    Generates a cosine triangular tone of a `-Frequency`, for `-Duration`, at `-Volume`
.NOTES
    A cosine triangular wave is calculated given at a given angle using:

    ~~~PowerShell
    [Math]::acos([Math]::cos($angle))    
    ~~~

    This will be the opposite of a Triangle tone.

    It will usually sound very similar to a Triangle tone, 
    but may seem like it is coming from below, not above.
.LINK
    https://en.wikipedia.org/wiki/Triangle_wave
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
)
)

$currentWave = $this
if (-not $currentWave) {
    $currentWave = wave
}

# Calculate the number of samples
$numberOfSamples = [Math]::Round(    
    $Duration.TotalSeconds * $SampleRate * $channelCount
)

# Measure our angles
$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Our object pipeline will consist of two steps:

# 1. A polycosine triangle
# 2. An envelope

# Now let's make our samples
[double[]]$Samples = @(
    # in the object pipeline

    # Starting at zero, go up to the number of samples we want
    # This will be `$t`
    $t = 0    
    
    # We will pipe in a series of times
    foreach ($t in 0..($numberOfSamples - 1)) {
        
        #region Polycosinetriangle
        # Start it at zero
        [double]$Sample = 0.0
        # Each successive angle will have a weighted volume
        # starting at full volume
        $angleWeight = 1.0
        # Take each of our angles and Add it Up
        foreach ($angle in $angles) {
            
            # Get the cosine of the times and multiply by the weight.
            # Make sure to get the arccosine right this second 
            # so we don't end up in "not a number" NaN land.
            $Sample += [Math]::acos([Math]::Cos($angle * $t)) * $angleWeight
            # Then half the weight so the next frequency does not overpower this one.
            $angleWeight/=2
        }
        
        #endregion Polycosinetriangle

        #region Envelope
        # Our envelope is 1 - $t as a fraction of the number of samples
        $envelope = 1.0 - ($t / $numberOfSamples)
        $sample * $Volume * $envelope
        #endregion Envelope
    }
)

# If we have not been provided a time
if (-not $time) {
    # add it to the end.
    $time = $this.Duration
}

if ($Time) {
    return $this.Add($samples, $time)
}
else {
    $waveFormat = $this.WaveFormat
    if (-not $waveFormat) {
        $waveFormat = @{}
    }
    return wave @waveFormat -Samples $Samples
}
