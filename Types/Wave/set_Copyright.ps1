<#
.SYNOPSIS
    Sets the Wave's Copyright
.DESCRIPTION
    Sets the Wave's Copyright metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Copyright metadata is stored
    with the four letter word key: `ICOP`
#>
param([string]$Copyright)

$metadata = $this.metadata
$metadata.Copyright = $Copyright
$this.Metadata = $metadata
