<#
.SYNOPSIS
    Gets Wave Sample Rate
.DESCRIPTION
    Gets the Sample Rate used for the Wave.

    This is the number of audio samples per second
.NOTES
    This is bytes 4 to 7 in the Format `fmt ` chunk (`4..7`)

    Mathematically speaking, we can have a negative sample rate, or a fractional sample rate.

    The `.wav` standard specifies the length in four bytes.
    
    Those bytes are expected to be a `[uint32]`.

    Many players will not play wave files below a 4400hz rate.
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
[bitConverter]::ToUint32($this.'#fmt'[$range] -as [byte[]], 0)

