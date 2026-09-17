<#
.SYNOPSIS
    Gets Wave Data
.DESCRIPTION
    Gets the byte[] describing a wave.
#>
[CmdletBinding()]
param()

# If we have not cached our data chunk
if (-not $this.'#data') {
    # read chunks
    $null = $this.Chunk
    # If there is still nothing
    if (-not $this.'#data') {
        return # return nothing.
    }
}
# Use the comma operator to return a list containin the data, 
# so that it unrolls to the data itself (rather than tries to stream the bytes)
return ,$this.'#data'