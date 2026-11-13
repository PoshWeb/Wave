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
    'MathML' = 'MATH'
    'MusicXML' = 'MusicXML'
    'json' = 'json'
    'midi' = 'MIDI'
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
$null = $this.Seek($listStart, 'Begin')
# Then write the list
$writer.Write([Text.Encoding]::ASCII.GetBytes("LIST"))

filter ListItemBytes {
    $value = $_
    [Text.Encoding]::ASCII.GetBytes($shortKey)

    [byte[]]$ValueBytes = if (
        $shortKey -match 'xml' -or 
        $shortKey -match 'math' -or 
        $shortKey -match 'clix'
    ) {
        if ($value -is [xml]) {
            [Text.Encoding]::UTF8.GetBytes(
                $value.OuterXml
            )
        } else {
            [Text.Encoding]::UTF8.GetBytes("$($value)")
        }            
    }
    elseif ($shortKey -match 'json') {        
        [Text.Encoding]::Utf8.GetBytes(
            (ConvertTo-Json -InputObject $value -Depth 100)
        )
    }
    else {
        if ($value -is [DateTime]) {
            if ($key -eq 'ICRD') {
                [Text.Encoding]::ASCII.GetBytes("$(
                    ($value).ToString('yyyy-MM-dd')
                )")
            } else {
                [Text.Encoding]::ASCII.GetBytes($value.ToString('o'))
            }
        } else {
            # Get the bytes stored in the value
            [Text.Encoding]::ASCII.GetBytes("$($value)")
        }
    }

    [BitConverter]::GetBytes([uint32]$valueBytes.Length)
    $valueBytes
    if ($valueBytes.Length % 2) {
        [byte]0
    }    
}

# Collect our list data
[byte[]]$listData = @(
    # `LIST` chunks begin with the ASCII characters `INFO`.
    [Text.Encoding]::ASCII.GetBytes("INFO")
    # followed by a series of key-value pairs
    foreach ($key in $MetaData.Keys) {
        # If the metadata starts with punctuation, 
        # we do not want to save it.
        # This allows for temporary 
        # metadata that will not be persisted.
        if ($key -match '^\p{P}') {
            continue
        }
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
        
        $MetaData[$key] | ListItemBytes
    }
)
$writer.Write([uint32]$listData.Length)
$writer.Write($listData)

foreach ($after in $afterList) {
    $writer.Write([Text.Encoding]::ASCII.GetBytes($after.id))
    $writer.Write([uint32]$after.length)
    $writer.Write([byte[]]$after.data)
}

$null = $this.Seek(4, 'Begin')
# Then write our stream length, minus 8 bytes
$writer.Write([uint32]($this.Length - 8))

# and set our position back to the start.
$null = $this.Seek(0, 'Begin')

foreach ($prop in $this.psobject.properties) {
    if ($prop.Name -match '^#') {
        $prop.Value = $null
    }
}

return $this