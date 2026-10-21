# Wave Security

Wave helps you make waves.

This does not represent an inherant security risk.

While it is theoretically possible that a specific `.wav` 
file might hit a zero-day exploit in one of the many 
audio players in the world, that is outside of this module's realm of responsibility.

There are two known ways that this module may be misused.  
Neither way is unique to this module.

Both are side-effect of making waves easier to create.

## Possible Pranking

By making it easier to get system sounds and make waves, 
it makes it easy to define audio schemes for the current user.

This is by design.

This can be done as a low-rights user, and it would be possible to change any system sound.

The mitgation for this is also at the operating system level, or using the module itself.

If someone pranks your system sound scheme, turn down the volume and remove items from the control panel.

## Musical Stenography

Sound is made up of samples, and these samples are a representation of data.

It is certainly possible to construct an algoritmn that 
converts a message into a series of notes.

It is also possible to take a series of notes decode them.

This has been possible for decades with multiple binary file formats.

This module may slightly increase the liklihood of this approach, 
and it may also serve to help inspect `.wav` files for infiltrated or exfiltrated data.

The most simple method of doing this is to embed a message in 8-bit audio, 
because that _is_ the binary data.

Fortunately, sounds like this tend to sound like static, 
be _very_ short, and reveal themselves very quickly by using:

~~~PowerShell
$wav = wave -Path .\SomethingSuspicious.wav
$wav.Data | Format-Hex
~~~

As this technique predates computing by a couple of centuries,
it is not possible to prevent this technique.

However, this module may help you detect and decode it.
