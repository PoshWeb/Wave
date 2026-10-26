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
[double[]]$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Our wave will consist of three steps:

# 1. A polysine
# 2. An envelope
# 3. A Volume scale

# Now let's make our samples
[double[]]$Samples = @(    
    # Scale our wave.
    [Wave.WaveLinq]::Multiply(
        # Multiply our wave by our our envelope
        [Wave.WaveLinq]::Multiply(
            [Wave.WaveLinq]::SineWave(
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
