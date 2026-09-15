<#
.SYNOPSIS
    Square Tone Generator
.DESCRIPTION
    Generates a square tone of a `-Frequency`, for `-Time`, at `-Volume`.
.NOTES
    This is the same a pure tone, 
    using `[Math]::Sinh` to round values to 1 or -1
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
[float]$Volume = 0.5
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




# Generate one sample at a time.
for ($i = 0; $i -lt $numberOfSamples; $i+=$step) {
    # Normally, we would calculate the envelope.
    # But a square wave does not have an envelope.
    # (or rather, is has an envelope of 1 )
    # $envelope = 1.0    
    
    # Calculate the angle at this point in time (in radians)
    $angle = ($cycle * $i) / $divisor    

    # The sample at this moment is the sine of that angle
    $sample = $math::Sin($angle)

    # We will scale this by the volume
    $sample = $sample * $Volume

    # Clamp our sample
    $sample = $math::Clamp($sample, -1.0, 1.0)

    #region Encode Sample

    # We _could_ encapsulate the encoding off into it's own procedure.

    # However, callstacks have overhead.

    # Inline code will be quicker.
    # (hence duplicating it across multiple files)

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
        # Hardcode `[int16]::MaxValue` for speed
        $BitConverter::GetBytes([int16]($sample * 32767))
    }

    # If there are 32 bits per sample
    elseif ($BitsPerSample -eq 32) {
        # we can just scale to an `[int32]`.
        # Hardcode `[int32]::MaxValue` for speed
        $BitConverter::GetBytes([int32]($sample * 2147483647))
    }
    #endregion Encode Sample
}
