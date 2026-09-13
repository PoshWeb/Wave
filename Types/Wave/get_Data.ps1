<#
.SYNOPSIS
    Gets Wave Data
.DESCRIPTION
    Gets the byte[] describing a wave.
#>
[CmdletBinding()]
param()
# Use the comma operator to return a list containin the data, 
# so that it unrolls to the data itself (rather than tries to stream the bytes)
return ,$this.'#data'