<#
.SYNOPSIS
    Sets the Wave's TrackNumber
.DESCRIPTION
    Sets the Wave's TrackNumber metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    TrackNumber (or Part Number) metadata is stored
    with the four letter word key: `IPRT`
#>
param([int]$TrackNumber)

$metadata = $this.metadata
$metadata.TrackNumber = "$TrackNumber"
$this.Metadata = $metadata
