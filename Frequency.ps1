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
    $in -as [Wave.Frequency]
}

foreach ($in in $allArgs) {
    $in -as [Wave.Frequency]
}
