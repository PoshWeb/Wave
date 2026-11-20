<#
.SYNOPSIS
    Get Frequencies
.DESCRIPTION
    Gets any input or arguments as frequencies
#>
param()

$allArgs = @($args)
$allInput = $($input)

foreach ($in in $allInput) {
    $in -as [Wave.WaveFrequency]
}

foreach ($in in $allArgs) {
    $in -as [Wave.WaveFrequency]
}
