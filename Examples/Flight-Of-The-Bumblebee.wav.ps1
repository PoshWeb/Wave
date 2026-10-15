$BumblebeeTune = @(
	'𝅘𝅥𝅮'
	#Intro
	"E5..C#5"
	"D5..B4"
	"C5..C#4"
	"D4..B3"
	"C4..F3"
    '𝅝' 
	'~'
	'𝅘𝅥𝅮'
	#Main Theme (Starts on the 5th)
	@(
		"E4..C4"
		"F4..Eb4"
		"E4..C#4"
		"C4..D#4"
	) * 2

	"E4..C#4"
	"D4..B3"
	"C4..F4"
	'E4 Eb4'
	"E4..C#4"
	"D4..B3"
	"C4..E4"
	"F#4..Ab4"

	#Shift up to actual tonic
	@(
		"A4..F4"
		"Bb4..Ab4"
		"A4..F#4"
		"F4..G#4"
	) * 2
	"A4..F#4"
	"G4..E4"
	"F4..Bb4"
	'A4 Ab4'
	"A4..F#4"
	"G4..E4"
	"F4..Bb4"
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
	"A4..C#5"
	"C5..A4"
	"Bb4..C#5"
	"C5..A4"
    @('𝅗𝅥 ~')  * 3
	'𝅘𝅥𝅮'
	@('Eb5 D5 C#5 D5') * 2
    @('𝅗𝅥 ~')  * 2
	'𝅘𝅥𝅮'
	@('C#5 D5 D#5 D5') * 2
	@('D5 Eb5 D5 C#5') * 4
	@(
		"D5..F#5"
		"F5..Eb5"
	) * 2
	"D5..Bb4"
	"Eb5..C#5"
	"D5..B4"
	"Bb4..C#5"
	"D5..B4"
	"C5..A4"
	'Bb4 B4'
	('C5 C#5') * 2
	'D5 D#5'
	"E5..C#5"
	"D5..B4"
	"C5..F4"
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
	"E3..E5"
	'𝅘𝅥'
	'~'
	#Recapitulation (8va)
	'𝅘𝅥𝅮'
	@(
		"E5..C5"
		"F5..Eb5"
		"E5..C#5"
		"C5..D#5"
	) * 2

	"E5..C#5"
	"D5..B4"
	"C5..F5"
	'E5 Eb5'
	"E5..C#5"
	"D5..B4"
	"C5..E5"
	"F#5..Ab5"

	#Shift up to actual tonic
	@(
		"A5..F5"
		"Bb5..Ab5"
		"A5..F#5"
		"F5..G#5"
	) * 2
	"A5..F#5"
	"G5..E5"
	"F5..Bb5"
	'A5 Ab5'
	"A5..F#5"
	"F5..A5"
	@('𝅘𝅥 ~') * 2
	#Coda
	'𝅘𝅥𝅮'
	@(
		"E5..C5"
		"F5..Eb5"
		"E5..C#5"
		"C5..D#5"
	) * 2
	'𝅘𝅥'
	'E5'
	'𝅘𝅥𝅮'
	"G#4..C#5"
	"D5..B4"
	"C5..A4"
	"G#4..Eb5"
	@('E5 F5 E5 D#5') * 2
	'𝅘𝅥'
	'E5'
	'𝅘𝅥𝅮'
	"G#4..C#5"
	"D5..B4"
	"C5..A4"
	"G#4..Eb5"
	'E5 F5 E5 D#5 E5'
	"F#5..G#5"
	"A5..F#5"
	"G5..E5"
	"F5..Bb4"
	"A4..F#4"
	"G4..E4"
	"F4..A3"
	@('𝅝 ~') * 2
	'𝅘𝅥𝅮'
	#Final Run-Up
	"E3..E5"
	"F#5..A5"
)

wav bpm 100 volume 0.50 note $BumblebeeTune play
