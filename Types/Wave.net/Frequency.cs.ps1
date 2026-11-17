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
        if (Regex.IsMatch(lowerHertz,"^[a-g]")) {
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
            double direction = 1.0;
            if (this.Hertz == 0) {
                direction = 0;
            } else if (this.Hertz < 1) {
                direction = -1.0;
            }            
            
            double midiNumber = 69.0 + 12.0 * direction * Math.Log(Math.Abs(this.Hertz) / 440,2);
            if (Math.Abs(midiNumber) >= 21) {
                return midiNumber;
            }
            return 0;
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
            double absMidi = Math.Abs(this.MidiNumber);
            if (this.MidiNumber < 21) { return String.Empty;}
            double remainder = (absMidi - 12) % 12;                
            return Frequency.Letters[
                (int)Math.Round(
                    (remainder * Frequency.Letters.Length)/Frequency.Letters.Length
                )
            ] + this.Octave.ToString();
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
            if (this.MidiNumber < 21) { return 0; }                
            double octave = Math.Floor((this.MidiNumber - 12) / 12);
            return octave;
        }                
    }
"@

@"
    public double Circumference {
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
            for (double n = 0; n < 88; n++) {
                keyboard.Add(a0.Sharpen(n)); 
            }
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
    if ($operator -in '==', '!=', '>', '>=', '<', '<=') {
        operator -Signature "public static bool" -Operator $operator -Operands @(
            "$ClassName left", "$ClassName right"
        ) -Body "{ return left.Hertz $operator right.Hertz; }"

        operator -Signature "public static bool" -Operator $operator -Operands @(
            "$ClassName left", "double right"
        ) -Body "{ return left.Hertz $operator right; }"
    }     
    else {
        operator -Signature "public static $className" -Operator $operator -Operands @(
            "$ClassName left", "$ClassName right"
        ) -Body "{ return new $ClassName(left.Hertz $operator right.Hertz); }"
        
        operator -Signature "public static $className" -Operator $operator -Operands @(
            "$ClassName left", "double right"
        ) -Body "{ return new $ClassName(left.Hertz $operator right); }"
    }
        
}


        # Older versions of PowerShell don't support bitwise operators in this format
        # so we can only `-shr`/`-shl` a frequency on PowerShell Core.

        # (we can always use the `Sharpen` and `Flatten` methods to do this on Windows PowerShell)
        
        if ($psVersionTable.PSVersion.Major -ge 6) {
            operator -Signature "public static $ClassName" -Operator '>>' -Operands @(
                "$ClassName left", "double right"
            ) -Body "{ return new $ClassName(left.Hertz / Math.Pow(2, (right * -1.0)/12)); }"

            operator -Signature "public static $ClassName" -Operator '>>' -Operands @(
                "$ClassName left", "$ClassName right"
            ) -Body "{ return new $ClassName(left.Hertz / Math.Pow(2, (right.Hertz * -1.0)/12)); }"

            operator -Signature "public static $ClassName" -Operator '<<' -Operands @(
                "$ClassName left", "double right"
            ) -Body "{ return new $ClassName(left.Hertz * Math.Pow(2, (right * -1.0)/12)); }"

            operator -Signature "public static $ClassName" -Operator '<<' -Operands @(
                "$ClassName left", "$ClassName right"
            ) -Body "{ return new $ClassName(left.Hertz * Math.Pow(2, (right.Hertz * -1.0)/12)); }"
    
        }
        
        # Implicit and Explicit conversions to/from double and TimeSpan
        operator -Signature "public static implicit" -Operator 'double' -Operands @(
            "$ClassName other"
        ) -Body "{ return other.Hertz; }"

        operator -Signature "public static explicit" -Operator "$ClassName" -Operands @(
            "double other"
        ) -Body "{ return new Frequency(other);}"

        operator -Signature "public static implicit" -Operator 'TimeSpan' -Operands @(
            "$ClassName other"
        ) -Body "{
            if (other.Hertz == 0) {
                return TimeSpan.FromSeconds(0);
            }
            else {
                return TimeSpan.FromSeconds(1/other.Hertz);
            }
        }"

        operator -Signature "public static explicit" -Operator "$ClassName" -Operands @(
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

    IConvertible = @"
        #region IConvertible
        public TypeCode GetTypeCode () { return TypeCode.Double; }
        public bool ToBoolean ( IFormatProvider provider = null) {
            return this.Hertz == 0;
        }
        public char ToChar ( IFormatProvider provider = null) {
            return char.MinValue;
        }
        public SByte ToSByte ( IFormatProvider provider = null) {
            return 0; 
        }
        public byte ToByte ( IFormatProvider provider = null) {            
            return 0;
        }
        public Int16 ToInt16 ( IFormatProvider provider = null) {
            return 0;
        }
        public UInt16 ToUInt16 ( IFormatProvider provider = null) {
            return 0;
        }
        public Int32 ToInt32 ( IFormatProvider provider = null) {
            return 0;
        }
        public UInt32 ToUInt32 ( IFormatProvider provider = null) {
            return 0;
        }
        public Int64 ToInt64 ( IFormatProvider provider = null) {
            return 0;
        }
        public UInt64 ToUInt64 ( IFormatProvider provider = null) {
            return 0;
        }
        public Single ToSingle ( IFormatProvider provider = null) {
            return (float)this.Hertz;
        }
        public Double ToDouble ( IFormatProvider provider = null) {
            return this.Hertz;
        }
        public Decimal ToDecimal ( IFormatProvider provider = null) {
            return (Decimal)this.Hertz;
        }
        public DateTime ToDateTime ( IFormatProvider provider = null) {
            return DateTime.MinValue.AddSeconds(1.0/this.Hertz);
        }
        public string ToString ( IFormatProvider provider = null) {
            return this.Hertz.ToString() + "hz";
        }        

        public Object ToType ( Type conversionType ,  IFormatProvider provider ) {            
            return null;
        }
        #endregion IConvertible
"@
},

[string[]]
$Members = @(
@'
        public override string ToString () {
            return this.Hertz.ToString() + "hz";
        }        

        public override int GetHashCode() {
            return this.Hertz.GetHashCode();
        }

        public override bool Equals(object other) {
            if (other == null) { return false; }
            if (other is Frequency) { return ((Frequency)other).Hertz == this.Hertz; }      
            if (other is double) { return (double)other == this.Hertz; }
            if (other is int) { return (double)(int)other == this.Hertz; }  
            if (other is uint) { return (double)(uint)other == this.Hertz; }
            return false;
        }

        public bool Equals(double other) {
            return this.Hertz.Equals(other);
        }

        public Frequency Sharpen(double distance) {
            return new Frequency(this.Hertz / Math.Pow(2, ((distance * -1.0)/12)));
        }

        public Frequency Flatten(double distance) {
            return new Frequency(this.Hertz * Math.Pow(2, ((distance * -1.0)/12)));
        }                    
'@
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