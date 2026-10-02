<#
.SYNOPSIS
    Gets Wave Note Grammar
.DESCRIPTION
    Wave notes are a musical domain specific language.

    Defining a Grammar streamlines how we can work with them.
.NOTES
    ### Grammar Format

    The Grammar is defined in a simple primal format:

    It is an `[Ordered]` dictionary.

    The order defines the order of precedence.
    
    Each key is the name of an instruction.

    Each value is one or more literal strings or `[Regex]`

    The grammar is combined into a single regular expression,
    which is available in `.NotePattern`

    ### Grammar Maturity

    This Grammar is in currently in flux, 
    and should not be viewed as final or fully matured.

    Certain elements specified in the grammar are not yet supported:

    * `<>` (Open/Close Phrase) support is not yet implemented
    * `[]` (Open/Close Divide) only supports some partial syntax
    * `𝆱𝆲` (GlissandoUp/Down) are not yet implemented
    * `𝆒𝆓` (Crescendo/Decrescendo) are not yet implemented
    
#>

[Ordered]@{
    OpenPhrase = '<'
    ClosePhrase = '>'
    OpenDivide = '['
    CloseDivide = ']'    
    UpTempo = '++'
    DownTempo = '--'
    Time1_1 = '𝅝'
    Time1_2 = '𝅗𝅥'
    Time1_4 = '𝅘𝅥'
    Time1_8 = '𝅘𝅥𝅮'
    Time1_16 = '𝅘𝅥𝅯'
    Time1_32 = '𝅘𝅥𝅰'
    Time1_64 = '𝅘𝅥𝅲'
    Time1_128 = '𝅘𝅥𝅲'
    GlissandoUp = '𝆱'
    GlissandoDown = '𝆲'
    Crescendo = '𝆒'
    Decrescendo = '𝆓'
    Rest1_1 = '𝄻'
    Rest1_2 = '𝄼'
    Rest1_4 = '𝄽'
    Rest1_8 = '𝄾'
    Rest1_16 = '𝄿'
    Rest1_32 = '𝅀'
    Rest1_64 = '𝅁'
    Rest1_128 = '𝅂'    
    Multiply = [Regex]::new('\*(?<scale>[\d\.]+)')
    Divide = [Regex]::New('/(?<scale>[\d\.]+)')
    Repeat = [Regex]::New('!(?<scale>[\d+])')
    DECPS = [regex]::new('\e\[(?<volume>[0-7]);(?<duration>\d+);(?:(?<decnote>\d+);?){1,},~')
    Emoji = [Regex]::new("[\p{IsHighSurrogates}\p{IsLowSurrogates}\p{IsVariationSelectors}\p{IsCombiningHalfMarks}]+")
    MidiNote = [Regex]::New('m(?:idi)?\s{0,}(?<midiNumber>[\d\.]+)','IgnoreCase')
    AtTime = [Regex]::new('\@(?<scale>[\d\.]+)')
    Rest = [Regex]::new('
        (?>
            ~|            # Strudel notation            
            rest|silence| # Common english                                     
            [xz]|         # ABC notation
            ø             # Notemoji notation
        )
    ','IgnoreCase,IgnorePatternWhitespace')
    Beep = [Regex]::new(
        '
        Beep                   # Beep
        \s{0,}                 # Followed by optional whitespace
        \p{Ps}?                # Optional starting punctuation
        (?<frequency>[\d\.]+)  # Frequency
        \s{0,}                 # Optional whitespace
        \p{P}                  # Intermedia punctuation
        \s{0,}                 # Optional whitespace
        (?<duration>[\d\.]+)   # Duration
        \s{0,}                 # Optional whitespace
        \p{Pe}                 # Ending punctuation
        ',
        'IgnoreCase,IgnorePatternWhitespace'
    )
    <#ExactFrequency = [Regex]::new(
        '(?<frequency>[\d\.]+)(?<scale>(?>hz|㎐|㎑|㎒|㎓))'
    )#>
    Sleep = [Regex]::new(
        '
        Sleep                  # Sleep
        \s{0,}                 # Followed by optional whitespace
        \p{Ps}?                # Optional starting punctuation
        \s{0,}                 # Optional whitespace
        (?<duration>[\d\.]+)   # Duration
        \s{0,}                 # Optional whitespace        
        \p{Pe}?                # Optional ending punctuation',
        'IgnoreCase,IgnorePatternWhitespace'
    )
    LetterNote = [Regex]::new('    
    (?<pitch>
        (?>
            (?<flat>[b\u266d_])
            |
            (?<sharp>[\#\u266f\^])
        )
    )?
    (?<letter>[a-g]) # a letter between a and g
    (?: 
        # Then an optional flat/sharp alter
        # and a number
        (?>
            # If it is a `b` flat, 
            # it has to be followed by an octave.
            (?<flat>b)
                (?<octave>[1-8])
            |
            # If it is a notemoji flat or underscore
            (?<flat>[\u266d_])
                # the octave is optional
                (?<octave>[1-8])?
            |
            # If it is a notemoji sharp, pound sign, or caret
            (?<sharp>[\#\u266f\^])
                # the octave is optional
                (?<octave>[1-8])?
            |
            # If there was no sharp or flat, the octave can still be present
            (?<octave>[1-8])
        )        
    )?
     # an optional octave
    ', 'IgnoreCase, IgnorePatternWhitespace'        
    )
    Decimal = [Regex]::new(
        '
(?<IsNegative>\-)?                # It might be start with a -
(?:(?>                            # Then it can be either: 
    (?<Characteristic>\d+)        # One or more digits (the Characteristic)
    (?:\.(?<Mantissa>\d+)){0,1}   # followed by a period and one or more digits (the Mantissa)
    |                             # Or it can be
    (?:\.(?<Mantissa>\d+))        # just a Mantissa      
))
(?:
    E
    (?<Exponent>
        [+-]\d+
    )
)?
    '        
    )
}
