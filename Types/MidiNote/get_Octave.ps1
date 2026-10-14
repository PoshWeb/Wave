<#
.SYNOPSIS
    Gets the Octave
.DESCRIPTION
    Gets the Octave for a midi note
#>
$abs = [Math]::Abs($this)
if ($abs -lt 24) {
    0
} else {    
    [Math]::Ceiling(
        ($abs - 12) / 12
    )
}
