[API categories](API-categories.md) | [API index](API-index.md)


# StringVisitor (interface)

See [Frame](Frame.md).GetSource() and [Frame](Frame.md).GetText().

You have to keep a strong reference to the `StringVisitor` object
while visiting strings, otherwise it gets destroyed and the
`StringVisitor` callbacks won't be called.


Table of contents:
* [Callbacks](#callbacks)
  * [Visit](#visit)


## Callbacks


### Visit

| Parameter | Type |
| --- | --- |
| value | string |
| __Return__ | bool |

Method that will be executed.
