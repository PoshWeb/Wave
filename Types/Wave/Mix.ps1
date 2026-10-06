<#
.SYNOPSIS
    Mixes Waves
.DESCRIPTION
    Mixes one wave's samples with another.  Outputs a new wave.        
.NOTES
    We mix two waves whatever way we want.  
    
    Not all of those ways will sound nice.
    
    At it's heart, a mix is simply a function we apply to a two waves.

    By default this function is `add`.
    
    This matches how waves work in real life.  
    
    When two waves intersect, they are added together.  
    
    This is also why an opposite waves cancel out.  
    
    One wave has a positive value, one wave has a negative value.
    
    Add those two together and you get zero.

    There are a few other built in mix functions:

    * `subtract`
    * `multiply`
    * `average`
    
    Feel free to experiment with your own functions.
#>
param($wave, $function = 'add', $parameters)

$mixWith = $null
if ($wave.pstypenames -contains 'audio/wav') {
    [double[]]$MixWith = $wave.samples
} elseif ($wave -is [double[]]) {
    [double[]]$MixWith = $wave
}

$waveSplat = $this.WaveFormat

if ($function -is [string]) {
    $function = switch -regex ($function -replace '[<>\[\]]') {
        '^(\+|Add)$' {
            {
                for ($index = 0; $index -lt $samples.Count; $index++) {
                    $samples[$index] + ($MixWith[$index % $MixWith.Length])
                }
            }
        }
        '^(\-|Subtract)$' {
            {
                for ($index = 0; $index -lt $samples.Count; $index++) {
                    $samples[$index] - ($MixWith[$index % $MixWith.Length])
                }
            }
        }
        '^(\~|Avg|Average)$' {
            {
                for ($index = 0; $index -lt $samples.Count; $index++) {
                    $samples[$index] + ($MixWith[$index % $MixWith.Length]) / 2
                }
            }
        }
        '^(\*|x|Multiply)$' {
            {
                for ($index = 0; $index -lt $samples.Count; $index++) {
                    $samples[$index] * ($MixWith[$index % $MixWith.Length])
                }
            }
        }        
    }
}

if ($MixWith -and $function -is [ScriptBlock]) {
    [double[]]$samples = $this.Samples
    $mixed = wave @waveSplat -Samples @(
        if ($parameters -is [Collections.IDictionary]) {
            . $function.GetNewClosure() @parameters
        } elseif ($parameters -is [array]) {
            . $function.GetNewClosure() @parameters
        } 
        elseif ($null -ne $parameters) {
            $parameters = @($parameters)
            . $function.GetNewClosure() @parameters
        } else {
            . $function.GetNewClosure()
        }
    )

    return $mixed
}
return 
