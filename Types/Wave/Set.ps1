<#
.SYNOPSIS
    Wave Set
.DESCRIPTION
    Sets one or more properties of a Wave and returns the Wave.
#>
param(
# The list of properties to set.
[CollectIons.IDictionary[]]
$Property = @([Ordered]@{})
)

# If there is no this, there is no setting this.
if (-not $this) { return }

# Walk over each dictionary
foreach ($dictionary in $property) {
    # go and each key in each dictionary
    foreach ($key in $dictionary.Keys) {
        # If it is not a property
        if (-not $this.psobject.properties[$key]) {
            # warn and continue.
            Write-Warning "$($key) is not a property"
            continue
        }
        # If it cannot be set
        if (-not $this.psobject.properties[$key].IsSettable) {
            # warn and continue.
            Write-Warning "$($key) is not writeable"
            continue
        }

        # Try to set it
        try {
            $this.$key = $dictionary[$key]
        } catch {
            # and if it fails, warn and continue.
            Write-Warning "Could not set $key : $_"
            continue
        }        
    }        
}

return $this
