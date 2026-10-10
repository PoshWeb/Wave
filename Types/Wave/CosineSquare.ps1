<#
.SYNOPSIS
    Cosine square tone Generator
.DESCRIPTION
    Generates a cosine square tone of a `-Frequency`, for `-Duration`, at `-Volume`
.NOTES
    A cosine square wave is calculated by taking the cosine of a given angle
    and then using it's direction to shape the wave. 

    ~~~PowerShell
    $sample = [Math]::Cos($Angle)
    if ($sample -gt 0) { $sample = 1 }
    if ($sample -lt 1) { $sample = -1}
    ~~~
.LINK
    https://en.wikipedia.org/wiki/Square_wave_(waveform)
#>
[OutputType('Wave')]
param(
# The frequency.
# Defaults to A4 (440hz)
[Alias('Hz')]
[double]$Frequency = 440,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume
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

# Return a `[double[]]` containing the samples
[double[]]$Samples = @(
    # generated one at a time
    for ($i = 0; $i -lt $numberOfSamples; $i++) {                        
        # The sample is the arc sin of the sine of the angle
        $sample = [Math]::cos($stepAngle * $i)

        # For a square wave, 
        # we simply check the sign of the sample.
        if ($sample -gt 0) {
            $sample = 1 # and use either 1
        } elseif ($sample -lt 0) {
            $sample = -1 # or negative 1.
        }

        # Our envelope is how we want to enclose the sound.
        # This will fade the sound over the `-Duration`
        $envelope = 1.0 - ($i / $numberOfSamples)

        # We scale our sample by half the volume and the envelope
        $sample * $volume/2 * $envelope
    }
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