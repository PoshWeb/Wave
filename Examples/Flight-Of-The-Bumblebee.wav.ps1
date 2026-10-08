enum NoteName {
    C  = 0
    Cs = 1
    D  = 2
    Ds = 3
    E  = 4
    F  = 5
    Fs = 6
    G  = 7
    Gs = 8
    A  = 9
    As = 10
    B  = 11
}

function Get-ChromaticRun {
	[Alias('NoteRun')]
	param(
		[Parameter(Mandatory)]
		[string]$From,

		[Parameter(Mandatory)]
		[string]$To
	)

	function ConvertTo-NoteNumber {
		param(
			[string]$Pitch
		)

		if ($Pitch -notmatch '^([A-Ga-g])([#b]?)(\d+)$') {
			throw "Invalid pitch name: $Pitch"
		}

		$letter = $Matches[1].ToUpper()
		$accidental = $Matches[2]
		$octave = [int]$Matches[3]

		$baseNote = [NoteName]$letter
		$noteValue = [int]$baseNote

		switch ($accidental) {
			'#' { $noteValue++ }
			'b' { $noteValue-- }
		}

		if ($noteValue -lt 0) {
			$noteValue += 12
			$octave--
		} elseif ($noteValue -gt 11) {
			$noteValue -= 12
			$octave++
		}

		(($octave + 1) * 12) + $noteValue
	}

	function ConvertFrom-NoteNumber {
		param(
			[int]$NoteNumber
		)

		$note = [NoteName]($NoteNumber % 12)
		$octave = [math]::Floor($NoteNumber / 12) - 1

		$noteName = $note.ToString() -replace 's$', '#'

		"$($noteName.ToLower())$octave"
	}

	$fromNumber = ConvertTo-NoteNumber $From
	$toNumber = ConvertTo-NoteNumber $To

	$step = if ($toNumber -ge $fromNumber) { 1 } else { -1 }

	$notes = for ($note = $fromNumber; ; $note += $step) {
		ConvertFrom-NoteNumber $note

		if ($note -eq $toNumber) {
			break
		}
	}

	$notes -join ' '
}

