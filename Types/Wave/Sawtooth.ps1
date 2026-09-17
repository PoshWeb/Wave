<#
.SYNOPSIS
    Sawtooth tone Generator
.DESCRIPTION
    Generates a sawtooth tone of a `-Frequency`, for `-Duration`, at `-Volume`
.NOTES
    A sawtooth wave is calculated given at a given angle using:

    ~~~PowerShell
    [Math]::atan([Math]::Tan($angle/2))
    ~~~
.LINK
    https://en.wikipedia.org/wiki/Sawtooth_wave
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

# The volume.
# If the current wave has set a `volume`, 
# will use that volume.
# Otherwise, will default to 0.5
[float]$Volume = $(
    if ($this.Volume) { $this.Volume } else { 0.5 }
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
$cycle = 2 * [Math]::PI * $Frequency
$stepAngle = $cycle/($sampleRate * $channelCount)

# Return a `[double[]]` containing the samples
return ,[double[]]@(
    # generated one at a time
    for ($i = 0; $i -lt $numberOfSamples; $i++) {                        
        # The sample at this moment is the arc tangent of half that angle
        $sample = [Math]::atan([Math]::Tan($stepAngle * $i/2))        

        # Our envelope is how we want to enclose the sound.
        # This will fade the sound over the `-Duration`
        $envelope = 1.0 - ($i / $numberOfSamples)

        # We scale our sample by the volume and the envelope
        $sample * $volume * $envelope
    }
)