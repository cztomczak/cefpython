# `JavascriptBindings` class #

## Introduction ##

With this class you can expose python functions, objects and data. Binding is made to javascript "window" object. Instantiate this class and pass it to [cefpython](cefpython).CreateBrowserSync(). See also [javascript callbacks](JavascriptCallback).

To initiate communication from python, when there is no javascript callback available yet, use [Frame](Frame).`ExecuteJavascript()` or [Frame](Frame).`ExecuteFunction()`. To get main frame for browser call [Browser](Browser).`GetMainFrame()`.

When integrating javascript with python, javascript exceptions may become python exceptions when using javascript or python callbacks. Read more about javascript errors handling [here](JavascriptErrors).

In CEF 3 communication between javascript and python can only be asynchronous. It is due multi-process architecture. Javascript runs in the renderer process, while python runs in the browser process. Communication is done using IPC messaging between processes. When you need to return value in a python or javascript function, then the solution is to use [callbacks](https://en.wikipedia.org/wiki/Callback_(computer_programming)). Both python callbacks and javascript callbacks are supported.

There are plans to support binding data by reference (a list, dict or object's properties). This would be possible with the use of CefRegisterExtension().

## Example usage ##

See the [wxpython.py](../blob/master/cefpython/cef3/windows/binaries_32bit/wxpython.py) example for an example usage of javascript bindings, javascript callbacks and python callbacks.

## Methods ##

### `__`init`__`(bool bindToFrames=False, bool bindToPopups=False) (void) ###

> By default we bind only to top frame.

> `bindToFrames` option - whether bindings are accessible inside iframes and frameset.

> `bindToPopups` option - whether bindings are accessible from popups.

### IsValueAllowed(mixed value) (bool) ###

> Whether you are allowed to bind this value to javascript, value may be one of:

> - list<br>
<blockquote>- bool<br>
- float<br>
- int<br>
- long<br>
- None (null in js)<br>
- dict (object in js)<br>
- string<br>
- unicode<br>
- tuple<br>
- function<br>
- instancemethod (an object's method)<br></blockquote>

<blockquote>If <code>long</code> value is outside of int32 limits (-2147483647..2147483647) then it will be converted to string in javascript (it should really be -2147483648, but then Cython complains about it).</blockquote>

<h3>Rebind() (void)</h3>

<blockquote>Call this to rebind javascript bindings. This is useful when using reload() on python's module, you can make changes to application and see it instantly without having to re-launch application. After you reload() module set all the bindings again using SetFunction/SetObject/SetProperty methods, then call Rebind() to rebind it to javascript. See <a href='https://code.google.com/p/cefpython/issues/detail?id=12'>Issue 12</a> (<a href='http://cefpython.googlecode.com/issues/attachment?aid=120013000&name=reload_example.zip&token=lq-FNXxmXyjmXwFMvwYPLIEW1PY%3A1347648551040'>reload_example.zip</a>) for an example.</blockquote>

<blockquote>There is an another way of doing rebinding, you can call <a href='Frame'>Frame</a>.SetProperty(), but this is not best performant way as it creates a C++ class V8FunctionHandler for each function, when doing Rebind() there is only one such class created. <a href='Frame'>Frame</a>.SetProperty() is also more limited, you cannot bind objects using it, though it could be supported, I'm wondering whether there is a need for that, it would allow to pass objects as arguments to javascript callbacks so maybe it will be implemented in the future. Also Rebind() does bindings to frames and popups automatically according to bindToFrames and bindToPopups constructor options, while using <a href='Frame'>Frame</a>.SetProperty() you would need to take care of that by yourself.</blockquote>

<blockquote>Rebind does not solve all scenarios, take for example: what happens if you pass a python callback to javascript and then do rebindings? You still get old function referenced in javascript.</blockquote>

<h3>SetFunction(string name, function|method func) (void)</h3>

<blockquote>This function will be binded to window object in html, you can call it in two ways:</blockquote>

<pre><code>	window.myfunc()<br>
	myfunc() # window properties are global<br>
</code></pre>

<blockquote>You can use SetFunction() to overwrite native javascript function, for example if you would like to implement your own version of "window.alert" do this:</blockquote>

<pre><code>	def PyAlert(msg):<br>
		win32gui.MessageBox(__browser.GetWindowID(), msg, "PyAlert()", win32con.MB_ICONQUESTION)<br>
<br>
	bindings = cefpython.JavascriptBindings(bindToFrames=True, bindToPopups=True)<br>
	bindings.SetFunction("alert", PyAlert)<br>
</code></pre>

<blockquote>This function is dummy, it really calls SetProperty(), you might use it as well to bind functions.</blockquote>

<h3>SetObject(string name, instance object) (void)</h3>

<blockquote>Currently this function binds only methods of an object. Example:</blockquote>

<pre><code>	# In python:<br>
	bindings.SetObject("myobject", myobject)<br>
	// In javasript:<br>
	window.myobject.someMethod();<br>
	// or:<br>
	myobject.someMethod();<br>
</code></pre>

<blockquote>Currently when binding object only methods are binded, I decided not to bind properties of the object, as they would be binded by copying value and this might be confusing, as accessing object's property from javascript might give a different value during runtime then the real value when getting the property from python runtime. Only object's methods and functions can be binded by reference. Still you can bind object's properties if you like, you can find useful method IsValueAllowed() to check which properties can be binded, of course doing it this way will not allow you to access properties through "window.myobject.property", you can only bind to the "window" object so you should imitate some kind of namespace, so that accessing property would be through "window.myobject_property" or "myobject_property" as window prefix is always optional. Use dir() function to list object's properties. Example code:</blockquote>

<pre><code>	import types<br>
<br>
	for name in dir(myobject):<br>
		if name[0] == '_': # ignore private attributes<br>
			continue<br>
		attr = getattr(myobject, name)<br>
		# Do not bind: functions, methods - this check is necessary as IsValueAllowed is true for these.<br>
		if type(attr) not in (types.FunctionType, types.MethodType):<br>
			if bindings.IsValueAllowed(attr):<br>
				bindings.SetProperty("myobject_"+name, attr)<br>
</code></pre>

<blockquote>There is a plan for the future to support binding object's properties by reference, it would be possible with the use of CefRegisterExtension().</blockquote>

<h3>SetProperty(string name, mixed value) (void)</h3>

<blockquote>Set some value to property of the window object in html. This propertiy  for example can hold configuration options or some other data required at startup of your application.</blockquote>

<blockquote>Mixed type is one that can be converted to javascript types, see IsValueAllowed() for a full list.</blockquote>

<blockquote>To get the value during runtime (as it might been changed via javascript) call <a href='Frame'>Frame</a>.GetProperty().</blockquote>

<blockquote>This function copies the values and converts them to V8 Javascript values (the only exception are functions and methods), if you pass a Dictionary don't expect that if you change it later and then call <a href='Frame'>Frame</a>.GetProperty that you will get the modified value.