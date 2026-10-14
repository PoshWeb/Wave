<#
.SYNOPSIS
    Calculates Wave Angles
.DESCRIPTION
    Calculates the angle needed to play a frequency.

    Sounds are sine waves.  
    
    A full unattenuated sine wave will take the form:

    ~~~PowerShell
    [Math]::Sin($t * $angle)
    ~~~
    
    Where $t is the time and the angle is the amount our frequency needs to play each step.

    This method measures the angles we need to draw, given our sample rate and channel count.
#>
param(
$Frequency,

$SampleRate = $(
    if ($this.SampleRate) {
        $this.SampleRate
    } else { 44100 }
),

$channelCount = $(
    if ($this.ChannelCount) {
        $this.ChannelCount
    } else { 1 }
)
)


# Convert each frequency into an angle 
foreach ($freq in $Frequency) {
    # If the frequency was an integer between 21 and 108
    if ($freq -is [int] -and ($freq -ge 21 -and $freq -le 108)) {
        # make it a midi note
        $freq.pstypenames.add('MidiNote')
    }

    # If the frequency is a midi note
    if ($freq.pstypenames -contains 'MidiNote') {
        $freq = $freq.Frequency # get it's actual frequency
    }
    # Cast our frequency to a double
    $freq = $freq -as [double]

    # For each frequency we play,
    # we can imagine drawing a series of circles.
    # How many circles?  Whatever our frequency may be.
    $cycle = 2 * [Math]::PI * $freq
    # What angle do we need to use?

    # Take our circumference and divide by our sample rate and channel count.
    # This is the angle, in radians
    $cycle/($sampleRate * $channelCount)
}

