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

# The weights for each frequency.
# If multiple frequencies are played, 
# each wave will be scaled by the weight.
# If fewered weights are provided than frequencies, 
# all remaining frequencies will be half of the previous weight.
[double[]]$Weights = @(1.0),

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
[double[]]$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Our audio pipeline will consist of three steps:

# 1. A CircleSquareWave
# 2. An envelope
# 3. A voume scalar

# Squares peak sharply, so adjust volume accordingly.
$volume/=2

# Now let's make our samples
[double[]]$Samples = @(
    # Scale our wave.
    [Wave.WaveLinq]::Multiply(
        # Multiply our wave by our our envelope
        [Wave.WaveLinq]::Multiply(
            [Wave.WaveLinq]::CircleSquareWave(
                [double[]](0..($numberOfSamples - 1)),
                $angles,
                $Weights
            ),
            # (which is a fade out over the number of samples)
            [Wave.WaveLinq]::FadeOut($numberOfSamples)
        ),
        # Then scale by our volume
        [double[]]@($volume)
    )
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