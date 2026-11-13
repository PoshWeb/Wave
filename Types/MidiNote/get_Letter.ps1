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

$rounded = [Math]::Round(
    ($remainder * $letters.Length)/$letters.Length
)

$letter = 
    if ($rounded -lt $letters.Length) {        
        $letters[$rounded]
    } else {
        'C'
        $octave += 1
    }


return $letter + $octave