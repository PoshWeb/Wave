<#
.SYNOPSIS
    Wave Melody Palindrome
.DESCRIPTION
    Plays a melody in normal order, and then plays a melody in reversed order.

    The resulting letters in the melody will form a palindrome
.LINK
    https://en.wikipedia.org/wiki/Palindrome
#>
$melody = @($this.Melody)

# If there is not a current melody, return this
if (-not $melody) { return $this }

# Assign the current melody to the palindrome
$this.Melody = @(
    $melody
    [Array]::Reverse($melody)
    $melody    
)

# Play the sound.
return $this.Sound()
