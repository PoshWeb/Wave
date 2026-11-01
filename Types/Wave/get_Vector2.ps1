<#
.SYNOPSIS
    Gets Wave Vector
.DESCRIPTION
    Gets a Wave as a series of Vectors.

    We can think of a wave as a series of vectors.

    Each sample in the wave travels one distance along the X axis, 
    and up or down along the along the Y axis.
.NOTES
    Thinking of waves this way provides some benefits.

    This will write progress as it calculates and 
    cache the vectors in memory after they are calculated.
#>
[OutputType([Numerics.Vector2[]])]
param()

if ($this.'#Vector2') { return ,$this.'#Vector2' }

[double[]]$Samples = $this.Samples

[Numerics.Vector2[]]$vector2 = [Wave.WaveLinq]::ToVector2($samples)

if ($vector2) {
    $this | Add-Member NoteProperty '#Vector2' $vector2 -Force
    return ,$vector2
}