<#
.SYNOPSIS
    Circle Square tone Generator
.DESCRIPTION
    Generates a circle / square tone of a `-Frequency`, for `-Time`, at `-Volume`
.NOTES
    A square wave is calculated by taking the sine of a given angle 
    and turning it into squares:

    ~~~PowerShell
    $sample = [Math]::Sin($t * $angle)
    $sample = 
        if ($sample -gt 0) { 1 }
        elseif ($sample -lt 0) { -1 }
        else { 0 }
    ~~~

    A Circle Square keeps the bottom half of the square, 
    and leaves the top half as a sine wave.
.LINK
    https://en.wikipedia.org/wiki/Square_wave_(waveform)
#>
[OutputType('Wave')]
param(
# The frequency.
# Defaults to A4 (440hz)
[Alias('Hz')]
$Frequency = 440.0,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume
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

# Calculate the number of samples
$numberOfSamples = [Math]::Round(    
    $Duration.TotalSeconds * $SampleRate * $channelCount
)

# Measure our angles
$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Our audio pipeline will consist of three steps:

# 1. A polysine
# 2. A square 
# 3. An envelope
$volume/=2

# Now let's make our samples
[double[]]$Samples = @(
    # Starting at zero, go up to the number of samples we want         
    foreach ($t in 0..($numberOfSamples - 1)) {

        #region Polysine
        # Start each sample at zero
        [double]$Sample = 0.0
        # Each successive angle will have a weighted volume
        # starting at full volume
        $angleWeight = 1.0
        # Take each of our angles and Add it Up
        foreach ($angle in $angles) {
            # Get the sine of the times and multiply by the weight.
            $Sine = [Math]::Sin($angle * $t)

            $square = 
                if ($Sine -gt 0) { 1 }
                elseif ($Sine -lt 0) { $Sine }
                else { $Sine }
                
            $Sample += $square * $angleWeight
            # Then half the weight               
            $angleWeight/=2
        }
        #endregion Polysine

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