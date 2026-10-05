<#
.SYNOPSIS
    Piping Samples
.DESCRIPTION
    Making waves by piping in raw samples.
.NOTES
    We can make waves by piping samples directly into wave.

    Let's declare a few filters and make some waves!
#>

# A wave is a sine wave

filter sine {
    param([double]$stepAngle = 0)
    [Math]::Sin($_ * $stepAngle)
}

# Scaled by a volume
filter volume {
    param([double]$Volume = 0.5)
    $_ * $volume
}

# Put into an envelope

function envelope {
    # Gather all of our input
    $allInput = @($input)
    # Determine the amount we will hush per step
    $hush = 1/$allInput.Count
    # Walk over each step 
    for ($n = 0; $n -lt $allInput.Length; $n++) {
        # and multiply by 1 - ($n * $hush)
        $allInput[$n] * (1 - ($n * $hush))
    }
}

# At a given sample rate
$sampleRate = 44100
# across a number of channels
$channelCount = 1

# We'll make A4 (440hz)
$a4 = 440

# We can imagine drawing 440 circles in a second
$cycle = 2 * [Math]::PI * $a4
# Our angle per step is our cycle 
# divided by our sample rate and channel count.
$stepAngle = $cycle/($sampleRate*$channelCount)


$sine440 = 
    0..44109 | # We'll make 44100 samples
        sine $stepAngle | # of pure sine waves 
            volume | # scaled to a volume
                envelope | # put into an envelope
                    wave # and made into a wave.

# And now we'll play the wave
$sine440 | wave play

# Now we'll do the same for a3
$a3 = 220

# Figure out our cycle and step angle
$cycle = 2 * [Math]::PI * $a3
$stepAngle = $cycle/($sampleRate*$channelCount)

$sine220Samples = 
    0..44109 | # Pipe 44100 numbers into 
        sine $stepAngle | # our sine wave        
            volume | # scaled to our volume
                envelope # and put into an envelope.

# We haven't made this a wave just yet
# make it a wave by piping it in and play it synchronously
$sine220Samples | wave PlaySync

# Then let's mix it with the samples from our 440 wave and play that
$sine220Samples | wave -Samples $sine440.Samples | wave play





