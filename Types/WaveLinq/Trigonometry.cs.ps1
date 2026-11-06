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

# The three base trigonmetric methods
$trigMethods = @(
    'Sin', 'Cos', 'Tan'
)

# Each has an arc method simply starts with an `A`
$trigMethods += @( $trigMethods -replace '^', 'A' )
# Each trig methods has a hyperbolic function as well, ending with an `h`
$trigMethods += @( $trigMethods -replace '$', 'h')

# Walk over each alphabetized method
foreach ($method in $trigMethods | Sort-Object) {
    "
    /// <summary>
    /// Computes the Math.${method} of a sets of numbers.
    /// </summary>
    /// <param name='numbers'>The set of numbers</param>
    /// <returns>The $method of each number.</returns>
    public static IEnumerable<double> $method (this IEnumerable<double> numbers) {
        foreach (double number in numbers) {
            yield return Math.$method(number);
        }
        yield break;
    }
    "
}