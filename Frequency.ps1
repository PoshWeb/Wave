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
    if ($in.pstypenames -notcontains 'Frequency') {
        $in.pstypenames.add('Frequency')
    } 
    $in
}

foreach ($in in $allArgs) {
    if ($in.pstypenames -notcontains 'Frequency') {
        $in.pstypenames.add('Frequency')
    } 
    $in
}
