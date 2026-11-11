<#
.SYNOPSIS
    Square tone Generator
.DESCRIPTION
    Generates a square tone of a `-Frequency`, for `-Time`, at `-Volume`
.NOTES
    A square wave is calculated by taking the sine of a given angle 
    and turning it into squares:

    ~~~PowerShell
    $sample = [Math]::Sin($t * $angle)
    $sample = 
        if ($sample -gt 0) { 1 }
        elseif ($sample -lt 0) { -1 }
        else { 0 }
    ~~~
.LINK
    https://en.wikipedia.org/wiki/Square_wave_(waveform)
#>
[OutputType('Wave')]
param(
# The frequency.
# Defaults to A4 (440hz)
[Alias('Hz')]
$Frequency = 440.0,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume
[double]$Volume = $(
    if ($this.Volume) { $this.Volume } else { 1/([Math]::PI * 2) }
),

# The start time.
$Time,

# The weights for each frequency.
# If multiple frequencies are played, 
# each wave will be scaled by the weight.
# If fewered weights are provided than frequencies, 
# all remaining frequencies will be half of the previous weight.
[double[]]$Weights = @(1.0),

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

# Square waves peak sharply, so half the volume.
$volume/=2

# This is the new wave.
$newWave = $this
if (-not $newWave) { $newWave = wave }

# If we don't have the time, add to the end.
if (-not $time) { $time = $newWave.Duration }

# We want to use WaveLinq for performance.
# This output a continous stream of samples,
# but only when we invoke the wave method.

$WaveForm = [Wave.WaveLinq]::SquareWave

# This means:
# 1. We can have a _very_ fast audio object pipeline
# 2. We can generate and add our sample in one expression chain
# 3. We write it inline "outside in"

# We're adding to the new wave;
return $newWave.Add(
    [double[]]@(
        # a fading enveloping
        [Wave.WaveLinq]::FadeOut(
            # containing our wave
            $WaveForm.Invoke(
                $Duration.TotalSeconds, # for our duration,
                ($Frequency -as [double[]]), # at our frequencies,
                $Weights, # with our weights,                
                [uint32](
                    $SampleRate * $channelCount # at our samples per second.                    
                )
            ),
        $volume # We scale the whole thing to our volume
        )
    ), $time # and add it at the specified time.
)