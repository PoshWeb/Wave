<#
.SYNOPSIS
    Reverses Wave Melody
.DESCRIPTION
    Reverses a Wave's melody.  
    
    This reverses the notes in the wave, but does not reverse the samples.
#>
param()

# Get the current melody
$melody = @($this.Melody)

# If there is not a current melody, return this
if (-not $melody) { return $this }

# Reverse the melody
[Array]::Reverse($melody)

# Reassign the current melody to it's reverse
$this.Melody = $melody

# Return the reversed melody
return $this.Sound()
