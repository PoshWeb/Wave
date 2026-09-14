<#
.SYNOPSIS
    Noise Generator
.DESCRIPTION
    Generates a Noise at a `-Frequency`, for `-Time`, at `-Volume`

    Mixes this tone with a `-Signal` and `-Noise` volume.
#>
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
$Noise = 0.40
)

# Cache our property values, so we are not wasting cycles.
$sampleRate = $this.SampleRate
$channelCount = $this.ChannelCount
$BytesPerSecond = $this.BytesPerSecond
$BitsPerSample = $this.BitsPerSample

# Cache our references, for the minor speed boost it may give us.
$math = [Math]
$BitConverter = [BitConverter]

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
for ($i = 0; $i -lt $numberOfSamples; $i+=$step) {

    # Calculate the envelope
    $envelope = 1.0 - ($i / $numberOfSamples)
    
    # Calculate the angle at this point in time (in radians)
    $angle = ($cycle * $i) / $divisor    

    # The sample at this moment is the sine of that angle
    $sample = $math::Sin($angle)
            
    $randomNoise = ($random.NextDouble() * 2) - 1

    $sample = (
        ($sample * $Signal) + ($randomNoise * $noise)
    ) * $Volume * $envelope

    # Clamp our sample
    if ($sample -gt 1) { $sample = 1}
    if ($sample -lt -1) { $sample = -1}

    # If there are 8 bits per sample
    if ($BitsPerSample -eq 8) {
        # round each sample into bytes, with 128 as the zero point.
        [byte]$math::Round(            
            128 + $sample * 127
        )    
    }

    # If there are 16 bits per sample
    elseif ($BitsPerSample -eq 16) {
        # we just need to scale an `[int16]`
        $BitConverter::GetBytes([int16]($sample * [int16]::MaxValue))
    }

    # If there are 32 bits per sample
    elseif ($BitsPerSample -eq 32) {
        # we can just scale to an `[int32]`
        $BitConverter::GetBytes([int32]($sample * [int32]::MaxValue))
    }
}
