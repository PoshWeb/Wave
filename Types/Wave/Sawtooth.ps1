<#
.SYNOPSIS
    Sawtooth tone Generator
.DESCRIPTION
    Generates a sawtooth tone of a `-Frequency`, for `-Time`, at `-Volume`
.NOTES
    A sawtooth wave is calculated given at a given angle using:

    ~~~PowerShell
    [Math]::atan([Math]::Tan($angle/2))
    ~~~
.LINK
    https://en.wikipedia.org/wiki/Sawtooth_wave
#>
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

    # Calculate the envelope
    $envelope = 1.0 - ($i / $numberOfSamples)
    
    # Calculate the angle at this point in time (in radians)
    $angle = ($cycle * $i) / $divisor    

    # The sample at this moment is the arc tangent of half that angle
    $sample = $math::atan($math::Tan($angle/2))    

    # We will scale this by the volume, and then by the envelope.
    $sample = $sample * $Volume * $envelope

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

return
