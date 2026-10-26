<#
.SYNOPSIS
    Full Sine Generator
.DESCRIPTION
    Generates a Polyphinic Full Sine Wave of a `-Frequency`, for `-Duration`, at `-Volume`

    This sound does not have a normal envelope, 
    and will sound quite strong because it does not slope over time.
.EXAMPLE
    # Generates a full sine wave of A4.
    # This will be louder than A4 in an envelope.
    wave fullsine 440 
.EXAMPLE
    # Generates a full sine wave of A4
    # and puts it in an envelope.
    wave fullsine 440 envelope
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
# Otherwise, will default to 1/([Math]::pi * 2)
[double]$Volume = $(
    if ($this.Volume) { $this.Volume } else { 1/([Math]::pi * 2) }
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

[double[]]$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

$waveFormat = $wave.WaveFormat

[double[]]$Samples =@(
    # Scale our full sine wave by the volume
    # (because we want to be kind to our eardrums and speakers)
    [Wave.WaveLinq]::Multiply(
        [Wave.WaveLinq]::SineWave(
            [double[]](0..($numberOfSamples - 1)),
            $angles,
            $Weights
        ),        
        [double[]]@($volume)
    )            
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