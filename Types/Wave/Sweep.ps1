<#
.SYNOPSIS
    Wave Sweep
.DESCRIPTION
    Generates a Wave that sweeps between two frequencies.    
#>
[OutputType('Wave')]
param(
# The frequency.
# If no frequency is provided, it will be 440hz (A4)
[Alias('Hz')]
$Frequency = 0,

# The distance to sweep, in semitones  
[double]
$Distance = 6,

# The number of steps in the sweep
# If none are provided, the frequencies will change continuously.
[int]
$StepCount = 0,

# The duration to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume.
# If the current wave has set a `volume`, 
# will use that volume.
# Otherwise, will default to 0.5
[double]$Volume = $(
    if ($this.Volume) { $this.Volume } else { 1/([Math]::PI * 2) }
),

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

$currentWave = $this
if (-not $currentWave) { $currentWave = wave }
if (-not $PSBoundParameters['Frequency']) { $Frequency = 440 }

$fromAngles = $currentWave.MeasureAngle($Frequency, $SampleRate, $channelCount)

$toAngles = foreach ($from in $fromAngles) {
    $from * [Math]::Pow(2, (($Distance * -1.0)/12))    
}

# Calculate the number of samples
$numberOfSamples = [Math]::Round($Duration.TotalSeconds * $SampleRate * $channelCount) 

# Now let's make our samples
[double[]]$Samples = @(
    # Start $t at zero
    foreach ($t in 0..($numberOfSamples - 1)) {
        $ft = $t/$numberOfSamples
        #region Polysweep
        [double]$Sample = 0.0
        # Each successive angle will have a weighted volume
        # starting at full volume
        $angleWeight = 1.0
        # Take each of our angles and Add it Up
        $angles = @(
            $angleNumber = 0 
            foreach ($angle in $fromAngles) {
                $toAngle = $toAngles[$angleNumber]                
                if ($StepCount) {
                    $stepSize = ($angle - $toAngle)/$StepCount
                    $angle + ($stepSize * [Math]::Floor($ft * $StepCount))
                } else {                    
                    $angle + ($angle - $toAngle) * $ft
                }
                $angleNumber
            }
        )

        foreach ($angle in $angles) {
            # Get the sine of the times and multiply by the weight.
            $Sample += [Math]::Sin($angle * $t) * $angleWeight
            # Then half the weight               
            $angleWeight/=2
        }
        #endregion Polysweep
        
        #region Envelope        
        $envelope = 1.0 - ($t / $numberOfSamples)                        
        $sample * $Volume * $envelope    
        #endregion Envelope
    }
)

# If we have not been provided a time
if (-not $time) {
    # add it to the end.
    $time = $currentWave.Duration
}

if ($Time) {
    return $currentWave.Add($samples, $time)
}
else {
    $waveFormat = $currentWave.WaveFormat
    if (-not $waveFormat) {
        $waveFormat = @{}
    }
    return wave @waveFormat -Samples $Samples
}