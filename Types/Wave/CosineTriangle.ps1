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
[double[]]$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Now let's make our samples
[double[]]$Samples = @(
# Scale our wave.
    [Wave.WaveLinq]::Multiply(
        # Multiply our wave by our our envelope
        [Wave.WaveLinq]::Multiply(
            [Wave.WaveLinq]::CosineTriangle(
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
