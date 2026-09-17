<#
.SYNOPSIS
    Wave Sweep
.DESCRIPTION
    Generates a Wave that sweeps between two frequencies.    
#>
[OutputType([double[]])]
param(
# The frequency.
# If no frequency is provided, it will be 440hz (A4)
[Alias('Hz')]
[float]$Frequency = 0,

# The destination frequency.  
# If not provided, will be half of the frequency
[Alias('Hz2')]
[float]$ToFrequency = 0,

# The duration to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume.
# If the AudioFormat is not floating point, 
# values will be clamped between -1 and 1
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

# Cache our property values, so we are not wasting cycles.
$BytesPerSecond = $SampleRate * $channelCount * $BitsPerSample/8

if ($Frequency -eq 0) { $Frequency = 440 }
if ($ToFrequency -eq 0) { $ToFrequency = $Frequency / 2 }

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
return ,[double[]]@(
    # Generate one sample at a time.
    for ($i = 0; $i -lt $numberOfSamples; $i+=$step) {
    
        $t = $i/$numberOfSamples
        # Calculate the envelope
        $envelope = 1.0 - $t

        $currentFrequency = $Frequency + ($ToFrequency - $Frequency) * $t

        # We can imagine each cycle as a series of circles
        # how many circles?  Whatever our frequency may be.
        $cycle = 2 * $math::PI * $currentFrequency
        
        # Calculate the angle at this point in time (in radians)
        $angle = ($cycle * $i) / $divisor    

        # The sample at this moment is the sine of that angle
        $sample = $math::Sin($angle)    

        # We will scale this by the volume, and then by the envelope.
        $sample * $Volume * $envelope
    }
)