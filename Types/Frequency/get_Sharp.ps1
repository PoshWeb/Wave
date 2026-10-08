<#
.SYNOPSIS
    Gets a Frequency's Sharp
.DESCRIPTION
    Gets the sharp of a given frequency.
#>
$sharpen = $this / [Math]::Pow(2, (-1/12))
$sharpen.pstypenames.add('Frequency')
return $sharpen

