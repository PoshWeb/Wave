<#
.SYNOPSIS
    Tone Generator
.DESCRIPTION
    Generates a Tone of a `-Frequency`, for `-Time`, at `-Volume`
#>
[OutputType([double[]])]
param(
# The frequency
[Alias('Hz')]
[float]$Frequency = 440,

# The duration to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume.
# If the current wave has set a `volume`, 
# will use that volume.
# Otherwise, will default to 0.5
[float]$Volume = $(
    if ($this.Volume) { $this.Volume}
    else { 0.5 }
),

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
$cycle = 2 * $math::PI * $Frequency
$stepAngle = $cycle/($sampleRate * $channelCount)

# Return a `[double[]]` containing the samples
return ,[double[]]@(for ($i = 0; $i -lt $numberOfSamples; $i++) {

    # Calculate the envelope
    $envelope = 1.0 - ($i / $numberOfSamples)
    
    # The sample is the sine of that angle at this moment in time.
    $sample = [Math]::Sin($stepAngle * $i)

    # We will scale this by the volume, and then by the envelope.
    $sample * $Volume * $envelope
})