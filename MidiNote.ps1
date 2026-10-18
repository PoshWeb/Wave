<#
.SYNOPSIS
    Midi Note
.DESCRIPTION
    Makes any input or argument a as a `MidiNote`.
#>
$allArgs = @($args)
$allInput = $($input)

foreach ($in in $allInput) {
    if ($in.pstypenames -notcontains 'MidiNote') {
        $in.pstypenames.add('MidiNote')
    } 
    $in
}

foreach ($in in $allArgs) {
    if ($in.pstypenames -notcontains 'MidiNote') {
        $in.pstypenames.add('MidiNote')
    } 
    $in
}

