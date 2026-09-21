<#
.SYNOPSIS
    Gets Wave Angle
.DESCRIPTION
    Gets a Wave as a series of angles (in degrees).

    Each sample in the wave travels one distance along the X axis, 
    and up or down along the along the Y axis.

    The angle we are moving up or down captures the shape of the waveform.
.NOTES
    Thinking of waves this way provides some benefits.
    
    This will write progress as it calculates and 
    cache the vectors in memory after they are calculated.
#>
param()

if ($this.'#Angle') { return $this.'#Angle' }

[double[]]$Samples = $this.Samples

$lastSample = 0

$progress = [Ordered]@{
    Id = Get-Random    
    Activity = "Vectoring"    
}

$sampleRate = $this.SampleRate
$SampleCount = $samples.Length
$degree = (180/[Math]::PI)

[double[]]$Angle = @(
    for ($index = 0; $index -lt $SampleCount;$index++) {

        if (-not ($index % 64kb)) {
            $progress.Status = "$index / $($SampleCount)"
            $progress.PercentComplete = ($index * 100 / $SampleCount)
            $progress.SecondsRemaining = (($SampleCount - $index) * (1 / $SampleRate))
            Write-Progress @progress
        }

        
        $degree/[Math]::Atan2(1,$samples[$index] - $lastSample)
        
        
        $lastSample = $samples[$index]
    }
)

$this | Add-Member NoteProperty '#Angle' $Angle -Force

$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress

return $Angle