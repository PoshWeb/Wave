$frequency = @($this.Frequency)[0]

if ($frequency -and $frequency.pstypenames -notcontains 'Frequency') {
    $frequency.pstypenames.Add('Frequency')        
}

$frequency.Letter