$BumblebeeTune = @(
	'𝅘𝅥𝅮'
	#Intro
	NoteRun -From E5 -To C#5
	NoteRun -From D5 -To B4
	NoteRun -From C5 -To C#4
	NoteRun -From D4 -To B3
	NoteRun -From C4 -To F3
    '𝅝' 
	'~'
	'𝅘𝅥𝅮'
	#Main Theme (Starts on the 5th)
	@(
		NoteRun -From E4 -To C4
		NoteRun -From F4 -To Eb4
		NoteRun -From E4 -To C#4
		NoteRun -From C4 -To D#4
	) * 2

	NoteRun -From E4 -To C#4
	NoteRun -From D4 -To B3
	NoteRun -From C4 -To F4
	'E4 Eb4'
	NoteRun -From E4 -To C#4
	NoteRun -From D4 -To B3
	NoteRun -From C4 -To E4
	NoteRun -From F#4 -To Ab4

	#Shift up to actual tonic
	@(
		NoteRun -From A4 -To F4
		NoteRun -From Bb4 -To Ab4
		NoteRun -From A4 -To F#4
		NoteRun -From F4 -To G#4
	) * 2
	NoteRun -From A4 -To F#4
	NoteRun -From G4 -To E4
	NoteRun -From F4 -To Bb4
	'A4 Ab4'
	NoteRun -From A4 -To F#4
	NoteRun -From G4 -To E4
	NoteRun -From F4 -To Bb4
	'A4 G#4 A4'
    '𝅝' 
	'~'
	#Middle Section
	'𝅘𝅥𝅮'
	@('A4 Bb4') * 4
    '𝅗𝅥' 
	'~'
	'𝅘𝅥𝅮'
	@('A4 Bb4 A4 G#4') * 4
	NoteRun -From A4 -To C#5
	NoteRun -From C5 -To A4
	NoteRun -From Bb4 -To C#5
	NoteRun -From C5 -To A4
    @('𝅗𝅥 ~')  * 3
	'𝅘𝅥𝅮'
	@('Eb5 D5 C#5 D5') * 2
    @('𝅗𝅥 ~')  * 2
	'𝅘𝅥𝅮'
	@('C#5 D5 D#5 D5') * 2
	@('D5 Eb5 D5 C#5') * 4
	@(
		NoteRun -From D5 -To F#5
		NoteRun -From F5 -To Eb5
	) * 2
	NoteRun -From D5 -To Bb4
	NoteRun -From Eb5 -To C#5
	NoteRun -From D5 -To B4
	NoteRun -From Bb4 -To C#5
	NoteRun -From D5 -To B4
	NoteRun -From C5 -To A4
	'Bb4 B4'
	('C5 C#5') * 2
	'D5 D#5'
	NoteRun -From E5 -To C#5
	NoteRun -From D5 -To B4
	NoteRun -From C5 -To F4
	('E4 F4 E4 D#4') * 8
	'E4'
    '𝅝' 
	'~'
	'𝅘𝅥'
	'E5 C5 A4 F4 A4 C5 E5'
    '𝅗𝅥' 
	'~'
    '𝅗𝅥' 
	'~'
	'𝅘𝅥𝅮'
	NoteRun -From E3 -To E5
	'𝅘𝅥'
	'~'
	#Recapitulation (8va)
	'𝅘𝅥𝅮'
	@(
		NoteRun -From E5 -To C5
		NoteRun -From F5 -To Eb5
		NoteRun -From E5 -To C#5
		NoteRun -From C5 -To D#5
	) * 2

	NoteRun -From E5 -To C#5
	NoteRun -From D5 -To B4
	NoteRun -From C5 -To F5
	'E5 Eb5'
	NoteRun -From E5 -To C#5
	NoteRun -From D5 -To B4
	NoteRun -From C5 -To E5
	NoteRun -From F#5 -To Ab5

	#Shift up to actual tonic
	@(
		NoteRun -From A5 -To F5
		NoteRun -From Bb5 -To Ab5
		NoteRun -From A5 -To F#5
		NoteRun -From F5 -To G#5
	) * 2
	NoteRun -From A5 -To F#5
	NoteRun -From G5 -To E5
	NoteRun -From F5 -To Bb5
	'A5 Ab5'
	NoteRun -From A5 -To F#5
	NoteRun -From F5 -To A5
	@('𝅘𝅥 ~') * 2
	#Coda
	'𝅘𝅥𝅮'
	@(
		NoteRun -From E5 -To C5
		NoteRun -From F5 -To Eb5
		NoteRun -From E5 -To C#5
		NoteRun -From C5 -To D#5
	) * 2
	'𝅘𝅥'
	'E5'
	'𝅘𝅥𝅮'
	NoteRun -From G#4 -To C#5
	NoteRun -From D5 -To B4
	NoteRun -From C5 -To A4
	NoteRun -From G#4 -To Eb5
	@('E5 F5 E5 D#5') * 2
	'𝅘𝅥'
	'E5'
	'𝅘𝅥𝅮'
	NoteRun -From G#4 -To C#5
	NoteRun -From D5 -To B4
	NoteRun -From C5 -To A4
	NoteRun -From G#4 -To Eb5
	'E5 F5 E5 D#5 E5'
	NoteRun -From F#5 -To G#5
	NoteRun -From A5 -To F#5
	NoteRun -From G5 -To E5
	NoteRun -From F5 -To Bb4
	NoteRun -From A4 -To F#4
	NoteRun -From G4 -To E4
	NoteRun -From F4 -To A3
	@('𝅝 ~') * 2
	'𝅘𝅥𝅮'
	#Final Run-Up
	NoteRun -From E3 -To E5
	NoteRun -From F#5 -To A5
)

wav bpm 100 volume 0.50 note $BumblebeeTune play
