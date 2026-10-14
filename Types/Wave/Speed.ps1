<#
.SYNOPSIS
    Wave Speed
.DESCRIPTION
    Creates a new wave at a different speed.

    This stretches time, which bends the frequencies.

    Roughly speaking, every 1.05x increase in speed will move notes up a semitone.
.NOTES
    Speed can be any number.  
    
    Providing negative speeds will reverse the audio.
#>
param(
# The new speed
[double]
$Speed = 1
)

if ($speed -eq 1) { return $this }
# If they provided a speed of zero, 
# let's be mathematically accurate before we divide by zero.

# A wave with a speed of zero would be an empty wave.
if ($speed -eq 0) { return wave }

$newDuration = $this.Duration / $Speed

$newSampleCount = [Math]::Abs(
    [Math]::floor(
        $newDuration.TotalSeconds * $this.ChannelCount * $this.SampleRate
    )
)

# Determine where we start.
$startAtSample = 
    # If we are going forwards in time
    if ($newDuration.TotalSeconds -ge 0) {        
        0 # start at zero
    } else {
        # If we are going backwards in time
        $newSampleCount - 1 # start at the last sample
    }

# Determine our increment
$sampleIncrement =
    # This is just the sign of our duration
    [Math]::Abs($newDuration.TotalSeconds)/
        $newDuration.TotalSeconds

# Collect our current samples
[double[]]$Current = $this.Samples

# Create new samples
[double[]]$newSamples = @(    
    for (
        # starting at either end
        $sampleNumber = $startAtSample ; 
        # going until we've reached the start or end.
        $sampleNumber -ge 0 -and ($sampleNumber -lt $newSampleCount);
        # and incrementing by 1 or -1
        $sampleNumber += $sampleIncrement
    ) {
        # Determine the old time
        $oldTime = $sampleNumber/$newSampleCount * $Current.Length
        # And see if it is a whole number
        $Remainder = $oldTime % 1
        # If it was
        if (-not $Remainder) {
            # we can take this sample as-is.
            $Current[$oldTime]
        }
        else {            
            # Since there was a remainder, 
            # there is a current and next sample
            # Let's treat them as vectors
            
            $currentVector = [Numerics.Vector2]::new(1,$current[[Math]::Floor($oldTime)])
            $nextVector = [Numerics.Vector2]::new(1,$current[[Math]::Ceiling($oldTime)])
            # We just need to Lerp them together (linear interpolation time!)
            
            # Vectors can Lerp
            $lerpSample = ([Numerics.Vector2]::Lerp(
                $currentVector, $nextVector, $Remainder
            )).Y -as [double] # and our new sample is the Y component.

            $lerpSample
        }        
    }    
)

$waveFormat = $this.WaveFormat
wave @waveFormat -Samples $newSamples


