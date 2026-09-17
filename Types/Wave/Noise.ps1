<#
.SYNOPSIS
    Noise Generator
.DESCRIPTION
    Generates a Noise at a `-Frequency`, for `-Duration`, at `-Volume`

    Mixes this tone with a `-Signal` and `-Noise` volume.
#>
[OutputType([double[]])]
param(
# The frequency
[Alias('Hz')]
[float]$Frequency = 440,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume
[float]$Volume = 0.5,

# The volume of the signal (by default 0.6)
[ValidateRange(0,1)]
[double]
$Signal = 0.60,

# The volume of the noise (by default 0.4)
[ValidateRange(0,1)]
[double]
$Noise = 0.40,

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
),

# The audio format.
# Will default to the `.AudioFormat` of `$this` wave.
# If there is no `$this` wave, will default to 3 (IEEE floating point).
[uint16]$AudioFormat = $(
    if ($this.AudioFormat) { $this.AudioFormat } else { 3 }
)
)

$BytesPerSecond = $SampleRate * $channelCount * $BitsPerSample/8

# Cache our references, for the minor speed boost it may give us.
$math = [Math]

# Calculate the number of samples
$numberOfSamples = $math::Round($Duration.TotalSeconds * $BytesPerSecond) 

# Our step size is the bits per sample / 8
$step = $BitsPerSample/8

# We can imagine each cycle as a series of circles
# how many circles?  Whatever our frequency may be.
$cycle = 2 * $math::PI * $Frequency

# The divisor will remain the same, so compute it now.
$divisor = ($sampleRate * $channelCount * $step)

$random = [Random]::new()

# Generate one sample at a time.
return ,[double[]]@(for ($i = 0; $i -lt $numberOfSamples; $i+=$step) {

    # Calculate the envelope
    $envelope = 1.0 - ($i / $numberOfSamples)
    
    # Calculate the angle at this point in time (in radians)
    $angle = ($cycle * $i) / $divisor    

    # The sample at this moment is the sine of that angle
    $sample = $math::Sin($angle)
            
    $randomNoise = ($random.NextDouble() * 2) - 1

    (
        ($sample * $Signal) + ($randomNoise * $noise)
    ) * $Volume * $envelope
})
