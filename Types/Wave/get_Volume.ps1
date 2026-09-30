<#
.SYNOPSIS
    Gets Wave Volume
.DESCRIPTION
    Gets a custom volume to apply to a wave.

    This is used to provide a default value for Wave methods that use `-Volume`.

    If no value has been set, will return zero.
#>
param()
if ($this.'#Volume') { return $this.'#Volume' }
return 0