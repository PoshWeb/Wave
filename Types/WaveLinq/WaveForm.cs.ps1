<#
.SYNOPSIS
    Wave Linq WaveForms
.DESCRIPTION
    Generates the code for each Wave Linq Waveform.
.NOTES
    Each of these are optimized polyphonic waveform generators,
    which is a fancy way of saying "quick makes lots of sounds".

    Each accepts:
    
    * `IEnumerable<double> time`
    * `IEnumerable<double> frequency`
    * `double[]` weight
#>

param()

@"
    /// <summary>
    /// Sweep generator.  At a small enough timeframe, everything is a sweep.
    /// </summary>
    /// <param name='frequency'>
    /// A sequence of double[] representing the frequencies to sweep
    /// Each frequency is a single sample, or the Sin of the time.
    /// </param>
    /// <param name='phase'>
    /// The offset from a pure sine wave.    
    /// </param>
    /// <returns>
    /// An `IEnumerable<double>` of samples.
    /// This is the raw unattenuated waveform.
    /// </returns>
    /// </exception>
    public static IEnumerable<double> SweepWave (
        IEnumerable<double> frequency,
        double phase = 0
    ) {
        double c = phase;
        // For each sample we want to generate
        foreach (double freq in frequency) {            
            // Yield our sample, letting iteration continue.        
            yield return Math.Sin(c * freq);
            c++;
        }
        
        // When we have reached the end of our time
        // take a break.
        yield break;
    }
"@

$waveForms = [Ordered]@{    
    "SineWave" = "Math.Sin(t * freq) * w"
    "CosineWave" = "Math.Cos(t * freq) * w"
    "TriangleWave" = "Math.Asin(Math.Sin(t * freq)) * w"
    "CosineTriangleWave" = "Math.Acos(Math.Cos(t * freq)) * w"
    "SawWave" = "Math.Atan(Math.Tan(t/2 * freq)) * w"
    "CosineSawWave" = "Math.Atan(Math.Tan(t/2 * freq)) * w * -1.0"
    "CosineSquareWave" = "
double sine = Math.Cos(t * freq);
if (sine > 0) {
    sample += 1.0 * w;
}
else if (sine < 0) {
    sample += -1.0 * w;
}
"
    "SquareWave" = "
double sine = Math.Sin(t * freq);
if (sine > 0) {
    sample += 1.0 * w;
}
else if (sine < 0) {
    sample += -1.0 * w;
}
"
    "CircleSquareWave" = "
double sine = Math.Sin(t * freq);
if (sine > 0) {
    sample += sine * w;
}
else if (sine < 0) {
    sample += -1.0 * w;
}
"
    "SquareCircleWave" = "
double sine = Math.Sin(t * freq);        
if (sine > 0) {
    sample += 1.0 * w;
}
else if (sine < 0) {
    sample += sine * w;
}
"
    "TriangleCircleWave" = "
double sine = Math.Sin(t * freq);
if (sine > 0) {
    sample += Math.Asin(sine) * w;
}
else if (sine < 0) {
    sample += sine * w;
}
"
    "CircleTriangleWave" = "
double sine = Math.Sin(t * freq);
if (sine > 0) {
    sample += sine * w;
}
else if (sine < 0) {
    sample += Math.Asin(sine) * w;
}
    "
}

$methods = foreach ($waveType in $waveForms.Keys) {
@"
    /// <summary>
    /// ${wavetype} generator.
    /// </summary>
    /// <param name='time'>
    /// A sequence of double[] representing the time.
    /// Each whole number should be a sample.</param>
    /// <param name='frequency'>
    /// A sequence of frequencies.
    /// The combined wave is the sum of all frequencies.
    /// </param>
    /// <returns>
    /// An `IEnumerable<double>` of samples.
    /// This is the raw unattenuated waveform.
    /// </returns>    
    /// </exception>
    public static IEnumerable<double> $WaveType (
        IEnumerable<double> time,
        IEnumerable<double> frequency,
        double[] weight
    ) {
        // If there is no time, break
        if (time == null) { yield break; }
        // If there is no weight, break
        if (weight == null) {
            yield break;
        }
        // If the weight is zero, make it 1
        if (weight.Length == 1 && weight[0] == 0) {
            weight[0] = 1;
        }
        // For each sample we want to generate
        foreach (double t in time) {
            // If the frequency was null, return silence
            if (frequency == null) {
                yield return 0.0;
            } else {
                // Otherwise, we want to sum multiple waveforms
                // so start our frequency count at zero
                int freqNumber = 0;
                // and our sample at 0.0
                double sample = 0.0;                
                // Then set the weight to the first item in the list.
                double w = weight[0];               
                // Then generate the wave for each frequency 
                foreach (double freq in frequency) {
                    // adding each of our outputs to the sample.
                    $(if ($waveForms[$waveType] -match '\n') {
                        $waveForms[$waveType] -split '(?>\r\n|\n)' -ne '' -join "$(
                            ([Environment]::NewLine) +(' ' * 20)
                        )"
                    } else {
                        "sample += $($waveForms[$waveType]);"
                    })
                    // Move onto the next frequency
                    freqNumber++;
                    // If we have any more weights
                    if (freqNumber < weight.Length) {
                        // Make the next frequency that weight.
                        w = weight[freqNumber];
                    } else {
                        // Otherwise, half the weight                        
                        w /= 2; 
                    }
                }
                // Yield our sample, letting iteration continue.
                yield return sample;
            }
        }
        
        // When we have reached the end of our time
        // take a break.        
        yield break;
    }
"@    
}

$methods -join ([Environment]::NewLine * 2)