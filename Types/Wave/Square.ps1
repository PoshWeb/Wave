<#
.SYNOPSIS
    Square tone Generator
.DESCRIPTION
    Generates a square tone of a `-Frequency`, for `-Time`, at `-Volume`
.NOTES
    A square wave is calculated by taking the sin of a given angle and using:

    ~~~PowerShell
    [Math]::atan([Math]::Tan($angle/2))
    ~~~
.LINK
    https://en.wikipedia.org/wiki/Square_wave_(waveform)
#>
[OutputType([double[]])]
param(
# The frequency.
# Defaults to A4 (440hz)
[Alias('Hz')]
[float]$Frequency = 440,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume
[float]$Volume = $(
    if ($this.Volume) { $this.Volume }
    else { 0.5 }
),

# The sample rate.
# Will default to the `.SampleRate` of `$this` wave.
# If there is no `$this` wave, will default to 44100
[uint32]$SampleRate = $(
    if ($this.SampleRate) { $this.SampleRate } 
    else { 44100 }
),


# The bits per sample.
# Will default to the `.BitsPerSample` of `$this` wave.
# If there is no `$this` wave, will default to 4.
[uint16]$BitsPerSample = $(
    if ($this.BitsPerSample) { $this.BitsPerSample } 
    else { 4 }
),

# The channel count.
# Will default to the `.ChannelCount` of `$this` wave.
# If there is no `$this` wave, will default to 1 (mono).
[uint16]$channelCount = $(
    if ($this.ChannelCount) { $this.ChannelCount } 
    else { 1 }
)
)

# Cache our property values, so we are not wasting cycles.
$BytesPerSecond = $SampleRate * $channelCount * $BitsPerSample/8

# Cache our references, for the minor speed boost it may give us.
$math = [Math]

# Calculate the number of samples
$numberOfSamples = $math::Round($Duration.TotalSeconds * $BytesPerSecond) 

# Our step size is the bits per sample / 8
$step = $BitsPerSample/8

# The divisor will remain the same, so compute it now.
$divisor = ($sampleRate * $channelCount * $step)

# We will return the wave as a `[double[]]`,
# and preceeed it by a comma so that we return all samples at once.

,[double[]]@(
    # Generate one sample at a time.
    for ($i = 0; $i -lt $numberOfSamples; $i+=$step) {
    
    # Calculate the envelope
    $envelope = 1.0 - ($i / $numberOfSamples)

    # We can imagine each cycle as a series of circles
    # how many circles?  Whatever our frequency may be.
    $cycle = (2 * $math::PI * $Frequency)
    
    # Calculate the angle at this point in time (in radians)
    $angle = ($cycle * $i) / $divisor    
    
    # Calculate the angle at the moment
    $sample = $math::sin($angle)
    
    # For a square wave, 
    # we simply check the sign of the sample.
    if ($sample -gt 0) {
        $sample = 1 # and use either 1
    } elseif ($sample -lt 0) {
        $sample = -1 # or negative 1.
    }

    # We will scale this by the volume, and then by the envelope.
    $sample * $volume * $envelope
})

return
