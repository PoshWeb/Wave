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
if ($this.'#Vector3') { return $this.'#Vector3' }
[double[]]$Samples = $this.Samples
$lastSample = 0

$progress = [Ordered]@{
    Id = Get-Random    
    Activity = "Vectoring"    
}
$sampleRate = $this.SampleRate
$SampleCount = $samples.Length

[Numerics.Vector3[]]$vector3 = @(
    for ($index = 0; $index -lt $samples.Length;$index++) {
        $delta = $samples[$index] - $lastSample
        $length = [Math]::Sqrt(($delta * $delta) + 1)        

        if (-not ($index % 64kb)) {
            $progress.Status = "$index / $($SampleCount)"
            $progress.PercentComplete = ($index * 100 / $SampleCount)
            $progress.SecondsRemaining = (($SampleCount - $index) * (1 / $SampleRate))
            Write-Progress @progress
        }
        
        [Numerics.Vector3]::new(1, $delta, $(
            $length * $(
                if ($delta -gt 0) { 1 }
                elseif ($delta -lt 0) { 1 }
                else { 0 }    
            )
        ))                
        
        $lastSample = $samples[$index]
    }
)

$this | Add-Member NoteProperty '#Vector3' $vector3 -Force

return $vector3