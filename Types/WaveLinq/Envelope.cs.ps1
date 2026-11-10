$envelopes = [Ordered]@{
    "Attack" = "n / total"    
    "FadeIn" = "n / total"
    "FadeOut" = "1.0 - (n/total)"    
    "Decay" = "1.0 - (n/total/2)"
    "Sustain" = "0.5"
    "Release" = "0.5 - (n/total/2)"
    "SinFadeIn" = "Math.Sin(n/total * (Math.PI/2))"
    "SinFadeOut" = "Math.Sin((1.0 - (n/total)) * (Math.PI/2))"
    "SinhFadeIn" = "Math.Sinh(n/total * (Math.PI/4))"
    "SinhFadeOut" = "Math.Sinh((1.0 - (n/total)) * (Math.PI/4))"    
}

foreach ($envelope in $envelopes.Keys) {
@"
    public static IEnumerable<double> $envelope (
        this int Length
    ) {
        if (Length == 0) { yield break; }
        double sign = Math.Abs(Length)/Length;
        double total = Math.Abs(Length);
        for (double n = 0; n < total; n++) {
            yield return (
                $($envelopes[$envelope])
            ) * sign;
        }        
    }

    public static IEnumerable<double> $envelope(
        this double frequency,
        double sampleRate = 44100.0
    ) {
        double step = sampleRate/frequency;
        double sign = Math.Abs(step)/step;
        
        double total = Math.Abs(step);
        for (double n = 0; n < total; n++) {
            yield return (
                $($envelopes[$envelope])
            ) * sign;
        }
    }

    public static IEnumerable<double> $envelope(
        this List<double> samples,
        double volume = (1 / (Math.PI * 2))
    ) {
        double n = 0;        
        double total = (double)samples.Count;
        
        foreach (double sample in samples) {
            yield return sample * ($((
                $($envelopes[$envelope])
            ))) * volume;
            n++;
        }
    }
"@
}



@"
    public static IEnumerable<double> Envelope(
        this List<double> samples,
        List<double> envelope = null,
        double volume = (1 / (Math.PI * 2))
    ) {
        if (envelope == null) {
            envelope = new List<double>();
            envelope.AddRange(FadeOut(samples.Count));
        }
        int n = 0;
        foreach (double sample in samples) {
            yield return sample * envelope[n % envelope.Count] * volume;
            n++;
        }        
    }

"@
return 