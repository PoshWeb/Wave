<#
.SYNOPSIS
    Gets Wave Metadata
.DESCRIPTION
    Gets Metadata about a Wave File.

    Wave files can include metadata in a LIST chunk

    Each piece of metadata is a 4-byte ASCII identifier,
    a 4-byte length, and a string.
    
    If the identifier contains `XML`,
    the string will be decoded as UTF-8 and cast to `[XML]`

    If the identifier does not contain `XML`,
    the string will be decoded as ASCII.
.NOTES    
    Each header must start at a WORD boundary, or two bytes.
    
    If the ASCII string had an odd number of characters, the next byte will be ignored.
#>
[OutputType([Collections.IDictionary])]
param()

# If we have no cached list
if (-not $this.'#list') {
    # read chunks.
    $null = $this.Chunk
    # Return if we still have no cached list
    if (-not $this.'#list') { return }
}


# Almost everything in metadata is encoded in ASCII
# (Wave file predate UTF-8 encoding by about a decade)

# We want to return metadata as a dictionary
$metadata = [Ordered]@{}

# Get our list bytes
$list = $this.'#list'

# The first four bytes of a list are always `INFO`,
# so walk over our list, starting at 4 and incrementing as we read.
for ($index = 4; $index -lt $list.Length; ) {
    # Get the ID
    $metaDataId = [Text.Encoding]::ASCII.GetString($list, $index, 4) 
    # and advance four bytes.
    $index +=4
    # Get the chunk length 
    $metadataLength = [BitConverter]::ToUInt32($list,$index)
    # and advance four bytes
    $index +=4

    # While _most_ content in LIST sections is ASCII,
    # the Broadcast Wave Standard allows a UTF-8 encoded XML.

    # Rather than special case this one scenario, 
    # we will presume anything with the letters `XML` in the key is UTF-8 XML.
    if ($metaDataId -match 'XML') {
        $metadata[$metaDataId] = [Text.Encoding]::UTF8.GetString($list, $index, $metadataLength)
        # If we can cast the value to XML
        if ($metadata[$metaDataId] -as [xml]) {
            # then return this metadata as XML
            $metadata[$metaDataId] = $metadata[$metaDataId] -as [xml]
        }
    } else {
        # Get the string
        $metadata[$metaDataId] = [Text.Encoding]::ASCII.GetString($list, $index, $metadataLength)
    }
    
    # and advance by the string length.
    $index += $metadataLength
    # If our index was odd
    if ($index % 2) {
        $index++ # advance one more byte.
    }
}

# Return our metadata.
return $metadata