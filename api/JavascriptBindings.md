[API categories](API-categories.md) | [API index](API-index.md)


# JavascriptBindings (class)


Table of contents:
* [Introduction](#introduction)
* [Methods](#methods)
  * [\_\_init\_\_()](#__init__)
  * [IsValueAllowed](#isvalueallowed)
  * [Rebind](#rebind)
  * [SetFunction](#setfunction)
  * [SetObject](#setobject)
  * [SetProperty](#setproperty)


## Introduction

With this class you can expose python functions, objects and data. Binding is made to javascript "window" object. Instantiate this class and pass it using [Browser](Browser.md).SetJavascriptBindings(). See also [javascript callbacks](JavascriptCallback.md).

To initiate communication from python, when there is no javascript callback available yet, use [Frame](Frame.md).ExecuteJavascript() or [Frame](Frame.md).ExecuteFunction(). To get main frame for browser call [Browser](Browser.md).GetMainFrame().

When integrating javascript with python, javascript exceptions may become python exceptions when using javascript or python callbacks.

In CEF 3 communication between javascript and python can only be asynchronous. It is due multi-process architecture. Javascript runs in the renderer process, while python runs in the browser process. Communication is done using IPC messaging between processes. When you need to return value in a python or javascript function, then the solution is to use [callbacks](https://en.wikipedia.org/wiki/Callback_(computer_programming)). Both python callbacks and javascript callbacks are supported.

There are plans to support binding data by reference (a list, dict or object's properties). This would be possible with the use of CefRegisterExtension().


## Methods


### \_\_init\_\_()

| Parameter | Type |
| --- | --- |
| bindToFrames=False | bool |
| bindToPopups=False | bool |
| __Return__ | void |

By default we bind only to top frame.

`bindToFrames` option - whether bindings are accessible inside iframes and frameset.

`bindToPopups` option - whether bindings are accessible from popups.


### IsValueAllowed

| Parameter | Type |
| --- | --- |
| value | mixed |
| __Return__ | void |

Whether you are allowed to bind this value to javascript, value may be one of:

- list
- bool
- float
- int
- long
- None (null in js)
- dict (object in js)
- string
- unicode
- tuple
- function
- instancemethod (an object's method)

If `long` value is outside of int32 limits (-2147483647..2147483647) then it will be converted to string in javascript (it should really be -2147483648, but then Cython complains about it).


### Rebind

| | |
| --- | --- |
| __Return__ | void |

Call this to rebind javascript bindings. This is useful when using reload() on python's module, you can make changes to application and see it instantly without having to re-launch application. After you reload() module set all the bindings again using SetFunction/SetObject/SetProperty methods, then call Rebind() to rebind it to javascript. See [Issue #12](../issues/12) ([reload_example.zip](http://cefpython.googlecode.com/issues/attachment?aid=120013000&name=reload_example.zip&token=lq-FNXxmXyjmXwFMvwYPLIEW1PY%3A1347648551040)) for an example.

There is an another way of doing rebinding, you can call [Frame](Frame.md).SetProperty(), but this is not best performant way as it creates a C++ class V8FunctionHandler for each function, when doing Rebind() there is only one such class created. [Frame](Frame.md).SetProperty() is also more limited, you cannot bind objects using it, though it could be supported, I'm wondering whether there is a need for that, it would allow to pass objects as arguments to javascript callbacks so maybe it will be implemented in the future. Also Rebind() does bindings to frames and popups automatically according to bindToFrames and bindToPopups constructor options, while using [Frame](Frame.md).SetProperty() you would need to take care of that by yourself.

Rebind does not solve all scenarios, take for example: what happens if you pass a python callback to javascript and then do rebindings? You still get old function referenced in javascript.


### SetFunction

| Parameter | Type |
| --- | --- |
| name | string |
| func | function|method |
| __Return__ | void |

This function will be binded to window object in html, you can call it in two ways:

```
window.myfunc()
	myfunc() # window properties are global
```

You can use SetFunction() to overwrite native javascript function, for example if you would like to implement your own version of "window.alert" do this:

```
def PyAlert(msg):
		win32gui.MessageBox(__browser.GetWindowID(), msg, "PyAlert()", win32con.MB_ICONQUESTION)

	bindings = cefpython.JavascriptBindings(bindToFrames=True, bindToPopups=True)
	bindings.SetFunction("alert", PyAlert)
```

This function is dummy, it really calls SetProperty(), you might use it as well to bind functions.


### SetObject

| Parameter | Type |
| --- | --- |
| name | string |
| object | instance |
| allow_properties | bool=False |
| __Return__ | void |

Normally this function binds only methods of an object. If `allow_properties` is set properties will be copied during binding also.
Example:

```
# In python:
	bindings.SetObject("myobject", myobject)
	// In javasript:
	window.myobject.someMethod();
	// or:
	myobject.someMethod();
```

By default when binding object only methods are bound unless `allow_properties` is explicitely set. This was done as properties can currently ounly be bound by copying value during the binding process. It is expected this could be confusing as accessing object's property from javascript might give a different value during runtime then the real value when getting the property from python runtime if either end has been changed in the mean time. Only object's methods and functions can be bound by reference currently.  
If so desired the properties can be bound just be aware that the javascript object will only be able to access the values as they existed at the time binding was performed. Changes to the javascript or python copies of the properties will not be reflected on the other.

```
# In python:
	class MyObject(object):
        def __init__(self):
            self.definition = "a property"

        @property
        def py_prop(self):
            return True

        def someMethod(self):
            print("someMethod() called")

	myobject = MyObject()
	bindings.SetObject("myobject", myobject, allow_properties=True)
	browser.SetJavascriptBindings(bindings)
	myobject.definition = "changed property"  # js will not see this
    
	// In javasript:
	window.myobject.definition == "a property";
	// or:
	myobject.py_prop == true;
	myobject.someMethod();
```

There is a plan for the future to support binding object's properties by reference, it would be possible with the use of CefRegisterExtension().

If the python object has the special function `__call__` the javascript object will also be callable, running this python function. This allows some more complex javascript objects to be crafted.

```
# In python:
	class myobject(object):
        def __call__(self, arg):
            print("myobject(%s) called" % arg) 

        def someMethod(self):
            print("someMethod() called")

	bindings.SetObject("myobject", myobject())
    
	// In javasript:
	myobject("run object");
	myobject.someMethod();
```

### SetProperty

| Parameter | Type |
| --- | --- |
| name | string |
| value | mixed |
| __Return__ | void |

Set some value to property of the window object in html. This propertiy  for example can hold configuration options or some other data required at startup of your application.

Mixed type is one that can be converted to javascript types, see IsValueAllowed() for a full list.

To get the value during runtime (as it might been changed via javascript) call [Frame](Frame.md).GetProperty().

This function copies the values and converts them to V8 Javascript values (the only exception are functions and methods), if you pass a Dictionary don't expect that if you change it later and then call [Frame](Frame.md).GetProperty that you will get the modified value.
