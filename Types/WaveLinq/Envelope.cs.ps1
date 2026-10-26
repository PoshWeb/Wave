@"
    public static IEnumerable<double> FadeIn (
        this int Length
    ) {
        if (Length == 0) { yield break; }
        double absLength = Math.Abs(Length);
        for (double n = 0; n < absLength; n++) {
            yield return (
                (n / absLength)
            );
        }
        yield break;
    }

    public static IEnumerable<double> FadeOut (
        this int Length
    ) {
        if (Length == 0) { yield break; }
        double absLength = Math.Abs(Length);
        for (double n = 0; n < absLength; n++) {
            double fade = (1.0 - (n / absLength));            
            yield return fade;
        }
        yield break;
    }    
"@