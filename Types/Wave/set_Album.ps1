<#
.SYNOPSIS
    Sets the Wave's Album
.DESCRIPTION
    Sets the Wave's Album metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Album (or Product) metadata is stored
    with the four letter word key: `IPRD`
#>
param([string]$Album)

$metadata = $this.metadata
$metadata.Album = $Album
$this.Metadata = $metadata
