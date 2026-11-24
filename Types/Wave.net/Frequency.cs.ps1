<#
.SYNOPSIS
    Wave Frequency Class Definition
.DESCRIPTION
    This defines the source code for very flexible frequency class.
.NOTES
    This outputs a single type definition, inside the namespace of our choosing.

    It inlines each of the parameters values in the desired order,
    and joins with double newlines.
#>
param(
# The name of the class
[string]
$ClassName = 'WaveFrequency',

# The namespace the class is in.
[string]
$Namespace = 'Wave',

# The namespaces we will use.
[string[]]
$Using = @(
    'System'
    'System.Collections.Generic'
    'System.Text.RegularExpressions'
),

# The class type (in case we suddenly want to make it a `struct` instead)
[string]
$ClassType = 'class',

# Any modifiers on the class.  By default the class will be public
[string[]]
$Modifier = 'public',

# Any constructors.
[string[]]$Constructor = @(
    "
    public $ClassName() { this.Hertz = 0; }
"   
    "
    public $ClassName(double hertz) { this.Hertz = hertz; }    
"

@"
    public $ClassName(string hertz) {        
        string lowerHertz = hertz.ToLower();
        Match startsWithLetter = Regex.Match(lowerHertz,"^[a-g]");        
        if (startsWithLetter.Success) {
            Regex sharps = new Regex("[#♯]");
            char letter = startsWithLetter.Value[0];
            int distanceFromA = ((int)letter - (int)'a'); 
            lowerHertz = sharps.Replace(lowerHertz, "s");
            foreach ($ClassName f in $ClassName.Keyboard) {
                if (lowerHertz == f.Letter.ToLower()) {
                    this.Hertz = f.Hertz;
                    return;
                }
            }
        }

        if (Regex.IsMatch(lowerHertz, "hz$")) {
            Regex dropLetters = new Regex("\\p{L}");
            string noLetters = dropLetters.Replace(hertz, String.Empty);
            double parsed;
            if (double.TryParse(noLetters, out parsed)) {
                this.Hertz = parsed;        
            }    
        }        
    }
"@
),

# Any properties
[string[]]$Property = @(    
@"    
    public double Hertz { get; set; }
"@

@"
    public double MidiNumber {
        get {                        
            double midiNumber = 69.0 + 12.0 * Math.Log(Math.Abs(this.Hertz) / 440,2);
            
            return midiNumber;            
        }
        set {
            if (value > 0) {
                this.Hertz = 440.0 * Math.Pow(2,((value - 69)/12));
            } else if (value < 0 ) {
                this.Hertz = -440.0 * Math.Pow(2,((Math.Abs(value) - 69)/12));
            }
        }
    }
"@

@"
    public string Letter {
        get {
            double midiNumber = this.MidiNumber;
            double remainder = (midiNumber - 12) % 12;
            if (midiNumber < 12 && midiNumber >= 0) {
                return $ClassName.Letters[
                    (int)Math.Round(midiNumber)
                ] + this.Octave.ToString();                                        
            }                            
                
            // C-1 is MIDI 0, so we wrap at this point
            if (midiNumber < 0) {
                remainder = (midiNumber % 12);
            }
                
            // If our remainder was negative, wrap
            if (remainder < 0) {
                remainder = 12 + remainder;
            }

            // At this point we should have an accurate remainder
            // and all we need to do is make it an index
            int letterNumber = (int)Math.Round(remainder);
            
            // If the index is our total
            if (letterNumber == $ClassName.Letters.Length) {
                // congratulations, it's a `C`
                return "C" + this.Octave.ToString();
            }
            
            // Otherwise get the letter at that index.
            return $ClassName.Letters[letterNumber] + this.Octave.ToString();
        }
    }            
"@

@"

    public $ClassName Flat {
        get {
            return new $ClassName(this.Hertz * Math.Pow(2, -1.0/12));
        }
    }

    public $ClassName Sharp {
        get {
            return new $ClassName(this.Hertz / Math.Pow(2, -1.0/12));
        }
    }
"@

@"
    public double Octave {
        get {
            return Math.Floor(
                Math.Log(
                    Math.Abs(this.Hertz), 2
                ) - 4.0
            );            
        }
    }
"@

@"
    public double ArcLength {
        get { return this.Hertz * Math.PI * 2; }
        set { this.Hertz = value / (Math.PI * 2); }
    }
"@

@"
    public IEnumerable<object> this[string input] {
        get {            
            foreach (var prop in this.GetType().GetProperties()) {
                if (! prop.CanRead) { continue; }
                if (String.Compare(prop.Name,"Item",true) == 0) { continue; }
                if (String.Compare(prop.Name, input, true) != 0) { continue; }

                object propertyValue = null;
                Exception exception = null;
                try {
                    propertyValue = prop.GetValue(this);
                } catch (Exception ex) {
                    exception = ex;
                }
                if (exception != null) {
                    yield return exception;
                }
                else if (propertyValue != null) {
                    yield return propertyValue;
                }            
            }
        }        
    }
"@


# Indexers
@"      
    public double this[double time] {
        get {   
            if (time == 0 || this.Hertz == 0) { return 0; }
            return Math.Sin(time * (Math.PI * 2)/this.Hertz);
        }
    }
             
    public double this[double time, double rate] {
        get {   
            if (time == 0 || rate == 0) { return 0; }                     
            return Math.Sin(time * ((this.Hertz * Math.PI * 2)/rate));
        }
    }    
        
    public double this[double time, double rate, double volume] {
        get {                                    
            return this[time, rate] * volume;
        }
    }
        
    public IEnumerable<double> this[TimeSpan duration, double rate] {
        get {            
            if (duration.TotalSeconds == 0) { yield break; }
            if (rate == 0) { yield break; }

            double sampleCount = Math.Round(duration.TotalSeconds * rate);

            double increment = Math.Abs(sampleCount)/sampleCount;            
            
            double f = (Math.PI * 2 * this.Hertz) / rate;            
            for (double sampleNumber = 0;
                Math.Abs(sampleNumber) <= Math.Abs(sampleCount);
                sampleNumber+=increment
            ) {    
                yield return Math.Sin(sampleNumber * f);
            }
        }
    }

    public IEnumerable<double> this[TimeSpan duration, double rate, double volume] {
        get {            
            foreach (double sample in this[duration, rate]) {
                yield return sample * volume;
            }
        }
    }

    public IEnumerable<double> this[TimeSpan duration, double rate, double volume, double velocity = 1] {
        get {
            double total = Math.Abs(duration.TotalSeconds * rate);
            if (total == 0) { yield break; }
            double c = 0;
            foreach (double sample in this[duration, rate]) {
                double envelope = 1.0 - (c * velocity/total);
                if (envelope < 0) { envelope = 0; }
                if (envelope > 1) { envelope = 1; }
                c++;
                yield return sample * volume * envelope;
            }
        }
    }

    public IEnumerable<double> this[TimeSpan duration, double rate, double volume, double[] envelope] {
        get {
            double total = Math.Abs(duration.TotalSeconds * rate);
            if (total == 0) { yield break; }
            int c = 0;        
            foreach (double sample in this[duration, rate]) {
                double e = 1;
                if (envelope != null && envelope.Length > 0) {
                    e = envelope[c % envelope.Length];
                }
                c++;
                yield return sample * volume * e;
            }
        }        
    }        
"@

$Scales = [Ordered]@{
    'Major' = 0, 2, 4, 5, 7, 9, 11, 12
	'MajorDescending' = 0, -1, -3, -5, -7, -8, -10, -12
    'Minor' = 0, 2, 3, 5, 7, 8, 10, 12
	'MinorDescending' = 0, -2, -4, -5, -7, -9, -10, -12
    'Augmented' = 0, 3, 4, 7, 8, 11, 12
	'AugmentedDescending' = 0, -1, -4, -5, -8, -9, -12
    'HarmonicMinor' = 0, 2, 3, 5, 7, 8, 11, 12
	'HarmonicMinorDescending' = 0, -1, -4, -5, -7, -9, -10, -12
    'MelodicMinor' = 0, 2, 3, 5, 7, 9, 11, 12
    'PentatonicMajor' = 0, 2, 4, 7, 9, 12
    'PentatonicMajorDescending' = 0, -3, -5, -8, -10, -12
    'PentatonicMinor' = 0, 3, 5, 7, 10, 12    
    'PentatonicMinorDescending' = 0, -2, -5, -7, -9, -12
    'PentatonicBlues' = 0, 3, 5, 6, 7, 10, 12
    'PentatonicBluesDescending' = 0, -2, -5, -6, -7, -9, -12
    'Octatonic' = 0, 2, 3, 5, 6, 8, 9, 11, 12
    'OctatonicDescending' = 0, -1, -3, -4, -6, -7, -9, -10, -12
    'WholeTone' = 0, 2, 4, 6, 8, 10, 12
    'WholeToneDescending' = 0, -2, -4, -6, -8, -10, -12
}

foreach ($scale in $scales.Keys) {
@"
    /// <summary>
    /// $scale scale generator
    /// </summary>    
    /// <returns>
    /// The $Scale scale of this frequency.    
    /// </returns> 
    public IList<$ClassName> $Scale {
        get {
            double[] distances = new double[] { $($scales[$scale] -join ', ')};
            return this.Transpose(distances);            
        }
    }
"@
}

@"
    public static string[] Letters {
        get {
            return new string[] {"C","Cs","D","Ds","E","F","Fs","G","Gs","A","As","B"};
        }
    }
            
    public static List<$ClassName> Keyboard {
        get {
            $ClassName a0 = new $ClassName(27.5);
            List<$ClassName> keyboard = new List<$ClassName>();
            for (double n = 0; n < 88; n++) { keyboard.Add(a0.Sharpen(n)); }
            return keyboard;
        }
    }
"@

),

# Any operators
[string[]]
$Operators = @(
    function operator {
        param([string]$Signature, [string]$Operator, [string[]]$Operands, [string]$Body)
        "$Signature operator $operator($($Operands -join ', ')) $body"
    }

    $StaticOperators = @('+','-','/','*', '==', '!=', '>', '>=', '<', '<=')

    foreach ($operator in $StaticOperators) {        
        $operatorFormat = @{Operator=$operator}
        if ($operator -in '==', '!=', '>', '>=', '<', '<=') {            
            
            $operatorFormat.Signature="public static bool"

            operator @operatorFormat -Operands @(
                "$ClassName left", "$ClassName right"
            ) -Body "{ return left.Hertz $operator right.Hertz; }"

            operator @operatorFormat -Operands @(
                "$ClassName left", "double right"
            ) -Body "{ return left.Hertz $operator right; }"
        }
        else {

            $operatorFormat.Signature = "public static $className"

            operator @operatorFormat -Operands @(
                "$ClassName left", "$ClassName right"
            ) -Body "{ return new $ClassName(left.Hertz $operator right.Hertz); }"
            
            operator @operatorFormat -Operands @(
                "$ClassName left", "double right"
            ) -Body "{ return new $ClassName(left.Hertz $operator right); }"

        }            
    }


        # Older versions of PowerShell don't support bitwise operators in this format
        # so we can only `-shr`/`-shl` a frequency on PowerShell Core.

        # (we can always use the `Sharpen` and `Flatten` methods to do this on Windows PowerShell)
        
        if ($psVersionTable.PSVersion.Major -ge 6) {
            $operatorFormat = @{Signature="public static $ClassName"}

            operator @operatorFormat -Operator '>>' -Operands @(
                "$ClassName left", "double right"
            ) -Body "{ return new $ClassName(left.Hertz / Math.Pow(2, (right * -1.0)/12)); }"

            operator @operatorFormat -Operator '>>' -Operands @(
                "$ClassName left", "$ClassName right"
            ) -Body "{ return new $ClassName(left.Hertz / Math.Pow(2, (right.Hertz * -1.0)/12)); }"

            operator @operatorFormat -Operator '<<' -Operands @(
                "$ClassName left", "double right"
            ) -Body "{ return new $ClassName(left.Hertz * Math.Pow(2, (right * -1.0)/12)); }"

            operator @operatorFormat -Operator '<<' -Operands @(
                "$ClassName left", "$ClassName right"
            ) -Body "{ return new $ClassName(left.Hertz * Math.Pow(2, (right.Hertz * -1.0)/12)); }"    
        }
        
        $implicit = @{Signature = "public static implicit"}
        $explicit = @{Signature = "public static explicit"}
        
        # Implicit and Explicit conversions to/from double and TimeSpan                
        operator @implicit -Operator "double" -Operands @(
            "$ClassName other"
        ) -Body "{ return other.Hertz; }"

        operator @explicit -Operator "$ClassName" -Operands @(
            "double other"
        ) -Body "{ return new $ClassName(other);}"

        operator @implicit -Operator 'TimeSpan' -Operands @(
            "$ClassName other"
        ) -Body "{
            if (other.Hertz == 0) {
                return TimeSpan.FromSeconds(0);
            }
            else {
                return TimeSpan.FromSeconds(1/other.Hertz);
            }
        }"

        operator @explicit -Operator "$ClassName" -Operands @(
            "TimeSpan other"
        ) -Body "{
            if (other.TotalSeconds == 0) {
                return new $ClassName(0.0);
            }
            else {
                return new $ClassName(1/other.TotalSeconds);
            }
        }"
),

