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


# Measure our angles
$angles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

# Our object pipeline will consist of three steps:

# 1. A polysine
# 2. A square 
# 3. An envelope

# For our polysine, we want to process each input time.
$PolySine = {
    process {
        # Given an input time, we want to make a sample
        $t = $_

        # Start it at zero
        [double]$Sample = 0.0
        # Each successive angle will have a weighted volume
        # starting at full volume
        $angleWeight = 1.0
        # Take each of our angles and Add it Up
        foreach ($angle in $angles) {
            # Get the sine of the times and multiply by the weight.
            $Sine = [Math]::Sin($angle * $t)
            $Sample += $sine * $angleWeight
            # Then half the weight               
            $angleWeight/=2
        }
        # Output the sum of all samples
        $sample                
    }            
}

$Square = {
    process {
        if ($Sample -gt 0) { 1 }
        elseif ($sample -lt 0) { -1 }
        else { $sample }
    }
}

# For our envelope, we want to scale by volume and hush over time
$Envelope = {
    process {
        # Our sample is our input
        [double]$Sample = $_
        # Our envelope is 1 - $t as a fraction of the number of samples
        $envelope = 1.0 - ($t / $numberOfSamples)
        $sample * $Volume * $envelope    
    }
}

# Now let's make our samples
[double[]]$Samples = @(
    # in the object pipeline

    # Starting at zero, go up to the number of samples we want
    # This will be `$t`
    $t = 0    
    
    # We will pipe in a series of times
    0..($numberOfSamples - 1) |
        . $PolySine | # and get our polysine
        . $Square | # square it
        . $Envelope # and then put it in an envelope.
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