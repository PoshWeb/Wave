<#
.SYNOPSIS
    Wave Linq WaveForms
.DESCRIPTION
    Generates the code for each Wave Linq Waveform.
.NOTES
    Each waveform has four overloads:

    * SimpleMonophonic ([double]frequency, [double]time, [double]weight, [uint32]sampleRate)
    * MonophonicSweep ([double[]]frequency, [double]time, [double]weight, [uint32]sampleRate)
    * SimplePolyphonic ([double]time, [double[]]frequency, [double[]]weight, [uint32]sampleRate)
    * ComplexPolyphonic ([double[]]time, [double[]]frequency, [double[]]weight)
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
    "SineWave" = "
sample += Math.Sin(t * f) * w;
"
    "CosineWave" = "
sample += Math.Cos(t * f) * w;
"
    "TriangleWave" = "
sample += Math.Asin(Math.Sin(t * f)) * w;
"
    "CosineTriangleWave" = "
sample += Math.Acos(Math.Cos(t * f)) * w;
"
    "SawWave" = "
sample += Math.Atan(Math.Tan(t/2 * f)) * w;
"
    "CosineSawWave" = "
sample += Math.Atan(Math.Tan(t/2 * f)) * w * -1.0;
"
    "CosineSquareWave" = "
double sine = Math.Cos(t * f);
if (sine > 0) {
    sample += 1.0 * w;
}
else if (sine < 0) {
    sample += -1.0 * w;
}
"
    "SquareWave" = "
double sine = Math.Sin(t * f);
if (sine > 0) {
    sample += 1.0 * w;
}
else if (sine < 0) {
    sample += -1.0 * w;
}
"
    "CircleSquareWave" = "
double sine = Math.Sin(t * f);
if (sine > 0) {
    sample += sine * w;
}
else if (sine < 0) {
    sample += -1.0 * w;
}
"
    "SquareCircleWave" = "
double sine = Math.Sin(t * f);        
if (sine > 0) {
    sample += 1.0 * w;
}
else if (sine < 0) {
    sample += sine * w;
}
"
    "TriangleCircleWave" = "
double sine = Math.Sin(t * f);
if (sine > 0) {
    sample += Math.Asin(sine) * w;
}
else if (sine < 0) {
    sample += sine * w;
}
"
    "CircleTriangleWave" = "
double sine = Math.Sin(t * f);
if (sine > 0) {
    sample += sine * w;
}
else if (sine < 0) {
    sample += Math.Asin(sine) * w;
}
    "
}

<#

For each of our waveforms we want to generate multiple overloads:

* A simple monophonic generator that generates a frequency for a time at a volume.
* A sweeping monophonic generator that accepts a list of frequencies over time.
* A polyphonic generator that accepts a list of times, frequencies, and weights 

Aside from the volume scale, each wave should be unattenuated.

It should be put into an appropriate envelope.

#>
$methods = foreach ($waveType in $waveForms.Keys) {

    #region Simple Monophonic
@"
    /// <summary>
    /// ${wavetype} generator.
    /// </summary>
    /// <param name='frequency'>
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
    public static IEnumerable<double> $WaveType (
        this double frequency,
        double time = 60.0/128.0,
        double weight = 0.5,
        uint sampleRate = (uint)44100
    ) {
        int sampleCount = (int)Math.Round((time * (double)sampleRate));
        double f = (Math.PI * 2 * frequency)/sampleRate;
        double w = weight;        
        for (int sampleNumber = 0; sampleNumber < sampleCount;sampleNumber++) {
            double sample = 0;
            double t = (double)sampleNumber;
            $(
                $waveForms[$waveType] -split '(?>\r\n|\n)' -ne '' -join "$(
                    ([Environment]::NewLine) +(' ' * 12)
                )"
            )
            yield return sample;
        }
        yield break;
    }
"@
    #endregion Simple Monophonic

    #region Sweeping Monophonic    
@"
    /// <summary>
    /// ${wavetype} generator.
    /// </summary>
    /// <param name='frequency'>
    /// A sequence of double[] representing the time.
    /// Each whole number should be a sample.</param>
    /// <param name='time'>
    /// The number of seconds to generate    
    /// </param>
    /// <param name='weight'>
    /// The weight applied to each sample.  This scales the volume.    
    /// </param>
    /// <param name='sampleRate'>
    /// The sample rate.
    /// Multi-channel audio has an effective sample rate of SampleRate*ChannelCount     
    /// </param>
    /// <returns>
    /// An `IEnumerable<double>` of samples.
    /// This is the raw unattenuated waveform.
    /// </returns>        
    public static IEnumerable<double> $WaveType (
        this List<double> frequency,
        double time = 60.0/128.0,
        double weight = 0.5,
        uint sampleRate = (uint)44100
    ) {
        if (frequency.Count == 0) { yield break; }
        if (frequency.Count == 1) {
            foreach (double sample in frequency[0].$WaveType(time,weight,sampleRate)) {
                yield return sample;
            }
            yield break;
        }

        int sampleCount = (int)Math.Round((double)time * (double)sampleRate);

        double w = weight;
        double frequencyStepLength = (double)sampleCount/(double)frequency.Count;
        for (int sampleNumber = 0; sampleNumber < sampleCount;sampleNumber++) {
            double sample = 0;
            double t = (double)sampleNumber;
            double ft = (
                (double)sampleNumber/(double)sampleCount
            );
             
            double fromFrequency = frequency[(int)Math.Floor(ft * (frequency.Count - 1))];            
            double toFrequency =  frequency[(int)Math.Ceiling(ft * (frequency.Count - 1))];
            double momentFrequency = fromFrequency + (
                (toFrequency - fromFrequency) * ((ft * (frequency.Count - 1)) % 1)
            );
            double f = (Math.PI * 2 * momentFrequency)/sampleRate;
            $(
                $waveForms[$waveType] -split '(?>\r\n|\n)' -ne '' -join "$(
                    ([Environment]::NewLine) +(' ' * 12)
                )"
            )
            yield return sample;
        }
        yield break;
    }
"@
    #endregion Sweeping Monophonic

    #region Simple Polyphonic
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
        this double time,
        IEnumerable<double> frequency,
        double[] weight = null,
        uint sampleRate = (uint)44100
    ) {
        int sampleCount = (int)Math.Round((time * (double)sampleRate));
        if (weight == null) {
            weight = new double[1];
            weight[0] = 1;            
        }
        // If the weight is zero, make it 1
        if (weight.Length == 1 && weight[0] == 0) {
            weight[0] = 1;
        }
        for (int sampleNumber = 0; sampleNumber < sampleCount;sampleNumber++) {
            double t = (double)sampleNumber;        
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
                    double f = (freq * Math.PI * 2)/(double)sampleRate; 
                    // adding each of our outputs to the sample.
                    $(
                        $waveForms[$waveType] -split '(?>\r\n|\n)' -ne '' -join "$(
                            ([Environment]::NewLine) + (' ' * 20)
                        )"
                    )
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
    #endregion Simple Polyphonic

    #region Complex Polyphonic
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
                foreach (double f in frequency) {
                    // adding each of our outputs to the sample.
                    $(
                        $waveForms[$waveType] -split '(?>\r\n|\n)' -ne '' -join "$(
                            ([Environment]::NewLine) +(' ' * 20)
                        )"
                    )
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
    #endregion Complex Polyphonic    
}

$methods -join ([Environment]::NewLine * 2)