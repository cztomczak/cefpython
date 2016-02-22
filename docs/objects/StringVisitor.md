# StringVisitor callbacks #

See [Frame](Frame).`GetSource()` and [Frame](Frame).`GetText()`.

You must keep a strong reference to the `StringVisitor` object
while visiting strings, otherwise it gets destroyed and the
`StringVisitor` callbacks won't be called.

## CEF 3 ##

bool **Visit**(string value)

> Method that will be executed.