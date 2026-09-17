<#
.SYNOPSIS
    Chirp Wave
.DESCRIPTION
    Chirp Wave generator.
    
    Generates a Wave that "chirps" between two frequencies.  
    
    This gets softer as it approaches the half, then louder as it approaches the end.
#>
[OutputType([double[]])]
param(
# The frequency
[Alias('Hz')]
[float]$Frequency = 0,

[Alias('Hz2')]
[float]$ToFrequency = 0,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume
[float]$Volume = 0.5,

# The sample rate.
# Will default to the `.SampleRate` of `$this` wave.
# If there is no `$this` wave, will default to 44100
[uint32]$SampleRate = $(
    if ($this.SampleRate) { $this.SampleRate } else { 44100 }
),


# The bits per sample.
# Will default to the `.BitsPerSample` of `$this` wave.
# If there is no `$this` wave, will default to 4.
[uint16]$BitsPerSample = $(
    if ($this.BitsPerSample) { $this.BitsPerSample } else { 4 }
),

# The channel count.
# Will default to the `.ChannelCount` of `$this` wave.
# If there is no `$this` wave, will default to 1 (mono).
[uint16]$channelCount = $(
    if ($this.ChannelCount) { $this.ChannelCount } else { 1 }
)
)


if ($Frequency -eq 0) {
    $Frequency = 440
}

if ($ToFrequency -eq 0) {
    $ToFrequency = $Frequency / 2
}

$BytesPerSecond = $SampleRate * $channelCount * $BitsPerSample/8

# Cache our references, for the minor speed boost it may give us.
$math = [Math]

# Calculate the number of samples
$numberOfSamples = $math::Round($Duration.TotalSeconds * $BytesPerSecond) 

# Our step size is the bits per sample / 8
$step = $BitsPerSample/8


# The divisor will remain the same, so compute it now.
$divisor = ($sampleRate * $channelCount * $step)

$half = $numberOfSamples / 2

# Generate one sample at a time.
return ,[double[]]@(
    for ($i = 0; $i -lt $numberOfSamples; $i+=$step) {
        
        $t = $i/$numberOfSamples
        # Calculate the envelope
        $envelope = 1.0 - $t

        $currentFrequency = if ($i -lt $half) {
            $Frequency
        } else {
            $ToFrequency
        }
            
        $envelope = if ($i -lt $half) {
            1.0 - ($i / $half)
        } else {
            1.0 - ($i - $half) / ($numberOfSamples - $half)
        }

        # We can imagine each cycle as a series of circles
        # how many circles?  Whatever our frequency may be.
        $cycle = 2 * $math::PI * $currentFrequency
        
        # Calculate the angle at this point in time (in radians)
        $angle = ($cycle * $i) / $divisor    

        # The sample at this moment is the sine of that angle
        $sample = $math::Sinh($math::Sin($angle))

        # We will scale this by the volume, and then by the envelope.
        $sample * $Volume * $envelope
    }
)
