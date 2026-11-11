<#
.SYNOPSIS
    Sets the Wave's CreationDate
.DESCRIPTION
    Sets the Wave's CreationDate metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    CreationDate metadata is stored
    with the four letter word key: `ICRD`
#>
param([DateTime]$CreationDate)

$metadata = $this.metadata
$metadata.CreationDate = $CreationDate
$this.Metadata = $metadata
