# `JavascriptCallback` object #

You can pass a callback function from Javascript to Python, when you do that, what you get in Python is a `JavascriptCallback` object that you can use to call javascript function back.

If you call the javascript callback and it fails, instead of js exception what you get is a python exception that exits the application by default (see sys.excepthook in examples), if you want to know more read about [Javascript Errors](JavascriptErrors).

See also [JavascriptBindings](JavascriptBindings).

See also [Issue 11](../issues/11) (Throw JS / Python exceptions according to execution context).


---


mixed **Call**(`[`mixed `param` `[`, mixed `param` `[`, ..`]]]`)

> Call the javascript callback function.

> For a list of allowed types for `mixed` see [JavascriptBindings](JavascriptBindings).IsValueAllowed().

string **GetName**()

> Get the javascript function's name. If that is an anonymous function you will get some random name like "É☺«".