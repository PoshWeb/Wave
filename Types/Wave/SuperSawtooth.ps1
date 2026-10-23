<#
.SYNOPSIS
    Supersaw tone Generator
.DESCRIPTION
    Generates a super sawtooth tone of a `-Frequency`, for `-Duration`, at `-Volume`

    A supersaw is made of multiple sawtooth waves, deviating by small frequencies.

    The number of blades in the saw is called the `-Count`.
    
    By default it will be 8.

    The total `-Distance` between frequencies is measured in semitones, 
    and spread evenly across all blades.

    It defaults to 1/([Math]::PI / 2)

.NOTES
    A sawtooth wave is calculated given at a given angle using:

    ~~~PowerShell
    [Math]::atan([Math]::Tan($angle/2))
    ~~~
.LINK
    https://en.wikipedia.org/wiki/Sawtooth_wave
#>
[OutputType('Wave')]
param(
# The frequency.
# Defaults to A4 (440hz)
[Alias('Hz')]
$Frequency = 440,

# The number of blades in the supersaw
[int]
$Count = 8,

# The distance between each blade, in semitones.
# By default, -1/([Math]::PI * 2)
[double]
$Distance = -1/([Math]::pi * 2),

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume.
# If the current wave has set a `volume`, 
# will use that volume.
# Otherwise, will default to 1/([Math]::PI * 2)
[double]$Volume = $(
    if ($this.Volume) { $this.Volume } else { 1/([Math]::PI * 2) }    
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

$Params = [Ordered]@{} + $PSBoundParameters

$frequency = 
    foreach ($freq in $Frequency) {
        if ($freq.pstypenames -contains 'MidiNote') {
            $freq.Frequency
        } else {
            $freq -as [double]
        }
    }

$stepLength = $distance/$Count
$frequency =
    foreach ($freq in $Frequency) {        
        foreach ($saw in 1..[Math]::Abs($Count)) {
            $freq * [Math]::Pow(2, ((
                $stepLength * (
                    $saw - 1
                ) * -1.0)/12
            ))        
        }
    }

$params.Remove('Count')
$params.Remove('Distance')
$params['Frequency'] = $Frequency

$currentWave = $this
if (-not $currentWave) { $currentWave = wave }
return & $currentWave.Sawtooth.Script @params