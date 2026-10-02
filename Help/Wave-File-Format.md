# What is a Wave?

A Wave file is simple, uncompressed audio.

A wave is a series of samples representing the amplitude at that moment in time.

How many samples?  Whatever our "sample rate" is.

If we have a sample rate of 44100,
that's 44100 samples per channel per second.

44100 measurements of loudness.

## Wave Encoding

Wave are a trusty old standard.  

It was released by Microsoft in August 1991.

They are as compact as they can be for a lossless audio file format.

They contain a minimal header and then the data of the wave.

### RIFFing on WAVEs

A Wave File is a [RIFF file](https://en.wikipedia.org/wiki/Resource_Interchange_File_Format).

It starts with `RIFF`, followed by a `[uint32]` size
minus the length until now (-8).

After that RIFF files have a four letter ID,
which is `WAVE`.

Everything from here on out is `RIFF` chunk, which is:

* An ASCII four letter ID
* A `[uint32]` containing the chunk length
* The data in the chunk

Waves require at least two chunks:

* `fmt ` describes the wave format (the space is important)
* `data` contains the wave data

## Wave Format Header

There's not too much format (only 16 bytes).

It only contains 6 pieces of information, and two of them are calculated.

|Field|Type|Range|Description|
|-|-|-|
|AudioFormat|`[uint16]`|0..1|The Audio Format (1 for fixed point, 3 for float)|
|Channel Count|`[uint16]`|2..3|The number of audio channels|
|Sample Rate|`[uint32]`|4..7|The sample rate|
|Bytes Per Second|`[uint32]`|8..11|The number of bytes per second `Sample Rate * Bytes Per Block`|
|Bytes Per Block|`[uint16]`|12..13|The number of bytes per block `ChannelCount * BitsPerSample / 8`|
|Bits Per Sample|`[uint16]`|14..15|The number of bits per sample|

Let's walk thru each of the fields and why they matter:

### Audio Format (`[uint16] 0..1`)

Waves can be encoded with a custom format.  That's why this header is two bytes long.

However, many custom wave file formats are obscure, undocumented, and unsupported by most players.

We will focus on two formats:

* Fixed-Point PCM (`1`)
* IEEE float (`3`)

Fixed-point PCM stores amplitude as a whole number.

This is converted to a decimal between 1 and -1.

This forces amplitude to be "clamped" between 1 and -1.

Float stores amplitude as a single-precision decimal.

This allows us to have any amplitude.

#### Fixed-Point Encoding

If the Wave is 8-bit, each sample is one `[byte]`.

Since a `[byte]` cannot be negative, the center of our wave is at 128.

If the Wave is 16-bit, each sample is an `[int16]`, centered at zero.

If the Wave is 32-bit, each sample is an `[int32]`, centered at zero.

Any way you cut it, a fixed point encoding has a maximum amplitude.

#### Floating-Point Encoding

If a Wave uses floating point encoding, we use a `[float]` to store data instead.

As the audiophiles will tell you, this has more "dynamic range" than a fixed point.

How much more?

|32-bit Fixed Point|Floating Point|
|-|-|
|`[int32]::MaxValue - [int32]::MinValue` (4294967295) | `[float]::MaxValue - [float]::MinValue` (6.80564693277058E+38)|

This is a mind-bogglingly huge difference.

~~~PowerShell
([float]::MaxValue - [float]::MinValue) / ([int32]::MaxValue - [int32]::MinValue) 
~~~

That gives us `1.58456315620689E+29`

Still mind-boggling.

Divide by billion a few times:

~~~PowerShell
([float]::MaxValue - [float]::MinValue) / 
    ([int32]::MaxValue - [int32]::MinValue) / 
        1000000000 / 
            1000000000 / 
                1000000000
~~~

And we finally get something more readable: `158.456315620689`

How much more dynamic range does a float have?

~~~
$billion = 1000000000
158.456315620689 * $billion * $billion * $billion
~~~

Or roughly a billion times better, cubed.

### Channel Count (`[uint16] 2..3`)

The channel count is the number of channels in the audio file.

Each sample will alternate between channels.  

For a stereo file, the odd numbered samples will be on the left,
and the even numbered samples will be on the right.

### Sample Rate (`[uint32] 4..7`)

This is the number of samples per second.

A common sampling rate is 44100 samples per second.

The frequency of a sound is how often it repeats per second,
so the maximum frequency we can hold within a second of samples is the sample rate.

Most human hearing maxes out around `20000 Hz`, so this sample rate is more than enough to work with.

### Bytes Per Second (`[uint32] 8..11`)

This is the number of bytes per second.

This is normally derived from other values:  `SampleCount * ChannelCount * BytesPerBlock`

This tells the machine how much to read per second, and can be used to calculate duration.

If we divide the length of the wave data by the bytes per second, we get the total time of the wave.

### Bytes Per Block (`[uint16] 12..13`)

This is the number of bytes used to contain a single moment in time across all channels.

It is normally derived from other values: `Channel Count * BitsPerSecond/8`

### Bits Per Second (`[uint16] 14..15`)

This is the number of bits used to store an audio sample.  

More bits means more detailed sounds.

This must be a factor of `8`, because that is how many bits are in a byte.

## Wave Data

The `data` block contains the wave as a series of bytes.  

We use the `AudioFormat` and the `BitsPerSample` to determine how each sample is stored

|AudioFormat|BitsPerSample|Data Type|
|-|-|-|
|1|8|`[byte]`|
|1|16|`[int16]`|
|1|32|`[int32]`|
|3|32|`[float]`|

Each sample is the amplitude of the wave at that moment in time.

And that's all that makes up a wave file.

* A series of amplitudes
* At a `SampleRate`
* Using a specific `AudioFormat`
* To encode a `ChannelCount` of audio channels
* At `BitsPerSample`