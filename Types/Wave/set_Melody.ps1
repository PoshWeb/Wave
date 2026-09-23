<#
.SYNOPSIS
    Sets the Melody
.DESCRIPTION
    Sets the Melody of a Wave.
#>
param()
$This | 
    Add-Member NoteProperty '#Melody' $args -Force -PassThru