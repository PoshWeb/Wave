<#
.SYNOPSIS
    Gets Wave Sample Rate
.DESCRIPTION
    Gets the Sample Rate used for the Wave.

    This is the number of audio samples per second
.NOTES
    This is bytes 4 to 7 in the Format `fmt ` chunk (`4..7`)
#>

# The expected range
$range = 4..7
# If we have no cached format
if (-not $this.'#fmt') {
    # read chunks.
    $null = $this.Chunk
    # Return if we still have no cached format
    if (-not $this.'#fmt') { return }
}

# Otherwise, convert the range into a [uint32]
[bitConverter]::ToUint32($this.'#fmt'[$range] -as [byte[]])

