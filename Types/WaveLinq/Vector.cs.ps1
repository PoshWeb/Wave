<#
.SYNOPSIS
    Wave Linq Vectoring
.DESCRIPTION
    Generates Wave Linq Vector methods.

    These provide fast vector operations on a large number of samples.
.NOTES
    
#>

param()

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

return