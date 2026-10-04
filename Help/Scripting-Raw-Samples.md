# Scripting Raw Samples

We can do amazing things just by manipulating samples.

A sample is a wave at a moment in a time.

It is just an array of `[double[]]`s.

Each sample represents a point in wave.

We decode the audio by converting bytes to samples.

We encode the audio by converting samples to bytes.

`Wave` makes this pretty easy with the `-Samples` parameter.

This will encode whatever samples are passed in,
using whatever `-AudioFormat`, `-SampleRate`, `-ChannelCount`, etc.

This means we can script raw samples with PowerShell if we want to.

Let's show how.

## Step 1 : Making a Wave

All waves are fundamentally sine waves.

We can make a really quick filter that gives us a lot of sine waves,
moving at a specific frequency

~~~PowerShell
filter sine {
    param([double]$stepAngle = 0)
    [Math]::Sin($_ * $stepAngle)
}
~~~

Now let's figure out our angle.

Imagine drawing a point on a circle N times per second.

Our frequency is how many circles we are trying to draw.

~~~PowerShell
$cycle = 2 * [Math]::PI * $Frequency
~~~

If we have 44100 samples per second, the wave needs to change by:

~~~PowerShell
$cycle/44100
~~~

If it was in stereo, the wave needs to change by:

~~~PowerShell
$cycle/(44100 * 2)
~~~

In general terms:

~~~PowerShell
$stepAngle = $cycle/($sampleRate * $channelCount)
~~~

Let's bring it all together and make a pure unattenuated sine wave:

~~~PowerShell
filter sine {
    param([double]$stepAngle = 0)
    [Math]::Sin($_ * $stepAngle)
}
$sampleRate = 44100
$channelCount = 1
$frequency = 440
$cycle = 2 * [Math]::PI * $Frequency
$stepAngle = $cycle/$sampleRate
$sineWave = wave -Samples (0..($sampleRate - 1) | sine $stepAngle)
$sineWave.Play()
~~~

## Step 2 : Putting it an envelope

When we play a sound, it normally fades out slightly over time.

An envelope describes the shape of the volume over time.

The most simple envelope is a flat slope between full volume and no volume.

We can write this in a fast freeform function.

~~~PowerShell
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
~~~

Let's put our sine wave in an envelope:

~~~PowerShell
filter sine {
    param([double]$stepAngle = 0)
    [Math]::Sin($_ * $stepAngle)
}
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
$sampleRate = 44100
$channelCount = 1
$frequency = 440
$cycle = 2 * [Math]::PI * $Frequency
$stepAngle = $cycle/$sampleRate
$sineWave = wave -Samples (0..($sampleRate - 1) | sine $stepAngle | envelope)
$sineWave.Play()
~~~

This will sound like:

~~~PowerShell
wave sine 440 "00:00:01" 1 play 
~~~

Because this is exactly how the sine generator works.

It makes a sine wave and stuffs it in an envelope.

That's how audio is made.

You can do _anything_ with a Wave by scripting raw samples.