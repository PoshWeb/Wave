<#
.SYNOPSIS
    Sets the Wave's Artist
.DESCRIPTION
    Sets the Wave's album metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Artist metadata is stored
    with the four letter word key: `IART`
#>
param([string]$Artist)

$metadata = $this.metadata
$metadata.Artist = $Artist
$this.Metadata = $metadata
