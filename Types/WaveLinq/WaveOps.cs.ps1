<#
.SYNOPSIS
    Wave Linq Operations
.DESCRIPTION
    Generates the code for each common Wave Linq operation.
.NOTES

#>

param()

foreach ($method in 'Add','Subtract', 'Multiply', 'Divide') {
    $operator = switch ($method) {
        'Add' { '+' }
        'Subtract' { '-' }
        'Multiply' { '*' }
        'Divide' { '/' }
    }    

@"
    /// <summary>
    /// ${method}s a set of numbers at a specific offset.
    /// </summary>
    /// <param name='current'>The current set of samples</param>
    /// <param name='offset'>The offset</param>
    /// <param name='samples'>A list of samples to $Method</param>
    /// <returns>The $method of each number.</returns>
    public static IEnumerable<double> $Method(
        IList<double> current, 
        int offset,
        IList<double> samples   
    ) {
        int index = 0;
        if (current.Count > offset) {
            for (index = 0; index < offset; index++) {
                yield return current[index]; //get the samples until the offset
            }
        } else {
            // Otherwise, include the current samples
            foreach (double sample in current) {
                yield return sample;
            }
            
            // and pad the remainder of the time until start with silence
            int deltaSamples = offset - current.Count;
            for (int i = 0; i < deltaSamples; i++) {
                yield return 0;
            }
        }
                    
        for (index = 0; index < samples.Count; index++) {
            // If we are still within the current timeframe
            if (current.Count > (index + offset)) {
                // Add samples in at that point
                yield return current[index + offset] $operator samples[index];
            } else {
                // Otherwise, simply include the new sample
                yield return samples[index]$( if ($operator -eq '-') { '* -1'});
            }
        }

        yield break;
    }
"@


}

@"
    /// <summary>
    /// Averages two waves at a specific offset.
    /// </summary>
    /// <param name='current'>The current set of samples</param>
    /// <param name='offset'>The offset</param>
    /// <param name='samples'>A list of samples to average</param>
    /// <returns>The average wave</returns>
    public static IEnumerable<double> Average(
        IList<double> current, 
        int offset,
        IList<double> samples
    ) {
        int index = 0;
        if (current.Count > offset) {
            for (index = 0; index < offset; index++) {
                yield return current[index]; //get the samples until the offset
            }
        } else {
            // Otherwise, include the current samples
            foreach (double sample in current) {
                yield return sample;
            }
            
            // and pad the remainder of the time until start with silence
            int deltaSamples = offset - current.Count;
            for (int i = 0; i < deltaSamples; i++) {
                yield return 0;
            }
        }
                    
        for (index = 0; index < samples.Count; index++) {
            // If we are still within the current timeframe
            if (current.Count > (index + offset)) {
                // Add samples in at that point
                yield return (current[index + offset] + samples[index])/2;
            } else {
                // Otherwise, simply include the new sample
                yield return samples[index];
            }
        }

        yield break;
    }
"@

@"

    /// <summary>
    /// Simplified Wave Gain.
    /// </summary>
    /// <param name='samples'>The current set of samples</param>
    /// <param name='gain'>The gain</param>    
    /// <returns>The wave with a gain applied</returns>
    public static IEnumerable<double> Gain(
        this IEnumerable<double> samples,
        double gain
    ) {
        if (gain < 0) {
            gain = -1 / gain;
        }
        
        foreach (double sample in samples) {
            yield return sample * gain;
        }
    }
"@

@"
    /// <summary>
    /// Simplified Wave Sampler.
    /// </summary>
    /// <param name='samples'>The current set of samples</param>
    /// <param name='start'>The start sample index</param>    
    /// <param name='end'>The end sample index</param>    
    /// <returns>The samples between these portions of time</returns>
    public static IEnumerable<double> Sample(
        this IList<double> samples,
        int start,
        int end        
    ) {        
        if (start == end) { yield break; }
        if (start < end) {
            for (int index = start; index <= end ; index++) {
                if (samples.Count > index) {
                    yield return samples[index];
                } else {
                    yield return 0; 
                }
            }
        } else {
            for (int index = end; index >= start ; index--) {
                if (samples.Count > index) {
                    yield return samples[index];
                } else {
                    yield return 0; 
                }
            }
        }
    }    
"@

@"   
    /// <summary>
    /// Wave Speed.
    /// </summary>
    /// <param name='samples'>The current set of samples</param>
    /// <param name='speed'>The speed used to read samples</param>        
    /// <returns>The samples at this speed</returns>
    public static IEnumerable<double> Speed(
        this IList<double> samples,
        double speed = 1
    ) {
        if (samples == null) { yield break; }
        if (speed == 0) { yield break; }
        if (Math.Abs(speed) < 1.0/16.0) {
            throw new Exception("Will not slow beneath 1/16");
        }

        double start;
        double end;

        double newCount = Math.Abs(samples.Count / speed);
        double increment = Math.Abs(speed)/speed;

        if (speed < 0) {
            start = newCount - 1;
            end = 0.0;
        } else {
            start = 0.0;
            end = newCount - 1; 
        }
        
        for (
            double index = start;
            (index >= 0) && (index < newCount);
            index += increment
        ) {
            double oldTime = index/newCount * samples.Count;
            if (oldTime < samples.Count) {            
                double remainder = oldTime % 1;
                double lastSample = samples[(int)Math.Floor(oldTime)];
                double nextSample;
                if (Math.Ceiling(oldTime) == samples.Count) {
                    nextSample = 0;
                } else {
                    nextSample = samples[(int)Math.Ceiling(oldTime)];
                }                
                
                double delta = (nextSample - lastSample);

                if (delta == 0) {
                    yield return lastSample;
                } else {
                    yield return (
                        lastSample + (delta * remainder)
                    );
                }                                                        
            } else {
                yield return 0; 
            }
        }        
    }
"@