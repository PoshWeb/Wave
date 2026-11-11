<#
.SYNOPSIS
    Gets the Wave's TrackNumber 
.DESCRIPTION
    Gets the Wave TrackNumber metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    TrackNumber (or Part Number) metadata is stored
    with the four letter word key: `IPRT`
#>

return $this.metadata.TrackNumber -as [int]
