[API categories](API-categories.md) | [API index](API-index.md)


# JavascriptCallback (object)

You can pass a callback function from Javascript to Python, when you do that, what you get in Python is a `JavascriptCallback` object that you can use to call javascript function back.

If you call the javascript callback and it fails, instead of js exception what you get is a python exception that exits the application by default (see sys.excepthook in examples). 

See also [JavascriptBindings](JavascriptBindings.md).

See also [Issue #11](../issues/11) (Throw JS / Python exceptions according to execution context).


Table of contents:
* [Methods](#methods)
  * [Call](#call)
  * [GetFrame](#getframe)
  * [GetId](#getid)
  * [GetFunctionName](#getfunctionname)


## Methods


### Call

| Parameter | Type |
| --- | --- |
| [params..] (optional) | mixed |
| __Return__ | void |

Call the javascript callback function. Pass arguments optionally.

For a list of allowed types for `mixed` see JavascriptBindings.[IsValueAllowed()](JavascriptBindings.md#isvalueallowed).


### GetFrame

| | |
| --- | --- |
| __Return__ | [Frame](Frame.md) |

Get Frame object associated with this callback. If Browser was destroyed
then Frame may be None.


### GetId

| | |
| --- | --- |
| __Return__ | int |

Get this callback's identifier.


### GetFunctionName

| | |
| --- | --- |
| __Return__ | string |

Get the javascript function's name. If that is an anonymous function you will get some random name like "É☺«".
