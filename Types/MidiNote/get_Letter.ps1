<#
.SYNOPSIS
    Gets MidiNote in Letter format
.DESCRIPTION
    Gets this midi note in Letter format.
#>
param()


$letters = 'C','Cs','D','Ds','E','F','Fs','G','Gs','A','As','B'


$abs = [Math]::Abs($this)
if ($abs -lt 24) {
    $octave = 0    
} else {    
    $octave = [Math]::Floor(
        ($abs - 12) / 12
    )
}

$remainder = ($abs - 12) % 12

$letter = 
    if ($remainder) {
        $letters[
            [Math]::Floor(
                ($remainder * $letters.Length)/$letters.Length
            )
        ]
    } else {
        'C'
    }


return $letter + $octave