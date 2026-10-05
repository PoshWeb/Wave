<#
.SYNOPSIS
    Negates Auto
.DESCRIPTION
    Negates all samples, switching their polarity and generating an opposite wave.

    This is sometimes called "antinoise".
    
    If you mix a negated wave with the original wave it will cancel out.

    This is because mixing is adding samples together, 
    and if you add 1 to -1 you get zero.
.NOTES
    This will make sine waves into cosine waves.
#>
[OutputType('audio/wav')]
param()

[double[]]$Samples = $this.Samples

$waveFormat = $this.WaveFormat

[double[]]$Inverse = foreach ($sample in $samples) {
    $sample * -1
}

return wave @waveFormat -Samples $Inverse