<#
.SYNOPSIS
    Sets the Melody
.DESCRIPTION
    Sets the Melody of a Wave.

    The melody is the sequence of instructions the wave will play.
#>
param()
$This | 
    Add-Member NoteProperty '#Melody' $args -Force -PassThru