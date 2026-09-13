<#
.SYNOPSIS
    Gets the Wave Length
.DESCRIPTION
    Gets the length of the Wave.  
    
    This should be the length of the stream.
#>
$this.Position = 4
[IO.BinaryReader]::new($this).ReadUInt32() + 8