[Collections.IDictionary]
$Interfaces = [Ordered]@{
    IComparable = "
        #region IComparable
        public Int32 CompareTo(object other) {
            double a = this.Hertz;
            double b = 0;
            if (other is $ClassName) {
                b = (($ClassName)other).Hertz;
            }            
            
            if (other is double) {
                b = (double)other;
            }
            if (a > b) {
                return 1;
            }
            if (a < b) {
                return -1;
            }
            return 0;
        }
        #endregion IComparable
    "    
},

[string[]]
$Members = @(

        # Overriding Equals
@"
        public bool Equals(double other) { return this.Hertz.Equals(other); }

        public override bool Equals(object other) {
            if (other == null) { return false; }
            if (other is $ClassName) { return (($ClassName)other).Hertz == this.Hertz; }      
            if (other is double) { return (double)other == this.Hertz; }
            if (other is int) { return (double)(int)other == this.Hertz; }  
            if (other is uint) { return (double)(uint)other == this.Hertz; }
            return false;
        }
"@

        # Custom stringification
@'
        public override string ToString () { return this.Hertz.ToString() + "hz"; }
'@

@'                
        public override int GetHashCode() { return this.Hertz.GetHashCode(); }        
'@

        # Frequency Movement
@"
    
        public $ClassName Sharpen(double distance) {
            return new $ClassName(this.Hertz / Math.Pow(2, ((distance * -1.0)/12)));
        }

        public $ClassName Flatten(double distance) {
            return new $ClassName(this.Hertz * Math.Pow(2, ((distance * -1.0)/12)));
        }
            
        public $ClassName Shift(double octave = 0, double semitone = 0, double cent = 0) {
            double shifted = this.Hertz / Math.Pow(2, octave * -1.0);
            shifted /= Math.Pow(2, semitone * -1.0/12);
            shifted /= Math.Pow(2, cent * -1.0/1200);            
            return new $ClassName(shifted);
        }

        public $ClassName ShiftOctave(double distance) {
            return new $ClassName(this.Hertz / Math.Pow(2, distance * -1.0));
        }

        public $ClassName ShiftSemitone(double distance) {
            return new $ClassName(this.Hertz / Math.Pow(2, ((distance * -1.0)/12)));
        }
            
        public $ClassName ShiftCent(double distance) {
            return new $ClassName(this.Hertz / Math.Pow(2, ((distance * -1.0)/1200)));
        }

        public $ClassName Detune(double distance) {
            return new $ClassName(this.Hertz / Math.Pow(2, ((distance * -1.0)/1200)));
        }
"@


@"
    public IEnumerable<$ClassName> Run(int steps = 0) {
        yield return this;
        if (steps > 0) {
            for (int step = 1; step <= steps; step++) {
                yield return this.Sharpen((double)step);
            }
        } else if (steps < 0) {
            for (int step = -1; step >= steps; step--) {
                yield return this.Sharpen((double)step);
            }
        }
    }
"@


@"
    public IEnumerable<$ClassName> StepComplex(int steps = 1, double octave = 0, double semitone = 2, double cent = 0) {
        $ClassName current = this;
        if (steps > 0) {            
            for (int step = 0; step <= steps; step++) {
                yield return current;
                current = current.Shift(octave, semitone, cent);
            }
        } else if (steps < 0) {
            for (int step = 0; step >= steps; step--) {
                yield return current;
                current = current.Shift(octave * -1, semitone * -1, cent * -1);
            }
        }
    }
"@

@"    
    public IList<$ClassName> Transpose(IEnumerable<double> distance) {
        List<$ClassName> transposed = new List<$ClassName>();
        foreach (double d in distance) {
            transposed.Add(this.Sharpen(d));
        }
        return transposed;
    }
"@

@"
    public IEnumerable<$ClassName> Chords(IEnumerable<double> chords) {
        foreach (double chord in chords) {
            yield return new $ClassName(this.Hertz * chord);
        }
    }
"@

$waveTypes = [Ordered]@{
    'Sine' = 'Math.Sin(t * f)'
    'Triangle' = 'Math.Asin(Math.Sin(t * f))'
    'Square' = 'Math.Sign(Math.Sin(t * f))'
    'Sawtooth' = 'Math.Atan(Math.Tan(t/2 * f))'
}

foreach ($waveType in $waveTypes.Keys) {
@"
    public IEnumerable<double> $waveType(TimeSpan duration, double rate) {
        if (duration.TotalSeconds == 0) { yield break; }
        if (rate == 0) { yield break; }

        double sampleCount = Math.Round(duration.TotalSeconds * rate);

        double increment = Math.Abs(sampleCount)/sampleCount;            
        
        double f = (Math.PI * 2 * this.Hertz) / rate;            
        for (double t = 0;
            Math.Abs(t) <= Math.Abs(sampleCount);
            t+=increment
        ) {
            yield return $($waveTypes[$waveType]);
        }
    }
        
    public IEnumerable<double> $waveType(TimeSpan duration, double rate, double volume) {
        foreach (double sample in this.$WaveType(duration, rate)) {
            yield return sample * volume;
        }        
    }

    public IEnumerable<double> $waveType(TimeSpan duration, double rate, double volume, double velocity) {
        double total = Math.Abs(duration.TotalSeconds * rate);
        if (total == 0) { yield break; }
        double c = 0;
        foreach (double sample in this.$WaveType(duration, rate)) {
            double envelope = 1.0 - (c * velocity/total);
            if (envelope < 0) { envelope = 0; }
            if (envelope > 1) { envelope = 1; }
            c++;
            yield return sample * volume * envelope;
        }
    }

    public IEnumerable<double> $waveType(TimeSpan duration, double rate, double volume, double[] envelope) {
        double total = Math.Abs(duration.TotalSeconds * rate);
        if (total == 0) { yield break; }
        int c = 0;        
        foreach (double sample in this.$WaveType(duration, rate)) {
            double e = 1;
            if (envelope != null && envelope.Length > 0) {
                e = envelope[c % envelope.Length];
            }
            c++;
            yield return sample * volume * e;
        }
    }
"@    
}

)
)




@(

if ($namespace) {
    "namespace $namespace {"
}

$using -replace '^', 'using ' -replace '\;?$', ';' -join [Environment]::NewLine

[Environment]::NewLine

"$($Modifier -join ' ') $ClassType $ClassName $(
    if ($Interfaces.Count) { ':' +($Interfaces.Keys -join ', ')}
) {"
    $Constructor
    $Property
    $operators
    $Interfaces.Values
    $Members
"}"

if ($namespace) {
    "}"
}

) -join ( [Environment]::NewLine * 2)

return
