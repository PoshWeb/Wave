<#
.SYNOPSIS
    Gets Wave Channel Count
.DESCRIPTION
    Gets the number of audio channels in a wave.

    * `1` indicates mono audio
    * `2` indicates stereo audio
.NOTES
    This is bytes 2 to 3 in the `fmt ` chunk.
#>


# The expected range
$range = 2..3
# If we have no cached format
if (-not $this.'#fmt') {
    # read chunks.
    $null = $this.Chunk
    # Return if we still have no cached format
    if (-not $this.'#fmt') { return }
}

# Otherwise, convert the range into a [uint16]
[bitConverter]::ToUint16($this.'#fmt'[$range] -as [byte[]])