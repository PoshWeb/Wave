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
$ClassName = 'Frequency',

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
    public Frequency() { this.Hertz = 0; }
"   
    "
    public Frequency(double hertz) { this.Hertz = hertz; }    
"

@"
    public Frequency(string hertz) {        
        string lowerHertz = hertz.ToLower();
        Match startsWithLetter = Regex.Match(lowerHertz,"^[a-g]");        
        if (startsWithLetter.Success) {
            Regex sharps = new Regex("[#♯]");
            char letter = startsWithLetter.Value[0];
            int distanceFromA = ((int)letter - (int)'a'); 
            lowerHertz = sharps.Replace(lowerHertz, "s");
            foreach (Frequency f in Frequency.Keyboard) {
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
                return Frequency.Letters[
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
            if (letterNumber == Frequency.Letters.Length) {
                // congratulations, it's a `C`
                return "C" + this.Octave.ToString();
            }
            
            // Otherwise get the letter at that index.
            return Frequency.Letters[letterNumber] + this.Octave.ToString();
        }
    }            
"@

@"

    public Frequency Flat {
        get {
            return new Frequency(this.Hertz * Math.Pow(2, -1.0/12));
        }
    }

    public Frequency Sharp {
        get {
            return new Frequency(this.Hertz / Math.Pow(2, -1.0/12));
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
    public static string[] Letters {
        get {
            return new string[] {"C","Cs","D","Ds","E","F","Fs","G","Gs","A","As","B"};
        }
    }

    public static List<Frequency> Keyboard {
        get {
            Frequency a0 = new Frequency(27.5);
            List<Frequency> keyboard = new List<Frequency>();
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
        ) -Body "{ return new Frequency(other);}"

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
                return new Frequency(0.0);
            }
            else {
                return new Frequency(1/other.TotalSeconds);
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
            if (other is Frequency) {
                b = ((Frequency)other).Hertz;
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
@'
        public bool Equals(double other) { return this.Hertz.Equals(other); }

        public override bool Equals(object other) {
            if (other == null) { return false; }
            if (other is Frequency) { return ((Frequency)other).Hertz == this.Hertz; }      
            if (other is double) { return (double)other == this.Hertz; }
            if (other is int) { return (double)(int)other == this.Hertz; }  
            if (other is uint) { return (double)(uint)other == this.Hertz; }
            return false;
        }
'@

        # Custom stringification
@'
        public override string ToString () { return this.Hertz.ToString() + "hz"; }
'@



@'                
        public override int GetHashCode() { return this.Hertz.GetHashCode(); }        
'@

        # Frequency Movement
@'    
        public Frequency Sharpen(double distance) {
            return new Frequency(this.Hertz / Math.Pow(2, ((distance * -1.0)/12)));
        }

        public Frequency Flatten(double distance) {
            return new Frequency(this.Hertz * Math.Pow(2, ((distance * -1.0)/12)));
        }
            
        public Frequency Shift(double octave = 0, double semitone = 0, double cent = 0) {
            double shifted = this.Hertz / Math.Pow(2, octave * -1.0);
            shifted /= Math.Pow(2, semitone * -1.0/12);
            shifted /= Math.Pow(2, cent * -1.0/1200);            
            return new Frequency(shifted);
        }

        public Frequency ShiftOctave(double distance) {
            return new Frequency(this.Hertz / Math.Pow(2, distance * -1.0));
        }

        public Frequency ShiftSemitone(double distance) {
            return new Frequency(this.Hertz / Math.Pow(2, ((distance * -1.0)/12)));
        }
            
        public Frequency ShiftCent(double distance) {
            return new Frequency(this.Hertz / Math.Pow(2, ((distance * -1.0)/1200)));
        }
'@


@"
    public IEnumerable<Frequency> Chords(IEnumerable<double> chords) {
        foreach (double chord in chords) {
            yield return new Frequency(this.Hertz * chord);
        }
    }
"@
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