<#
.SYNOPSIS
    WaveLinq Calculus
.DESCRIPTION
    Generates calculus extension methods.

    * `Delta`
    * `Angle`
    * `AreaUnderCurve`
#>
@"



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
                area += (1 * delta)/2.0;                            

                yield return area;
            }
            yield break;
        }
        
"@