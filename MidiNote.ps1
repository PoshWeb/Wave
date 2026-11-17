<#
.SYNOPSIS
    Midi Note
.DESCRIPTION
    Makes any input or argument a as a `MidiNote`.
#>
$allArgs = @($args)
$allInput = $($input)

foreach ($in in $allInput) {
    
    if ($in -as [double]) {
        $f = [Wave.Frequency]::new()
        $f.MidiNumber = $in
        $f
    }
         
}

foreach ($in in $allArgs) {
    if ($in -as [double]) {
        $f = [Wave.Frequency]::new()
        $f.MidiNumber = $in
        $f
    }     
}

