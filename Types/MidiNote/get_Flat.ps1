<#
.SYNOPSIS
    Gets a Midi Note's Flat
.DESCRIPTION
    Gets the flat of a given midi note.
#>
$flatten = $this -1
$flatten.pstypenames.add('MidiNote')
return $flatten

