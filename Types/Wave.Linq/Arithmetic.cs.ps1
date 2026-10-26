<#
.SYNOPSIS
    Wave Linq Arithmetic
.DESCRIPTION
    Generates Wave Linq Arithmetic methods.

    These provide fast arithmetic operations on a large number of samples.
.NOTES
    Generates `Add`, `Subtract`, `Multiply`, and `Divide`

    These four operations differ by one character,
    and are generated in a small loop.
#>

param()

foreach ($method in 'Add','Subtract','Multiply', 'Divide') {
    $operator = 
        switch ($method) {
            Multiply { '*' }
            Divide { '/' }
            Subtract { '-' }
            Add { '+' }
        }
    "
    /// <summary>
    /// ${method}s two sets of numbers and returns the result.
    /// </summary>
    /// <param name='numbers'>The first set of numbers</param>
    /// <param name='b'>The second of numbers</param>
    /// <returns>The $method of each number.</returns>    
    /// </exception>
    public static IEnumerable<double> $method (
        this IEnumerable<double> numbers, 
        double[] operand
    ) {
        int n = 0;
        foreach (double number in numbers) {
            double modify = operand[n % operand.Length];
            n++;
            yield return number $operator modify;
        }                
        yield break;
    }
    "
}