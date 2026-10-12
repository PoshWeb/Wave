<#
.SYNOPSIS
    Full Unattenuated Sine Generator
.DESCRIPTION
    Generates a Full Unattenuated Sine Wave of a `-Frequency`, for `-Duration`, at `-Volume`
.EXAMPLE
    # Generates a full sine wave of A4.
    # This would be loud
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
[double]$Frequency = 440,

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

# Calculate the number of samples
$numberOfSamples = [Math]::Round(
    $Duration.TotalSeconds * $SampleRate * $channelCount
)
# We can imagine each cycle as a series of circles
# how many circles?  Whatever our frequency may be.
$cycle = 2 * [Math]::PI * $Frequency

$stepAngle = $cycle/($sampleRate * $channelCount)

filter sine {
    param([double]$stepAngle = 0)
    [Math]::Sin($_ * $stepAngle)
}

$waveFormat = $wave.WaveFormat

[double[]]$Samples =@(0..($numberOfSamples - 1) | sine $stepAngle)

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