<#
.SYNOPSIS
    Wave Linq Encoders
.DESCRIPTION
    Generates the source code for encoding Waves.
.NOTES
    Each Wave encoding varies mildly in how it iterates over samples.

    Approaching this problem with a bit of metaprogramming saves us
    from repeating ourselves.
#>
$encoders = [Ordered]@{
    Byte = '(byte)Math.Floor(127 + s * 127)'
    Int16 = 'BitConverter.GetBytes((Int16)Math.Round(sample * Int16.MaxValue))'
    Int32 = 'BitConverter.GetBytes((Int32)Math.Round(sample * Int32.MaxValue))'
    Float = 'BitConverter.GetBytes((float)sample)'
}

foreach ($encoder in $encoders.Keys) {
@"
    public static IEnumerable<byte> Encode$Encoder (
        this IEnumerable<double> samples
    ) {
        if (samples == null) { yield break; }
        foreach (double sample in samples) {
            double s = sample;$(
            if ($encoder -ne 'Float') {
            "
            if (s > 1) { s = 1; }
            if (s < -1) { s = -1; }
            "
            }
            )
            $(
            if ($encoder -eq 'Byte') {
                "yield return $($encoders[$encoder]);"
            } else {
                "
                byte[] bytes = $($encoders[$encoder]);
                foreach (byte encoded in bytes) {
                    yield return encoded;
                }
                "
            }
            )            

        }
        yield break;        
    }
"@

}