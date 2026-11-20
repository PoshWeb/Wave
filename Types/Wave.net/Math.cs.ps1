<#
.SYNOPSIS
    Wave Math Class Definition
.DESCRIPTION
    This defines the source code for the `Wave.WaveMath` class.

    This class defines helpful mathematical functions that accept a set of input.
.NOTES
    This outputs a single type definition, inside the namespace of our choosing.
#>
param(
# The name of the class
[string]
$ClassName = 'WaveMath',

# The namespace the class is in.
[string]
$Namespace = 'Wave',

# The namespaces we will use.
[string[]]
$Using = @(
    'System'
    'System.Collections.Generic'
    'System.Numerics'
    'System.Text.RegularExpressions'    
),

# The class type (in case we suddenly want to make it a `struct` instead)
[string]
$ClassType = 'class',

# Any modifiers on the class.
# By default the class will be public
[string[]]
$Modifier = 'public static',

[Collections.IDictionary]
$Regions = [Ordered]@{
    Arithmetic = @(
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
        /// <param name='operand'>The second of numbers</param>
        /// <returns>The $method of each number.</returns>    
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

"
        /// <summary>
        /// Averages two sets of numbers and returns the result.
        /// </summary>
        /// <param name='numbers'>The first set of numbers</param>
        /// <param name='operand'>The second of numbers</param>
        /// <returns>The Average of each pair of numbers</returns>    
        public static IEnumerable<double> Average (
            this IEnumerable<double> numbers, 
            double[] operand
        ) {
            int n = 0;
            foreach (double number in numbers) {
                double modify = (number + operand[n % operand.Length])/2;
                n++;
                yield return modify;
            }
            yield break;
        }
"


    )
    Calculus = @"
        public static IEnumerable<double> Delta(this IEnumerable<double> numbers) {
            double last = 0;
            foreach (double number in numbers) {
                double delta = number - last;
                last = number;
                yield return delta;
            }
            yield break;
        }

        public static IEnumerable<double> Angle(this IEnumerable<double> numbers) {
            double last = 0;
            foreach (double number in numbers) {
                double delta = number - last;
                last = number;
                yield return Math.Atan2(1, delta);
            }
            yield break;
        }

        public static IEnumerable<double> AreaUnderCurve(this IEnumerable<double> numbers) {
            double last = 0;
            foreach (double number in numbers) {
                double delta = number - last;
                last = number;

                // We can determine the area under the curve by imagining
                // our space between the samples as a rectangle and a right trangle

                double area = 0;
                
                // The number is the height of our rectangle
                // it's width is always one, since each sample has an X of 1.

                area += number;

                // The delta is the height of our triangle
                // it's width is also always one, since each sample has an X of 1.
                // We need to account for direction

                double direction = 1;
                if (delta != 0) {
                    direction = delta/Math.Abs(delta);
                }

                area += (1 * delta)/2.0 * direction;

                yield return area;
            }
            yield break;
        }
"@
    Geometry = @(
$Formulas = [Ordered]@{
    Circumference = 'Math.PI * 2 * n'
    
    CircleArea = 'Math.PI * n * n'    
    SquareArea = 'n * n'
    Squared = 'n * n'

    CubeVolume = 'n * n'
    Cubed = 'n * n * n'
    CubeSurfaceArea = '6.0 * n * n'
    
    SphereVolume = '4.0/3.0 * Math.PI * n * n * n'
    SphereSurfaceArea = '4.0 * Math.PI * n * n'
            
    Radians = 'n * (Math.PI / 180)'
    Degrees = 'n * (180 / Math.PI)'
}


foreach ($formula in $formulas.Keys) {
@"

        /// <summary>
        /// $formula
        /// </summary>
        /// <param name='numbers'>A collection of numbers</param>
        /// <returns>The $formula for each number</returns>    
        public static IEnumerable<double> $Formula(this IEnumerable<double> numbers) {
            foreach (double n in numbers) {
                yield return $($Formulas[$formula]);
            }
            yield break;
        }
"@

}        
    )
    Trigonometry = @(

$trigMethods = @(
    # The three base trigonmetric methods    
    'Sin', 'Cos', 'Tan',
    # and their arc equivalents.
    'Asin', 'Acos', 'Atan'
)

# Each trig methods has a hyperbolic function as well, ending with an `h`
$trigMethods += @( $trigMethods -replace '$', 'h')

# Walk over each alphabetized method
foreach ($method in $trigMethods | Sort-Object) {
    # Not all of these methods will exist in all .NET Framework versions
    if (-not [Math]::$Method) { continue }
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

    )
    Vectors = @(
        $Vectors = @{
    2 = 'Vector2 vector = new Vector2((float)c, (float)(sample - lastSample));'
    3 = '
            double length = Math.Sqrt(
                (delta * delta) + 1
            );

            double direction = length/Math.Abs(length);
            
            Vector3 vector = new Vector3(
                (float)c,
                (float)delta,
                (float)(length * direction)
            );
    '
}


foreach ($d in 2,3) {
@"    
        public static IEnumerable<Vector$d> ToVector$d(
            this IEnumerable<double> samples
        ) {
            double lastSample = 0;
            double c = 0;
            foreach (double sample in samples) {
                double delta = sample - lastSample;
                $($Vectors[$d])
                c++;
                lastSample = sample;
                yield return vector;
            }

            yield break;
        }
"@

}
        
    )

})



@(

if ($namespace) {
    "namespace $namespace {"
}

$using -replace '^', 'using ' -replace '\;?$', ';' -join [Environment]::NewLine

[Environment]::NewLine

"$($Modifier -join ' ') $ClassType $ClassName {"    
    foreach ($region in $regions.Keys) {
        (' ' * 8) + "#region $region"
        $regions[$region]
        (' ' * 8) + "#endregion $region"
    }
"}"

if ($namespace) {
    "}"
}

) -join ( [Environment]::NewLine)