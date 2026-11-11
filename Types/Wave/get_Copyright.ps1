<#
.SYNOPSIS
    Gets the Wave's Copyright 
.DESCRIPTION
    Gets the Copyright of the wave.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Copyright metadata is stored
    with the four letter word key: `ICOP`
#>

return $this.metadata.Copyright
