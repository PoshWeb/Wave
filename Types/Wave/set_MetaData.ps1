<#
.SYNOPSIS
    Sets Wave Metadata
.DESCRIPTION
    Sets Metadata about a Wave File.

    Wave files can include metadata in a LIST chunk

    Each piece of metadata is a 4-byte ASCII identifier,
    a 4-byte length, and an ASCII string.
.NOTES    
    Each header must start at a WORD boundary, or two bytes.
    
    If the ASCII string had an odd number of characters, the next byte will be ignored.
#>
param([Collections.IDictionary]$MetaData)

$shortNames = [Ordered]@{
    "ArchiveLocation" = 'IARL'
    "Artist" = 'IART'
    'BPM' = 'TBPM'
    'BeatsPerMinute' = 'TBPM'
    "Commissioned" = 'ICMS'
    "Comment" ='ICMT'
    "Comments" ='ICMT'
    "Copyright" = 'ICOP'
    "CreationDate"= 'ICRD'
    "Engineer"= 'IENG'
    "Genre"='IGNR'
    "Tag" = "IKEY"
    "Tags" = "IKEY"
    "Keyword"="IKEY"
    "Keywords"='IKEY'
    "Medium"='IMED'
    "Title"='INAM'
    'Album' = 'IPRD'
    "Product"= 'IPRD' 
    "TrackNumber"= 'IPRT'
    "Subject"= 'ISBJ'
    "Software" = 'ISFT'
    "Source"= 'ISRC'
    "SourceForm" =  'ISRF'
    "Technician" = 'ITCH'    
}

# https://mediaarea.net/BWFMetaEdit/listinfo

# Start off by refreshing out chunk list
$this | Add-Member NoteProperty '#Chunk' $null -Force
$chunks = $this.Chunk

# We will need to locate the list start if we have one
$listStart = 0 

# Walk over each chunk
$afterList = foreach ($chunk in $chunks) {
    # we will put the data into the first LIST chunk we see
    if ($chunk.id -eq 'LIST') {
        $listStart = $chunk.start
    }
    # and we will keep track of all chunks after this location
    elseif ($listStart) {
        $chunk
    }
}

# If we do not have a LIST
if (-not $listStart) {
    # Put it before the last chunk (often `data`)
    $listStart = $chunks[-1].start
    $afterList = @($chunks[-1])
}

# Create a writer
$writer = [IO.BinaryWriter]::new($this)
# and seek to the list start
$this.Position = $listStart
# Then write the list
$writer.Write([Text.Encoding]::ASCII.GetBytes("LIST"))

# Collect our list data
[byte[]]$listData = @(
    # `LIST` chunks begin with the ASCII characters `INFO`.
    [Text.Encoding]::ASCII.GetBytes("INFO")
    # followed by a series of key-value pairs
    foreach ($key in $MetaData.Keys) {
        # Each key can only be four ASCII characters.
        $shortKey = 
            # If the key was longer than four characters
            if ($shortNames[$key]) {
                $shortNames[$key]
            }
            elseif ("$key".Length -gt 4) {
                # take the first four characters
                "$key".Substring(0, 4)
            } else {
                # otherwise, pad right with spaces.
                "$key".PadRight(4, ' ')
            }
                    
        [Text.Encoding]::ASCII.GetBytes($shortKey)
        
        [byte[]]$valueBytes = if ($shortKey -match 'xml') {
            if ($MetaData[$key] -is [xml]) {
                [Text.Encoding]::UTF8.GetBytes(
                    $MetaData[$key].OuterXml
                )
            } else {
                [Text.Encoding]::UTF8.GetBytes("$($MetaData[$key])")
            }            
        } else {
            if ($MetaData[$key] -is [DateTime]) {
                [Text.Encoding]::ASCII.GetBytes("$(
                    ($MetaData[$key]).ToString('yyyy-MM-dd')
                )")
            } else {
                # Get the bytes stored in the value
                [Text.Encoding]::ASCII.GetBytes("$($MetaData[$key])")
            }
        }
        
        [BitConverter]::GetBytes([uint32]$valueBytes.Length)
        $valueBytes
        if ($valueBytes.Length % 2) {
            [byte]0
        }
    }
)
$writer.Write([uint32]$listData.Length)
$writer.Write($listData)

foreach ($after in $afterList) {
    $writer.Write([Text.Encoding]::ASCII.GetBytes($after.id))
    $writer.Write([uint32]$after.length)
    $writer.Write([byte[]]$after.data)
}

$this.Position = 4
# Then write our stream length, minus 8 bytes
$writer.Write([uint32]($this.Length - 8))

# and set our position back to the start.
$this.Position = 0

foreach ($prop in $this.psobject.properties) {
    if ($prop.Name -match '^#') {
        $prop.Value = $null
    }
}

return $this

# Everything in metadata is encoded in ASCII
# (Wave file predate UTF-8 encoding by about a decade)

# We want to return metadata as a dictionary
$metadata = [Ordered]@{}

# Get our list bytes
$list = $this.'#list'

# Walk over our list, starting at 4 and incrementing as we read 
for ($index = 4; $index -lt $list.Length; ) {
    # Get the ID
    $metaDataId = [Text.Encoding]::ASCII.GetString($list, $index, 4) 
    # and advance four bytes.
    $index +=4
    # Get the chunk length 
    $metadataLength = [BitConverter]::ToUInt32($list,$index)
    # and advance four bytes
    $index +=4
    # Get the string
    $metadata[$metaDataId] = [Text.Encoding]::ASCII.GetString($list, $index, $metadataLength)
    # and advance by the string length.
    $index += $metadataLength
    # If our index was odd
    if ($index % 2) {
        $index++ # advance one more byte.
    }
}


# Return our metadata.
return $metadata

