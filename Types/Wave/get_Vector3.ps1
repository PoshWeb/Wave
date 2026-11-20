<#
.SYNOPSIS
    Gets Wave Vector
.DESCRIPTION
    Gets a Wave as a series of Vectors.

    We can think of a wave as a series of vectors.

    Each sample in the wave travels one distance along the X axis, 
    and up or down along the along the Y axis.

    We can also think of the length of the line between 
    X and Y as the depth (Z) of the wave, 
    and thus view each Wave as a series of 3D vectors.
.NOTES
    Thinking of waves this way provides some benefits.

    This will write progress as it calculates and 
    cache the vectors in memory after they are calculated.
#>

if ($this.'#Vector3') { return ,$this.'#Vector3' }

[double[]]$Samples = $this.Samples

[Numerics.Vector2[]]$vector3 = [Wave.WaveMath]::ToVector3($samples)

if ($vector2) {
    $this | Add-Member NoteProperty '#Vector3' $vector3 -Force
    return ,$vector3
}