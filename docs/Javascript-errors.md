# Javascript Errors #

Typically when you browse a webpage your javascript errors appear in the developer tools javascript console. In cefadvanced.py example there is a binding to F12 key for opening developer tools.

## Catching errors programmatically ##

To catch errors programmatically implement [JavascriptContextHandler](JavascriptContextHandler).`OnUncaughtException()`.

## Javascript bindings and callbacks ##

When a python function is invoked from javascript and it fails, a python exception is thrown. It is written to the console and logged to the "error.log" file, then application exits. You may change this behavior by modifying `ExceptHook` function found in examples.

A python exception might be thrown when in a context of a javascript callback. For example: javascript invokes a python function and passes a javascript callback to it, which is later called when python function finishes its job, if there is a javascript exception thrown during execution of the javascript callback, then a python exception will be thrown.

See also [Issue 11](../issues/11) - "Throw JS / Python exceptions according to execution context".