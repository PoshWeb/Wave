<#
.SYNOPSIS
    Gets Wave Volume
.DESCRIPTION
    Gets a cached Volume value from a wave.

    This is used to provide a default value for Wave methods that use `-Volume`.

    If no Volume has been provided, returns nothing.
#>
if ($this.'#Volume') {
    return $this.'#Volume'
}