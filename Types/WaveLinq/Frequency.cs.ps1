<#
.SYNOPSIS
    Frequency Methods
.DESCRIPTION
    Generates Frequency Methods.
    
    We transform frequencies often in fairly predictable ways.

    This generates the WaveLinq methods for common frequency operations, including:

    * `ToCycle`
    * `FromCycle`
    * `ToMidi`
    * `FromMidi`
    * `Sharpen`
    * `Flatten`    
#>

$Conversions = [Ordered]@{
    'ToMidi' = '69.0 + 12.0 * Math.Log(frequency / 440.0, 2)'
    'FromMidi' = '440.0 * Math.Pow(2, (frequency - 69.0) / 12 )'
}

$Movements = [Ordered]@{
    'Sharpen' = 'frequency / Math.Pow(2, (distance * -1.0) / 12)'
    'Flatten' = 'frequency * Math.Pow(2, (distance * -1.0) / 12)'
}

foreach ($conversion in $conversions.Keys) {
@"
        public static IEnumerable<double> $($conversion)(this IEnumerable<double> frequencies) {
            foreach (double frequency in frequencies) {
                yield return $($conversions[$conversion]);
            }
        }
"@
}

foreach ($movement in $movements.Keys) {
@"
        public static IEnumerable<double> $($movement)(this IEnumerable<double> frequencies, IEnumerable<double> distances) {
            foreach (double frequency in frequencies) {
                foreach (double distance in distances) {
                    yield return $($movements[$movement]);
                }
            }
        }
"@
}

@"
        public static IEnumerable<double> ToCycle(this IEnumerable<double> frequencies, IEnumerable<double> cycles) {
            foreach (double frequency in frequencies) {
                foreach (double cycle in cycles) {
                    yield return (Math.PI * 2 * frequency / cycle);
                }
            }
        }

        public static IEnumerable<double> FromCycle(this IEnumerable<double> frequencies, IEnumerable<double> cycles) {
            foreach (double frequency in frequencies) {
                foreach (double cycle in cycles) {
                    yield return (frequency * cycle) / (Math.PI * 2);
                }
            }
        }
"@