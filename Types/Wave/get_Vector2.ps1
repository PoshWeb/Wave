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

$lastSample = 0

$progress = [Ordered]@{
    Id = Get-Random    
    Activity = "Vectoring"    
}

$sampleRate = $this.SampleRate
$SampleCount = $samples.Length

[Numerics.Vector2[]]$vector2 = @(
    for ($index = 0; $index -lt $SampleCount;$index++) {

        if (-not ($index % 64kb)) {
            $progress.Status = "$index / $($SampleCount)"
            $progress.PercentComplete = ($index * 100 / $SampleCount)
            $progress.SecondsRemaining = (($SampleCount - $index) * (1 / $SampleRate))
            Write-Progress @progress
        }

        [Numerics.Vector2]::new(1, $samples[$index] - $lastSample)

        $lastSample = $samples[$index]
    }
)

$this | Add-Member NoteProperty '#Vector2' $vector2 -Force

$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress

return ,$vector2