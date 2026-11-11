<#
.SYNOPSIS
    Sets the Wave's Comments
.DESCRIPTION
    Sets the Wave's comment metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Comment metadata is stored
    with the four letter word key: `ICMT`
#>
param([string]$Comment)

$metadata = $this.metadata
$metadata.Comments = $Comment
$this.Metadata = $metadata
