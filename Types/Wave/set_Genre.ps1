<#
.SYNOPSIS
    Sets the Wave's Genre
.DESCRIPTION
    Sets the Wave's Genre metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Genre metadata is stored
    with the four letter word key: `IGNR`
#>
param([string]$Genre)

$metadata = $this.metadata
$metadata.Genre = $Genre
$this.Metadata = $metadata
