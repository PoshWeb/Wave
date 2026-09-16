<#
.SYNOPSIS
    Tone Generator
.DESCRIPTION
    Generates a Tone of a `-Frequency`, for `-Time`, at `-Volume`
#>
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
# If the AudioFormat is not floating point, 
# values will be clamped between -1 and 1
[float]$Volume = 0.5,

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
),

# The audio format.
# Will default to the `.AudioFormat` of `$this` wave.
# If there is no `$this` wave, will default to 3 (IEEE floating point).
[uint16]$AudioFormat = $(
    if ($this.AudioFormat) { $this.AudioFormat } 
    else { 3 }
)
)

# Cache our property values, so we are not wasting cycles.
$BytesPerSecond = $SampleRate * $channelCount * $BitsPerSample/8

# Cache our references, for the minor speed boost it may give us.
$math = [Math]
$GetBytes = [BitConverter]::GetBytes

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

    # The sample at this moment is the sine of that angle
    $sample = $math::Sin($angle)

    # We will scale this by the volume, and then by the envelope.
    $sample = $sample * $Volume * $envelope

    #region Encode Sample

    # We _could_ encapsulate the encoding off into it's own procedure.

    # However, callstacks have overhead.

    # Inline code will be quicker.
    # (hence duplicating it across multiple files)

    # If we are using 32-bit floating point audio
    if ($BitsPerSample -eq 32 -and $audioFormat -eq 3) {
        # we are basically done.
        # No clamping required. # Just cast to float, 
        $GetBytes.Invoke([float]$sample) # get the bytes,
        continue # and continue 
    }
    
    # If we are dealing with whole number audio formats,
    # We've got to clamp it down to an amplitude between -1 and 1.

    # Unfortunately, `Clamp` is not part of older .NET framework versions
    # So we will clamp the old fashioned way, with an `if`
    if ($sample -gt 1) { $sample = 1 }
    elseif ($sample -lt -1) { $sample = -1 }

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
        $GetBytes.Invoke([int16]($sample * 32767))
    }

    # If there are 32 bits per sample
    elseif ($BitsPerSample -eq 32) {
        # we can just scale to an `[int32]`.
        # Hardcode `[int32]::MaxValue` for speed
        $GetBytes.Invoke([int32]($sample * 2147483647))
    }
    #endregion Encode Sample
}
