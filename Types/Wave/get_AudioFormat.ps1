<#
.SYNOPSIS
    Gets Wave Audio Format
.DESCRIPTION
    Gets the Wave Audio Format.  This should either be a 1 or a 3.
.NOTES
    This is the first pair of bytes in the Format `fmt ` chunk.    
#>

# The expected range is 0,1 (first two bytes)
$range = 0,1
# If we have no cached format
if (-not $this.'#fmt') {
    # read chunks.
    $null = $this.Chunk
    # Return if we still have no cached format
    if (-not $this.'#fmt') { return }
}

# Otherwise, convert the range into a [uint16]
[bitConverter]::ToUint16($this.'#fmt'[$range] -as [byte[]], 0)
