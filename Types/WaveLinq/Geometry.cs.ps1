<#
.SYNOPSIS
    WaveLinq Geometry
.DESCRIPTION
    Generates the Geometric calculations in WaveLinq

    Includes:

    * Circumference
    * CircleArea
    * SquareArea/Squared
    * CubeVolume/Cubed
    * CubeSurfaceArea
    * SphereVolume
    * SphereSurfaceArea  
    * Radians
    * Degrees

    Each operation applies to an enumerable of numbers.
#>

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