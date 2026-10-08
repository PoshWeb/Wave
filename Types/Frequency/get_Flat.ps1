<#
.SYNOPSIS
    Gets a Frequency's Flat
.DESCRIPTION
    Gets the flat of a given frequency.
#>
$flatten = $this * [Math]::Pow(2, (-1/12))
$flatten.pstypenames.add('Frequency')
return $flatten
