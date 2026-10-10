<#
.SYNOPSIS
    Cosine Tone Generator
.DESCRIPTION
    Generates a Cosine Tone of a `-Frequency`, for `-Duration`, at `-Volume`
.NOTES
    A cosine tone generator generates a wave with Cosine instead of Sine.

    This will be the opposite of a Sine tone.

    It will usually sound very similar to a sine tone, 
    but may seem like it is coming from below, not above.
#>
[OutputType('Wave')]
param(
# The frequency
[Alias('Hz')]
[double]
$Frequency = 440,

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

# The start time
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
# Generate our samples
[double[]]$Samples = @(for ($i = 0; $i -lt $numberOfSamples; $i++) {

    # Calculate the envelope
    $envelope = 1.0 - ($i / $numberOfSamples)
    
    # The sample is the sine of that angle at this moment in time.
    $sample = [Math]::Cos($stepAngle * $i)

    # We will scale this by the volume, and then by the envelope.
    $sample * $Volume * $envelope
})

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