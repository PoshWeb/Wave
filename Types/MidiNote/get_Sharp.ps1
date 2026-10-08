<#
.SYNOPSIS
    Gets a Midi Note's Sharp
.DESCRIPTION
    Gets the sharp of a given midi note.
#>
$sharpen = $this + 1
$sharpen.pstypenames.add('MidiNote')
return $sharpen

