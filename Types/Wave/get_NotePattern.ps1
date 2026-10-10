<#
.SYNOPSIS
    Gets the Note Pattern
.DESCRIPTION
    Gets the regular expression used to match notes.
.NOTES
    This expression is derived from the Note Grammar.

    It combines every pattern defined in the grammar into a single `[Regex]`

    This pattern uses an atomic or `(?>a|b)` to ensure 
    only one grammar element at a time matches.

    We can view the captured information about each pattern as a state, 
    and view each match as a change in state.

    This allows us to parse notes using a finite state machine.
.LINK
    Wave.get_NoteGrammar
#>
[OutputType([Regex])]
param()
$grammar = $this.NoteGrammar

# Combine all patterns in the grammar
$patterns = @(
    foreach ($key in $grammar.Keys) {
        $pattern = # Each pattern is in a named capture group
            "(?<$key>",
            $(
            # If the grammar was a byte literal
            if ($grammar[$key] -is [byte[]]) {
                [Regex]::new(
                    [Regex]::Escape(
                        [Text.Encoding]::UTF8.GetString($grammar[$key])
                    )
                )
            }
            elseif ($grammar[$key] -isnot [Regex]) { 
                # make it a pattern that matches any of the supplied values
                [Regex]::new($(                
                    @(foreach ($const in $grammar[$key]) {
                        [Regex]::Escape("$const")
                    }) -join '|'
                ))
            } else {
                # Otherwise, stringify the pattern (this supercedes any options)
                "$($grammar[$key])"
            }
            ),')' -join [Environment]::NewLine

        # Try to create a new pattern
        try {
            [Regex]::new($pattern, 'IgnoreCase,IgnorePatternWhitespace')
        } catch {
            # If that fails, capture the exception
            $ex = $_
            # PowerShell generally does not show exceptions on a property get.
            # However, it can return an error explicitly
            try {
                # So throw an exception indicating which pattern failed
                throw "$key has an invalid $pattern : $ex"
            } catch {
                # and then return that exception.
                return $_
            }
            
        }
    }
)

# If all of the patterns were valid, combine them into an atomic or.
$combinedPattern = "(?>
$(
    # Join each of the patterns by an or `|`
    # surrounded by two newlines
    # (for readability of an incredibly long regular expression)
    $patterns -join (        
        ([Environment]::NewLine * 2) + '|' + ([Environment]::NewLine * 2)
    )
)
)"

# Try to create a new pattern.
# Always ignore case and pattern whitespace, 
# and set a timeout of a second.
try {
    [Regex]::new($combinedPattern, 'IgnoreCase,IgnorePatternWhitespace','00:00:01')
} catch {
    return $_
}

