<#
.SYNOPSIS
    Sets Wave Metadata
.DESCRIPTION
    Sets Metadata about a Wave File.

    Wave files can include metadata in a LIST chunk

    Each piece of metadata is a 4-byte ASCII identifier,
    a 4-byte length, and an ASCII string.
.NOTES    
    Each header must start at a WORD boundary, or two bytes.
    
    If the ASCII string had an odd number of characters, the next byte will be ignored.
#>
param([Collections.IDictionary]$MetaData)

$this.Metadata = $MetaData

return $this