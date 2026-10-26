<#
.SYNOPSIS
    Wave Linq Trigonometry
.DESCRIPTION
    Generates the Wave Linq methods for Trigonometry.
.NOTES
    Each of these methods simply yields a stream of each `Math.$method`
.EXAMPLE
    [Wave.WaveLinq]::Sin([double[]](1..100))
#>

param()

foreach ($method in 'Asin', 'Acos', 'Atan', 'Sin', 'Cos', 'Tan') {
    "
    public static IEnumerable<double> $method (this IEnumerable<double> numbers) {
        foreach (double number in numbers) {
            yield return Math.$method(number);
        }
        yield break;
    }            
    "
}