[API categories](API-categories.md) | [API index](API-index.md)


# Frame (object)

Remember to free all frame references for the browser to shut down cleanly.
Otherwise data such as cookies or other storage might not be flushed to disk
when closing app, and other issues might occur as well. If you store
a reference to Frame somewhere in your code then to free it just assign
a None value to the variable.

To compare frame objects always use [GetIdentifier()](#getidentifier)
method. Do not compare two Frame objects variables directly. There
are some edge cases when after the OnBeforeClose event frame objects
are no more globally referenced thus a new instance is created that
wraps upstream CefFrame object. Frame objects that were globally
unreferenced do not have properties of the original Frame object.


Table of contents:
* [Methods](#methods)
  * [Copy](#copy)
  * [Cut](#cut)
  * [Delete](#delete)
  * [ExecuteFunction](#executefunction)
  * [ExecuteJavascript](#executejavascript)
  * [GetBrowser](#getbrowser)
  * [GetIdentifier](#getidentifier)
  * [GetBrowserIdentifier](#getbrowseridentifier)
  * [GetName](#getname)
  * [GetParent](#getparent)
  * [GetSource](#getsource)
  * [GetText](#gettext)
  * [GetUrl](#geturl)
  * [IsFocused](#isfocused)
  * [IsMain](#ismain)
  * [IsValid](#isvalid)
  * [LoadUrl](#loadurl)
  * [Paste](#paste)
  * [Redo](#redo)
  * [SelectAll](#selectall)
  * [Undo](#undo)
  * [ViewSource](#viewsource)


## Methods


### Copy

| | |
| --- | --- |
| __Return__ | void |

Execute copy in this frame.


### Cut

| | |
| --- | --- |
| __Return__ | void |

Execute cut in this frame.


### Delete

| | |
| --- | --- |
| __Return__ | void |

Execute delete in this frame.


### ExecuteFunction

| Parameter | Type |
| --- | --- |
| funcName | string |
| .. | *args |
| __Return__ | void |

Call a javascript function asynchronously. This can also call object's methods, just pass "object.method" as funcName. Any valid javascript syntax is allowed as funcName, you could even pass an anonymous function here. For a list of allowed types of arguments see [JavascriptBindings](JavascriptBindings.md).IsValueAllowed() - except function, method and instance. Passing a python function here is not allowed, it is only possible using the [JavascriptCallback](JavascriptCallback.md) object.


### ExecuteJavascript

| Parameter | Type |
| --- | --- |
| jsCode | string |
| scriptUrl="" | string |
| startLine=1 | int |
| __Return__ | void |

Execute a string of JavaScript code in this frame. The sciptUrl parameter is the url where the script in question can be found, if any. The renderer may request this URL to show the developer the source of the error. The startLine parameter is the base line number to use for error reporting. This function executes asynchronously so there is no way to get the returned value. Calling javascript <> native code synchronously is not possible.


### GetBrowser

| | |
| --- | --- |
| __Return__ | [Browser](Browser.md) |

Returns the browser that this frame belongs to.


### GetIdentifier

| | |
| --- | --- |
| __Return__ | int |

Frame identifiers are unique per render process, they are not
globally unique.

Returns < 0 if the underlying frame does not yet exist.


### GetBrowserIdentifier

| | |
| --- | --- |
| __Return__ | int |

Returns the globally unique identifier for the browser hosting this frame.


### GetName

| | |
| --- | --- |
| __Return__ | string |

Returns the name for this frame. If the frame has an assigned name (for example, set via the iframe "name" attribute) then that value will be returned. Otherwise a unique name will be constructed based on the frame parent hierarchy. The main (top-level) frame will always have an empty name value.


### GetParent

| | |
| --- | --- |
| __Return__ | [Frame](Frame.md) |

Returns the parent of this frame or None if this is the main (top-level) frame. This method should only be called on the UI thread.


### GetSource

| Parameter | Type |
| --- | --- |
| visitor | [StringVisitor](StringVisitor.md) |
| __Return__ | void |

Retrieve this frame's HTML source as a string sent to the specified
visitor.


### GetText

| Parameter | Type |
| --- | --- |
| visitor | [StringVisitor](StringVisitor.md) |
| __Return__ | void |

Retrieve this frame's display text as a string sent to the specified
visitor.


### GetUrl

| | |
| --- | --- |
| __Return__ | string |

Returns the url currently loaded in this frame.


### IsFocused

| | |
| --- | --- |
| __Return__ | bool |

Returns true if this is the focused frame. This method should only be called on the UI thread.


### IsMain

| | |
| --- | --- |
| __Return__ | bool |

Returns true if this is the main (top-level) frame.


### IsValid

| | |
| --- | --- |
| __Return__ | bool |

True if this object is currently attached to a valid frame.


### LoadUrl

| Parameter | Type |
| --- | --- |
| url | string |
| __Return__ | void |

Load the specified |url|. To load HTML content directly use a data URI,
e.g. `LoadUrl("data:text/html,some+html+code+here")`. See also
[ResourceHandler](ResourceHandler.md) for a custom resource handler approach.


### Paste

| | |
| --- | --- |
| __Return__ | void |

Execute paste in this frame.


### Redo

| | |
| --- | --- |
| __Return__ | void |

Execute redo in this frame.


### SelectAll

| | |
| --- | --- |
| __Return__ | void |

Execute select all in this frame.


### Undo

| | |
| --- | --- |
| __Return__ | void |

Execute undo in this frame.


### ViewSource

| | |
| --- | --- |
| __Return__ | void |

Save this frame's HTML source to a temporary file and open it in the default text viewing application.
