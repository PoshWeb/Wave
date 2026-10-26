<#
.SYNOPSIS
    Wave Linq Decoders 
.DESCRIPTION
    Generates the source for WaveLinq Decoders.

    * `DecodeByte` (fixed 8-bit audio)
    * `DecodateInt16` (fixed 16-bit audio)
    * `DecodateInt32` (fixed 32-bit audio)
    * `DecodeFloat` (floating point 32-bit audio)
#>
param()
@"
    public static IEnumerable<double> DecodeByte (
        this byte[] samples
    ) {
        if (samples == null) { yield break; }
        foreach (byte sample in samples) {
            yield return ( ((double)sample)/255.0 ) - 0.5;
        }
        
        yield break;        
    }

    public static IEnumerable<double> DecodeInt16 (
        this byte[] samples
    ) {
        if (samples == null) { yield break; }
        for (int n = 0; n < samples.Length; n += 2) {
            Int16 iSample = BitConverter.ToInt16(samples, n);
            yield return ((double)iSample/Int16.MaxValue);
        }        
        
        yield break;        
    }

    public static IEnumerable<double> DecodeInt32 (
        this byte[] samples
    ) {
        if (samples == null) { yield break; }
        for (int n = 0; n < samples.Length; n += 4) {
            Int32 iSample = BitConverter.ToInt32(samples, n);
            yield return ((double)iSample/Int32.MaxValue);
        }        
        
        yield break;        
    }

    public static IEnumerable<double> DecodeFloat (
        this byte[] samples
    ) {
        if (samples == null) { yield break; }
        for (int n = 0; n < samples.Length; n += 4) {
            float iSample = BitConverter.ToSingle(samples, n);
            yield return ((double)iSample);
        }        
        
        yield break;        
    }
"@
